//
//  PrefsController.h
//  Objektiv
//
//  Created by Ankit Solanki on 22/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@import MASShortcut;


@interface PrefsController : NSWindowController

-(void) showPreferences;
-(void) refreshUI;

@property (weak) IBOutlet NSButton *startAtLogin;
@property (weak) IBOutlet NSButton *autoHideIcon;
@property (weak) IBOutlet NSButton *showNotifications;
@property (weak) IBOutlet MASShortcutView *hotkeyRecorder;


- (IBAction)toggleLoginItem: (id)sender;
- (IBAction)toggleHideItem: (id)sender;
- (IBAction)toggleShowNotifications: (id)sender;

@end
