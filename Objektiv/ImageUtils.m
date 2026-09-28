//
//  ImageUtils.m
//  Objektiv
//
//  Created by Ankit Solanki on 17/12/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//
// -------------------------------------------------
// This class uses a NSCache instance in order to cache icons
// of the installed browsers.
//

#import "ImageUtils.h"
#import "Constants.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@implementation ImageUtils
{
@private
    NSCache *cache;
}

# pragma mark initialization

+(ImageUtils*) sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init
{
    self = [super init];
    if (self) {
        cache = [[NSCache alloc] init];
    }
    return self;
}

# pragma mark static methods

+ (NSImage*) statusBarIconForAppId: (NSString*) applicationIdentifier
{
    return [[self sharedInstance] menuIconForAppId:applicationIdentifier];
}

+ (NSImage*) menuIconForAppId: (NSString*) applicationIdentifier
{
    return [[self sharedInstance] menuIconForAppId:applicationIdentifier];
}

+ (NSImage*) fullSizeIconForAppId: (NSString*) applicationIdentifier
{
    return [[[self sharedInstance] iconForAppIdentifier:applicationIdentifier] copy];
}

+ (NSImage*) fullSizeIconForAppId: (NSString*) applicationIdentifier withSize:(NSSize)size
{
    NSImage *image = [self fullSizeIconForAppId:applicationIdentifier];
    image.size = size;
    return image;
}

// Fill the opaque pixels of a template image with the output colour.
// Used to add the 'checkmark' on the selected browser's icon
+ (NSImage*) tintInputImage:(NSImage*)inputImage toColor:(NSColor*)outputColor
{
    return [NSImage imageWithSize:inputImage.size flipped:NO drawingHandler:^BOOL(NSRect rect) {
        [inputImage drawInRect:rect];
        [outputColor set];
        NSRectFillUsingOperation(rect, NSCompositingOperationSourceAtop);
        return YES;
    }];
}

# pragma mark instance methods

- (NSImage*) menuIconForAppId: (NSString*) applicationIdentifier
{
    NSString *key = [@"menu:" stringByAppendingString:applicationIdentifier ?: @""];
    NSImage *icon = [cache objectForKey:key];
    if (icon) return icon;

    icon = [[self iconForAppIdentifier:applicationIdentifier] copy];
    icon.size = NSMakeSize(StatusBarIconSize, StatusBarIconSize);
    [cache setObject:icon forKey:key];
    return icon;
}

# pragma mark internal utility methods

- (NSImage*) iconForAppIdentifier: (NSString*) applicationIdentifier
{
    NSString *key = applicationIdentifier ?: @"";
    NSImage *icon = [cache objectForKey:key];
    if (icon)
    {
        return icon;
    }
    
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSURL *url = applicationIdentifier ? [workspace URLForApplicationWithBundleIdentifier:applicationIdentifier] : nil;
    icon = url
        ? [workspace iconForFile:url.path]
        : [workspace iconForContentType:UTTypeApplicationBundle];
    icon = [icon copy];
    [cache setObject:icon forKey:key];

    return icon;
}

@end
