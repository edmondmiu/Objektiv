//
//  AppDelegate.m
//  Objektiv
//
//  Created by Ankit Solanki on 01/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import "AppDelegate.h"
#import "BrowserItem.h"
#import "Browsers.h"
#import "Constants.h"
#import "PrefsController.h"
#import "ImageUtils.h"
#import "BrowsersMenu.h"
#import "OverlayWindow.h"
#import "LoginItem.h"
#import "ApplicationsWatcher.h"
@import MASShortcut;

@interface AppDelegate()
{
    @private
    NSStatusItem *statusBarIcon;
    BrowsersMenu *browserMenu;
    NSUserDefaults *defaults;
    NSWorkspace *sharedWorkspace;
    OverlayWindow *overlayWindow;
    ApplicationsWatcher *applicationsWatcher;
    NSString *_defaultBrowser;
}
@end

@implementation AppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"applicationDidFinishLaunching");

    self.prefsController = [[PrefsController alloc] initWithWindowNibName:@"PrefsController"];
    sharedWorkspace = [NSWorkspace sharedWorkspace];

    browserMenu = [[BrowsersMenu alloc] init];

    NSLog(@"Setting defaults");
    defaults = [NSUserDefaults standardUserDefaults];
    NSString *defaultsPath = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
    [defaults registerDefaults:[NSDictionary dictionaryWithContentsOfFile:defaultsPath]];

    [UNUserNotificationCenter currentNotificationCenter].delegate = self;

    [self syncLoginItem];
    [self displayAreWeDefaultMsg];

    [defaults addObserver:self
               forKeyPath:PrefAutoHideIcon
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    [defaults addObserver:self
               forKeyPath:PrefStartAtLogin
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    [[MASShortcutBinder sharedBinder] bindShortcutWithDefaultsKey:PrefHotkey toAction:^{
        [self hotkeyTriggered];
     }];
    
    [[Browsers sharedInstance] findBrowsers];
    [self showAndHideIcon:nil];

    overlayWindow = [[OverlayWindow alloc] init];

    [self watchApplicationsFolder];

    NSLog(@"applicationDidFinishLaunching :: finish");
}

- (void)watchApplicationsFolder
{
    // Watch the /Applications & ~/Applications directories for a change
    NSArray *paths = @[
        @"/Applications",
        [NSHomeDirectory() stringByAppendingPathComponent:@"Applications"]
    ];

    applicationsWatcher = [[ApplicationsWatcher alloc] initWithPaths:paths handler:^{
        [[Browsers sharedInstance] findBrowsersAsync];
    }];
}

- (BOOL)applicationShouldHandleReopen: (NSApplication *)application hasVisibleWindows: (BOOL)visibleWindows
{
    [self showAndHideIcon:nil];
    return YES;
}

#pragma mark - NSKeyValueObserving

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if ([keyPath isEqualToString:PrefAutoHideIcon])
    {
        [self showAndHideIcon:nil];
    }
    if ([keyPath isEqualToString:PrefStartAtLogin])
    {
        [self toggleLoginItem];
    }
}

#pragma mark - "Business" Logic

- (NSArray*) browsers
{
    return [Browsers browsers];
}

- (void) selectABrowser:sender
{
    NSString *newDefaultBrowser = [sender respondsToSelector:@selector(representedObject)]
        ? [sender representedObject]
        :sender;

    NSLog(@"Selecting a browser: %@", newDefaultBrowser);
    [Browsers sharedInstance].defaultBrowserIdentifier = newDefaultBrowser;
    [self performSelector:@selector(updateStatusBarIcon) withObject:nil afterDelay:0.1];
    
    if ([defaults boolForKey:PrefShowNotifications])
    {
        [self showNotification:newDefaultBrowser];
    }
}

// The login item used to be stored with LSSharedFileList, which macOS ignores.
// Carry the old preference over once, then mirror the real SMAppService state
// so changes made in System Settings > Login Items are respected.
- (void) syncLoginItem
{
    if (![defaults boolForKey:PrefLoginItemMigrated])
    {
        if ([defaults boolForKey:PrefStartAtLogin]) [LoginItem setEnabled:YES];
        [defaults setBool:YES forKey:PrefLoginItemMigrated];
    }
    [defaults setBool:[LoginItem isEnabled] forKey:PrefStartAtLogin];
}

- (void) toggleLoginItem
{
    BOOL wanted = [defaults boolForKey:PrefStartAtLogin];
    if (wanted == [LoginItem isEnabled]) return;

    [LoginItem setEnabled:wanted];
    if ([LoginItem requiresApproval]) [LoginItem openSystemSettings];

    BOOL actual = [LoginItem isEnabled];
    if (actual != wanted)
    {
        // Registration failed; put the checkbox back to the real state.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->defaults setBool:actual forKey:PrefStartAtLogin];
            [self.prefsController refreshUI];
        });
    }
}

#pragma mark - UI


