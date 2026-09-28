Objektiv
========================================

![Objektiv Logo][logo] Objektiv is a small menu-bar utility that lets you switch
your default browser in one click. Useful if you're a web designer or developer,
or just keep work and personal browsing in different browsers.

This is a maintained continuation of [nthloop/Objektiv][upstream], which stopped
at version 0.6.3 in 2020. That release is Intel-only, and macOS now warns that
it "will not open in a future release of macOS". Version 0.7 is a native
Apple silicon build, updated to current macOS APIs.

Install
----------------------------------------

1. Download `Objektiv.zip` from the [latest release][releases].
2. Unzip it and drag **Objektiv.app** into your Applications folder.
3. Open it. When asked, click **Set As Default**, then confirm in the macOS
   dialog that follows.

Requires macOS 13 (Ventura) or later. The download is a universal app, so it
also runs on Intel Macs.

Upgrading from 0.6.3: quit the old version, replace it in Applications, and
open the new one. Your browser choice, hidden browsers and hotkey carry over.

How it works
----------------------------------------

Objektiv sets itself as the system default browser once, then forwards every
link and HTML file to the browser you've picked. Switching browsers in
Objektiv never brings up the macOS "change default browser?" prompt again.

If you skipped the prompt on first launch, choose Objektiv under
System Settings > Desktop & Dock > Default web browser.

Features
----------------------------------------

 - A menu-bar icon showing the current browser, with every installed browser
   one click (or one number key) away
 - An optional global hotkey that opens an overlay for even quicker switching
 - Hold Option (⌥) in the menu to hide browsers you never use, or to bring
   hidden ones back
 - Launch at login, auto-hiding menu-bar icon, and optional notifications
   when you switch

![Screenshot of the Objektiv overlay window](Objektiv/en.lproj/objektiv-overlay.png)

What's new in 0.7
----------------------------------------

 - Native Apple silicon (universal) build for macOS 13 and later
 - Launch at login uses `SMAppService`, so it shows up properly in
   System Settings > General > Login Items
 - Notifications use the UserNotifications framework
 - Default-browser handling moved to the current `NSWorkspace` APIs
 - Local HTML files opened through Objektiv now work (0.6.3 built broken
   `file://` URLs)
 - If your chosen browser is uninstalled, links go to Safari instead of failing
 - Objektiv no longer lists itself as one of the browsers
 - Sparkle auto-updates removed (the old update feed is gone); check this
   repository's releases for new versions
 - The "move to Applications folder" prompt was removed

Building from source
----------------------------------------

Requires Xcode 15 or later. The Xcode project is generated from `project.yml`
with [XcodeGen][] and committed, so you can open `Objektiv.xcodeproj` directly.
MASShortcut is pulled in through Swift Package Manager.

    xcodegen generate                # only needed after editing project.yml
    xcodebuild -project Objektiv.xcodeproj -scheme Objektiv -configuration Release -derivedDataPath build build
    xcodebuild -project Objektiv.xcodeproj -scheme Objektiv -derivedDataPath build test

The built app is at `build/Build/Products/Release/Objektiv.app`. Local builds
are ad-hoc signed, which is fine on the Mac that built them.

To make a signed, notarised release zip (needs a Developer ID certificate and a
`notarytool` keychain profile):

    scripts/release.sh "Developer ID Application: Your Name (TEAMID)" your-notary-profile

Copyright & About
----------------------------------------

Objektiv was built by the former web development company *nth loop* to solve
a problem they were facing and to learn all about developing Mac apps.

Copyright 2012, [nth loop][]. Objektiv is available under the MIT License.

Contributors
----------------------------------------

* [Anks](https://github.com/Anks), original developer
* [xrivatsan](https://github.com/xrivatsan), original developer
* [Vorror](https://github.com/Vorror), major bugfixes and making the tool work with present-day macOS
* [edmondmiu](https://github.com/edmondmiu), Apple silicon and modern macOS port (0.7)

Credits
----------------------------------------

  - [MASShortcut][] by Vadim Shpakovski (BSD Licensed)

Earlier versions also used ZeroKit, CDEvents, Sparkle and Camino's
NSWorkspace+Utils. Version 0.7 replaced all of them with system APIs.

  [logo]:        Objektiv/Objektiv.iconset/icon_128x128.png
  [upstream]:    https://github.com/nthloop/Objektiv
  [releases]:    https://github.com/edmondmiu/Objektiv/releases/latest
  [nth loop]:    http://nthloop.com
  [XcodeGen]:    https://github.com/yonaskolb/XcodeGen
  [MASShortcut]: https://github.com/cocoabits/MASShortcut
