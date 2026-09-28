Objektiv
========================================

![Objektiv Logo][logo] Objektiv is a utility that lets you switch your
default browser easily. You might find it useful if you're a web
designer or use multiple browsers in your workflow.

Install
----------------------------------------

This branch (0.7.0) is a native Apple silicon build for macOS 13 (Ventura)
onwards. The upstream 0.6.3 release and the Homebrew cask are Intel-only and
will stop opening in a future macOS release.

Features
----------------------------------------

 - A status-bar icon for quick access
 - An optional global hotkey triggers an overlay window for even quicker
   switching
 - Pressing Option (⌥) in the status menu lets you hide browsers that
   are incorrectly detected

![Screenshot of the Objektiv overlay window](Objektiv/en.lproj/objektiv-overlay.png)

Usage
----------------------------------------
Objektiv sets itself as the system default browser once (macOS asks you to
confirm), then forwards every link and HTML file to the browser you pick.
Switching browsers in Objektiv never triggers the macOS confirmation again.
If you skipped the prompt, choose Objektiv in System Settings > Desktop & Dock >
Default web browser.

Building & Running
----------------------------------------

Requires Xcode 15 or later. MASShortcut comes in through Swift Package Manager;
there is no CocoaPods step. The Xcode project is generated from `project.yml`
with [XcodeGen][] (`brew install xcodegen`), and the generated project is
committed so you can open `Objektiv.xcodeproj` directly.

    $ xcodegen generate            # only after editing project.yml
    $ xcodebuild -project Objektiv.xcodeproj -scheme Objektiv -configuration Release -derivedDataPath build build
    $ xcodebuild -project Objektiv.xcodeproj -scheme Objektiv -derivedDataPath build test
    $ ditto build/Build/Products/Release/Objektiv.app /Applications/Objektiv.app

The build is ad-hoc signed, which is fine on the machine that built it. Copying
it to another Mac will trigger a Gatekeeper warning.

### What changed in 0.7.0

 - Native arm64 (universal) build; Intel-only Sparkle removed (its update feed is dead)
 - CocoaPods replaced by Swift Package Manager; CDEvents replaced by a small FSEvents watcher
 - Launch Services calls moved to the modern `NSWorkspace` APIs
 - Launch at login uses `SMAppService`; an existing legacy login item preference is migrated once
 - Notifications use the UserNotifications framework
 - Links go through `application:openURLs:`, which fixes local HTML files (the old
   code built `file://locahost/...` URLs)
 - Links fall back to Safari, then the first installed browser, if the selected browser
   is uninstalled, so Objektiv can never forward a link to itself
 - Objektiv no longer lists itself as a browser (the built-in blacklist was case-sensitive)
 - Declares itself a viewer for HTML/XHTML files instead of plain text
 - The "move to Applications folder" prompt (LetsMove) was removed
 - Zero deprecation warnings against the macOS 26 SDK; unit tests for the browser
   filtering and fallback logic

Copyright & About
----------------------------------------

Objektiv was built by the former web development company *nth loop* to solve
a problem they were facing and to learn all about developing Mac Apps.
It might be ridiculously over-engineered for such a simple utility.

Copyright 2012, [nth loop][]. Objektiv is available under the MIT
License.

Contributors
----------------------------------------

* [Anks](https://github.com/Anks), original developer
* [xrivatsan](https://github.com/xrivatsan), original developer
* [Vorror](https://github.com/Vorror), major bugfixes and making the tool work with present-day macOS
* Apple silicon / modern macOS port (0.7.0), 2026


Credits
----------------------------------------

  - [MASShortcut][] by Vadim Shpakovski (BSD Licensed)

Earlier versions also used ZeroKit, CDEvents, Sparkle and Camino's
NSWorkspace+Utils; 0.7.0 replaced all of them with system APIs.

  [logo]:        Objektiv/Objektiv.iconset/icon_128x128.png
  [nth loop]:    http://nthloop.com
  [XcodeGen]:    https://github.com/yonaskolb/XcodeGen
  [MASShortcut]: https://github.com/cocoabits/MASShortcut
