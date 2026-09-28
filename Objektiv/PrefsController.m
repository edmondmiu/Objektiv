//
//  PrefsController.m
//  Objektiv
//
//  Created by Ankit Solanki on 22/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import "PrefsController.h"
#import "Constants.h"
#import "LoginItem.h"

@interface PrefsController ()
{
    @private
    NSUserDefaults *defaults;
}
@end

@implementation PrefsController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        defaults = [NSUserDefaults standardUserDefaults];
    }

    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.hotkeyRecorder.associatedUserDefaultsKey = PrefHotkey;
    [self refreshUI];
}

#pragma mark - UI methods

- (void) showPreferences
{
    [self refreshUI];
    [self.window makeKeyAndOrderFront:NSApp];
    if (@available(macOS 14.0, *)) {
        [NSApp activate];
    } else {
        [NSApp activateIgnoringOtherApps:YES];
    }
}

- (void) refreshUI
{
    if (!self.isWindowLoaded) return;
    self.autoHideIcon.state = [defaults boolForKey:PrefAutoHideIcon] ? NSControlStateValueOn : NSControlStateValueOff;
    self.startAtLogin.state = [LoginItem isEnabled] ? NSControlStateValueOn : NSControlStateValueOff;
    self.showNotifications.state = [defaults boolForKey:PrefShowNotifications] ? NSControlStateValueOn : NSControlStateValueOff;
}

#pragma mark - IBActions

- (IBAction)toggleLoginItem: (id)sender
{
    NSLog(@"PrefsController :: toggleLoginItem");
    [defaults setBool:(self.startAtLogin.state == NSControlStateValueOn) forKey:PrefStartAtLogin];
}

- (IBAction)toggleHideItem: (id)sender
{
    NSLog(@"PrefsController :: toggleHideItem");
    [defaults setBool:(self.autoHideIcon.state == NSControlStateValueOn) forKey:PrefAutoHideIcon];
}

- (IBAction)toggleShowNotifications: (id)sender
{
    NSLog(@"PrefsController :: showNotifications");
    [defaults setBool:(self.showNotifications.state == NSControlStateValueOn) forKey:PrefShowNotifications];
}

@end
