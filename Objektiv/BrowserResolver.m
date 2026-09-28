//
//  BrowserResolver.m
//  Objektiv
//

#import "BrowserResolver.h"

@implementation BrowserResolver

+ (BOOL)identifier:(NSString *)identifier matchesAnyPattern:(NSArray<NSString *> *)patterns
{
    for (NSString *pattern in patterns) {
        if (pattern.length && [identifier rangeOfString:pattern options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}

+ (NSArray<NSString *> *)filterIdentifiers:(NSArray<NSString *> *)identifiers
                                 blacklist:(NSArray<NSString *> *)blacklist
                            ownIdentifier:(NSString *)ownIdentifier
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:identifiers.count];
    NSMutableSet *seen = [NSMutableSet set];
    for (NSString *identifier in identifiers) {
        NSString *key = identifier.lowercaseString;
        if (!identifier.length || [seen containsObject:key]) continue;
        if ([identifier caseInsensitiveCompare:ownIdentifier] == NSOrderedSame) continue;
        if ([self identifier:identifier matchesAnyPattern:blacklist]) continue;
        [seen addObject:key];
        [result addObject:identifier];
    }
    return result;
}

+ (NSString *)targetForSelected:(NSString *)selected
                      installed:(NSArray<NSString *> *)installed
                  ownIdentifier:(NSString *)ownIdentifier
{
    NSString * (^find)(NSString *) = ^NSString *(NSString *wanted) {
        if (!wanted.length || [wanted caseInsensitiveCompare:ownIdentifier] == NSOrderedSame) return nil;
        for (NSString *identifier in installed) {
            if ([identifier caseInsensitiveCompare:wanted] == NSOrderedSame) return identifier;
        }
        return nil;
    };

    NSString *target = find(selected) ?: find(FallbackBrowserIdentifier);
    if (target) return target;

    for (NSString *identifier in installed) {
        if ([identifier caseInsensitiveCompare:ownIdentifier] != NSOrderedSame) return identifier;
    }
    return nil;
}

+ (NSString *)displayNameForApplicationAtURL:(NSURL *)url
{
    NSString *name = nil;
    [url getResourceValue:&name forKey:NSURLLocalizedNameKey error:NULL];
    if (!name.length) name = url.lastPathComponent;
    if ([name.pathExtension caseInsensitiveCompare:@"app"] == NSOrderedSame) name = name.stringByDeletingPathExtension;
    return name;
}

@end
