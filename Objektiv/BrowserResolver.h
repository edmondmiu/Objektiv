//
//  BrowserResolver.h
//  Objektiv
//
//  Pure logic for filtering browser identifiers and picking the browser
//  a link should be forwarded to. Foundation only, so it is unit tested.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define FallbackBrowserIdentifier @"com.apple.Safari"

@interface BrowserResolver : NSObject

// Case-insensitive substring match, the same rule used by the blacklists.
+ (BOOL)identifier:(NSString *)identifier matchesAnyPattern:(nullable NSArray<NSString *> *)patterns;

// Drops blacklisted identifiers, our own identifier and case-insensitive duplicates.
+ (NSArray<NSString *> *)filterIdentifiers:(NSArray<NSString *> *)identifiers
                                 blacklist:(nullable NSArray<NSString *> *)blacklist
                            ownIdentifier:(NSString *)ownIdentifier;

// The browser to forward links to: the selected one if it is installed and
// isn't us, otherwise Safari, otherwise the first installed browser.
+ (nullable NSString *)targetForSelected:(nullable NSString *)selected
                               installed:(NSArray<NSString *> *)installed
                           ownIdentifier:(NSString *)ownIdentifier;

@end

NS_ASSUME_NONNULL_END
