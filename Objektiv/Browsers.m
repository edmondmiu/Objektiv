//
//  Browsers.m
//  Objektiv
//
//  Created by Ankit Solanki on 19/01/13.
//  Copyright (c) 2013 nth loop. All rights reserved.
//

#import "Browsers.h"
#import "BrowserResolver.h"
#import "Constants.h"
#import "NSWorkspace+Browsers.h"

@implementation Browsers {
    NSArray *_browsers;

    // This internal blacklist of browsers is always hidden
    NSArray *internalBlacklist;
    NSString *ownIdentifier;
}

# pragma mark - initialization

+ (Browsers*)sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

-(id)init
{
    self = [super init];
    if (self) {
        internalBlacklist = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle]
                                                    pathForResource:@"Blacklist"
                                                             ofType:@"plist"]];
        ownIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    }
    return self;
}

# pragma mark - static properties

+ (NSArray*) browsers
{
    return [[Browsers sharedInstance] browsers];
}

+ (NSArray*) validBrowsers
{
    return [[Browsers sharedInstance] validBrowsers];
}

# pragma mark - instance properties

- (NSArray*) browsers
{
    if (![_browsers count]) { [self findBrowsers]; }
    return _browsers;
}

- (NSArray*) validBrowsers
{
    return [self.browsers filteredArrayUsingPredicate:
            [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        BrowserItem *item = evaluatedObject;
        return !item.hidden;
    }]];
}

- (NSString*) defaultBrowserIdentifier
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:PrefSelectedBrowser];
}

- (NSString*) systemDefaultBrowser
{
    return [[NSWorkspace sharedWorkspace] systemDefaultBrowserIdentifier];
}

- (void) setDefaultBrowserIdentifier:(NSString *)defaultBrowserIdentifier
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:defaultBrowserIdentifier forKey:PrefSelectedBrowser];
}

- (NSURL*) targetBrowserURL
{
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSString *target = [BrowserResolver targetForSelected:self.defaultBrowserIdentifier
                                                installed:[workspace installedBrowserIdentifiers]
                                            ownIdentifier:ownIdentifier];
    return target ? [workspace URLForApplicationWithBundleIdentifier:target] : nil;
}

- (void) setOurselvesAsDefaultBrowser
{
    [[NSWorkspace sharedWorkspace] setDefaultBrowserWithIdentifier:ownIdentifier completion:nil];
}

# pragma mark - Public methods

- (void) findBrowsersAsync
{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSArray *found = [self scanBrowsers];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_browsers = found;
        });
    });
}

- (void) findBrowsers
{
    _browsers = [self scanBrowsers];
}

- (BOOL) isHidden:(NSString*) browserIdentifier
{
    if (!browserIdentifier) return NO;

    NSArray *prefsHidden = [[NSUserDefaults standardUserDefaults] arrayForKey:PrefBlacklist];
    return [BrowserResolver identifier:browserIdentifier matchesAnyPattern:prefsHidden];
}

- (void) hideABrowser:sender
{
    NSString *identifier = [sender representedObject];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *prefsHidden = [[defaults arrayForKey:PrefBlacklist] mutableCopy] ?: [NSMutableArray array];
    [prefsHidden addObject:identifier];
    [defaults setObject:prefsHidden forKey:PrefBlacklist];

    [self findBrowsersAsync];
}

- (void) unhideABrowser:sender
{
    NSString *identifier = [sender representedObject];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *prefsHidden = [[defaults arrayForKey:PrefBlacklist] mutableCopy];

    NSIndexSet *matches = [prefsHidden indexesOfObjectsPassingTest:^BOOL(id hiddenIdentifer, NSUInteger idx, BOOL *stop) {
        return [BrowserResolver identifier:identifier matchesAnyPattern:@[hiddenIdentifer]];
    }];

    if (!matches.count) { return; }

    [prefsHidden removeObjectsAtIndexes:matches];
    [defaults setObject:prefsHidden forKey:PrefBlacklist];

    [self findBrowsersAsync];
}

#pragma mark - internal methods

- (NSArray*) scanBrowsers
{
    NSLog(@"Find browsers");
    NSWorkspace *sharedWorkspace = [NSWorkspace sharedWorkspace];
    NSArray *identifiers = [BrowserResolver filterIdentifiers:[sharedWorkspace installedBrowserIdentifiers]
                                                    blacklist:internalBlacklist
                                               ownIdentifier:ownIdentifier];

    NSString *defaultBrowser = [self defaultBrowserIdentifier];
    NSMutableArray *allBrowsers = [[NSMutableArray alloc] initWithCapacity:identifiers.count];

    for (NSString *browser in identifiers) {
        NSURL *browserURL = [sharedWorkspace URLForApplicationWithBundleIdentifier:browser];
        if (!browserURL) {
            NSLog(@"Can't find path of browser: %@", browser);
            continue;
        }

        NSString *browserName = [BrowserResolver displayNameForApplicationAtURL:browserURL];

        BrowserItem *item = [[BrowserItem alloc] initWithApplicationId:browser name:browserName path:browserURL.path];
        item.hidden = [self isHidden:browser];
        item.isDefault = defaultBrowser && [browser caseInsensitiveCompare:defaultBrowser] == NSOrderedSame;
        [allBrowsers addObject:item];
    }

    return [allBrowsers sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                   ascending:YES
                                                                                    selector:@selector(localizedCaseInsensitiveCompare:)]]];
}

@end