- (void) hotkeyTriggered
{
    NSLog(@"@Hotkey triggered");
    if (overlayWindow.isVisible) {
        [overlayWindow close];
        return;
    }
    [overlayWindow makeKeyAndOrderFront:NSApp];
    [self showAndHideIcon:nil];
}

- (void) createStatusBarIcon
{
    NSLog(@"createStatusBarIcon");
    if (statusBarIcon != nil) return;
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];

    statusBarIcon = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    statusBarIcon.button.toolTip = AppDescription;
    [self updateStatusBarIcon];

    statusBarIcon.menu = browserMenu;
}

- (void) updateStatusBarIcon
{
    NSString *identifier = [Browsers sharedInstance].defaultBrowserIdentifier;
    statusBarIcon.button.image = [ImageUtils statusBarIconForAppId:identifier];

    if ([identifier isEqualToString:_defaultBrowser]) return;
    _defaultBrowser = identifier;
    [[Browsers sharedInstance] findBrowsersAsync];
}

- (void) destroyStatusBarIcon
{
    NSLog(@"destroyStatusBarIcon");
    if (![defaults boolForKey:PrefAutoHideIcon])
    {
        return;
    }
    if (browserMenu.menuIsOpen)
    {
        [self performSelector:@selector(destroyStatusBarIcon) withObject:nil afterDelay:10];
    }
    else
    {
        [[statusBarIcon statusBar] removeStatusItem:statusBarIcon];
        statusBarIcon = nil;
    }
}

- (void) showAndHideIcon:(NSEvent*)hotKeyEvent
{
    NSLog(@"showAndHideIcon");
    [self createStatusBarIcon];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(destroyStatusBarIcon) object:nil];
    if ([defaults boolForKey:PrefAutoHideIcon])
    {
        [self performSelector:@selector(destroyStatusBarIcon) withObject:nil afterDelay:10];
    }
}

- (void) showAbout
{
    [self activate];
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:nil];
}

- (void) doQuit
{
    [NSApp terminate:nil];
}

- (void) activate
{
    if (@available(macOS 14.0, *)) {
        [NSApp activate];
    } else {
        [NSApp activateIgnoringOtherApps:YES];
    }
}

#pragma mark - Utilities

- (void) showNotification:(NSString *)browserIdentifier
{
    NSURL *browserURL = [sharedWorkspace URLForApplicationWithBundleIdentifier:browserIdentifier];
    NSString *browserName = browserURL
        ? [[NSFileManager defaultManager] displayNameAtPath:browserURL.path]
        : browserIdentifier;

    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString stringWithFormat:NotificationTitle, browserName];
    content.body = [NSString stringWithFormat:NotificationText, browserName, AppName];

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:UNAuthorizationOptionAlert
                          completionHandler:^(BOOL granted, NSError *error) {
        if (!granted) return;
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"browser-selected"
                                                                              content:content
                                                                              trigger:nil];
        [center addNotificationRequest:request withCompletionHandler:nil];
    }];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    completionHandler(UNNotificationPresentationOptionBanner | UNNotificationPresentationOptionList);
}

-(void)displayAreWeDefaultMsg
{
    if([defaults boolForKey:PrefAreWeDefault]) return;
    NSString *systemDefault = [[Browsers sharedInstance] systemDefaultBrowser];
    if(systemDefault && [[[NSBundle mainBundle] bundleIdentifier] caseInsensitiveCompare:systemDefault] == NSOrderedSame) {
        return;
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setShowsSuppressionButton:YES];
    [alert setMessageText:NSLocalizedString(@"Non Default Browser", @"Non Default Browser")];
    [alert setInformativeText:NSLocalizedString(@"No Default Browser Information", @"No Default Browser Information")];
    [alert addButtonWithTitle:NSLocalizedString(@"Set As Default", @"Set As Default")];
    NSButton *cancelButton = [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel")];
    [cancelButton setKeyEquivalent:@"\e"];
    
    [self activate];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [[Browsers sharedInstance] setOurselvesAsDefaultBrowser];
    }
    
    if ([[alert suppressionButton] state] == NSControlStateValueOn) {
        NSLog(@"Suppress");
        [defaults setBool:YES forKey:PrefAreWeDefault];
    }
}

#pragma mark - URL & File Handlers

// Receives both http(s) links and HTML files opened with Objektiv.
- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls
{
    NSURL *browserURL = [[Browsers sharedInstance] targetBrowserURL];
    if (!browserURL)
    {
        NSLog(@"No browser available to open %@", urls);
        return;
    }

    NSWorkspaceOpenConfiguration *configuration = [NSWorkspaceOpenConfiguration configuration];
    [sharedWorkspace openURLs:urls
         withApplicationAtURL:browserURL
                configuration:configuration
            completionHandler:^(NSRunningApplication *app, NSError *error) {
        if (error) NSLog(@"Opening %@ in %@ failed: %@", urls, browserURL, error);
    }];
}

@end
