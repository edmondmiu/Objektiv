//
//  NSWorkspace+Browsers.h
//  Objektiv
//
//  Launch Services queries for web browsers, using the NSWorkspace APIs
//  that replaced the LSCopy*/LSSet* functions deprecated in macOS 10.15.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSWorkspace (ObjektivBrowsers)

// Bundle identifiers of every app that can open https links (unsorted, may contain duplicates).
- (NSArray<NSString *> *)installedBrowserIdentifiers;

// Bundle identifier of the app macOS currently opens http links with.
- (nullable NSString *)systemDefaultBrowserIdentifier;

// Makes the given app the system default for http, https and HTML files.
// macOS asks the user to confirm the change.
- (void)setDefaultBrowserWithIdentifier:(NSString *)bundleIdentifier
                             completion:(nullable void (^)(NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
