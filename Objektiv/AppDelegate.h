//
//  AppDelegate.h
//  Objektiv
//
//  Created by Ankit Solanki on 01/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <UserNotifications/UserNotifications.h>
#import "PrefsController.h"


@interface AppDelegate : NSObject <NSApplicationDelegate, UNUserNotificationCenterDelegate>

- (void) hotkeyTriggered;
- (void) selectABrowser:sender;
- (void) updateStatusBarIcon;
- (void) showAbout;
- (void) doQuit;

@property PrefsController* prefsController;

@end
