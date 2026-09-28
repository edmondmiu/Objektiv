//
//  LoginItem.h
//  Objektiv
//
//  Launch-at-login via SMAppService (macOS 13+), replacing the
//  LSSharedFileList login item API that macOS no longer honours.
//

#import <Foundation/Foundation.h>

@interface LoginItem : NSObject

// YES when registered, including when waiting for approval in System Settings.
+ (BOOL)isEnabled;
+ (BOOL)requiresApproval;
+ (BOOL)setEnabled:(BOOL)enabled;
+ (void)openSystemSettings;

@end
