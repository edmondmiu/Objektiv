//
//  LoginItem.m
//  Objektiv
//

#import "LoginItem.h"
#import <ServiceManagement/ServiceManagement.h>

@implementation LoginItem

+ (BOOL)isEnabled
{
    SMAppServiceStatus status = SMAppService.mainAppService.status;
    return status == SMAppServiceStatusEnabled || status == SMAppServiceStatusRequiresApproval;
}

+ (BOOL)requiresApproval
{
    return SMAppService.mainAppService.status == SMAppServiceStatusRequiresApproval;
}

+ (BOOL)setEnabled:(BOOL)enabled
{
    if (enabled == [self isEnabled]) return YES;

    NSError *error = nil;
    BOOL ok = enabled
        ? [SMAppService.mainAppService registerAndReturnError:&error]
        : [SMAppService.mainAppService unregisterAndReturnError:&error];
    if (!ok) NSLog(@"%@ login item failed: %@", enabled ? @"Registering" : @"Unregistering", error);
    return ok;
}

+ (void)openSystemSettings
{
    [SMAppService openSystemSettingsLoginItems];
}

@end
