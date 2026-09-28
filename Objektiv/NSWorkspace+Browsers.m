//
//  NSWorkspace+Browsers.m
//  Objektiv
//

#import "NSWorkspace+Browsers.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@implementation NSWorkspace (ObjektivBrowsers)

- (NSArray<NSString *> *)installedBrowserIdentifiers
{
    NSMutableArray *identifiers = [NSMutableArray array];
    for (NSURL *appURL in [self URLsForApplicationsToOpenURL:[NSURL URLWithString:@"https://example.com"]]) {
        NSString *identifier = [NSBundle bundleWithURL:appURL].bundleIdentifier;
        if (identifier.length) [identifiers addObject:identifier];
    }

    NSString *defaultBrowser = [self systemDefaultBrowserIdentifier];
    if (defaultBrowser && ![identifiers containsObject:defaultBrowser]) [identifiers addObject:defaultBrowser];

    return identifiers;
}

- (NSString *)systemDefaultBrowserIdentifier
{
    NSURL *appURL = [self URLForApplicationToOpenURL:[NSURL URLWithString:@"http://example.com"]];
    return appURL ? [NSBundle bundleWithURL:appURL].bundleIdentifier : nil;
}

- (void)setDefaultBrowserWithIdentifier:(NSString *)bundleIdentifier
                             completion:(void (^)(NSError *))completion
{
    NSURL *appURL = [self URLForApplicationWithBundleIdentifier:bundleIdentifier];
    void (^finish)(NSError *) = ^(NSError *error) {
        if (error) NSLog(@"Setting default browser to %@ failed: %@", bundleIdentifier, error);
        if (completion) dispatch_async(dispatch_get_main_queue(), ^{ completion(error); });
    };

    if (!appURL) {
        finish([NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil]);
        return;
    }

    // Chained so macOS only shows one confirmation prompt at a time.
    [self setDefaultApplicationAtURL:appURL toOpenURLsWithScheme:@"http" completionHandler:^(NSError *error) {
        if (error) { finish(error); return; }
        [[NSWorkspace sharedWorkspace] setDefaultApplicationAtURL:appURL toOpenURLsWithScheme:@"https" completionHandler:^(NSError *error) {
            if (error) { finish(error); return; }
            [[NSWorkspace sharedWorkspace] setDefaultApplicationAtURL:appURL toOpenContentType:UTTypeHTML completionHandler:^(NSError *error) {
                finish(error);
            }];
        }];
    }];
}

@end
