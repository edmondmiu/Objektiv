//
//  OverlayWindowView.m
//  Objektiv
//
//  Created by Ankit Solanki on 19/12/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import "OverlayWindowView.h"
#import "BrowserItem.h"
#import "AppDelegate.h"
#import "ImageUtils.h"

@implementation OverlayWindowView {
    AppDelegate *appDelegate;
}

#pragma mark - constants

const NSUInteger ICON_SIZE = 84;
const NSUInteger TEXT_HEIGHT = 24;
const NSUInteger H_PADDING = 16;
const NSUInteger BOX_PADDING = 16;

#pragma mark - properties
@synthesize overlayFillColor = _overlayFillColor;
-(NSColor *)overlayFillColor
{
    if (!_overlayFillColor) {
        _overlayFillColor = [NSColor colorWithWhite:1 alpha:0.8];
    }
    return _overlayFillColor;
}

@synthesize overlayStrokeColor = _overlayStrokeColor;
-(NSColor *)overlayStrokeColor
{
    if (!_overlayStrokeColor) {
        _overlayStrokeColor = [self colorWithRed:0 green:0x66 blue:0xBB alpha:1];
    }
    return _overlayStrokeColor;
}

#pragma mark - NSView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        self.title = @"";
        self.titlePosition = NSNoTitle;
        [self setContentViewMargins:NSMakeSize(0, 0)];
        [self setBoxType:NSBoxCustom];
        [self setBorderWidth:0];
        [self setBorderColor:[NSColor clearColor]];
        [self setFillColor:[NSColor clearColor]];
        [self setAutoresizesSubviews:NO];
    }
    return self;
}

// Draws the semi-transparent background for the overlay panel
- (void)drawRect:(NSRect)dirtyRect
{
    dirtyRect = CGRectInset(dirtyRect, 0.5, 0.5);
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:16 yRadius:16];
    [self.overlayFillColor set];
    [path fill];

    [path setLineWidth:2];
    [self.overlayStrokeColor set];
    [path stroke];
}

# pragma mark - Actions
- (void) buttonClicked:sender
{
    NSButton *button = sender;

    [self.window orderOut:nil];
    [self.window close];

    [appDelegate selectABrowser: button.cell];
}

# pragma mark - Internals & Business Logic

// Adds buttons for browser icons in a 9-column wide grid.
// The first 9 will have hotkeys associated with them (numbers 1-9).
- (NSSize)addBrowsers:(NSArray*)browsers
{
    NSRect itemRect = NSMakeRect(BOX_PADDING, BOX_PADDING, ICON_SIZE + H_PADDING, ICON_SIZE + TEXT_HEIGHT);
    NSRect buttonRect = CGRectInset(itemRect, H_PADDING / 2, 0);
    NSUInteger width = itemRect.size.width, height = itemRect.size.height;

    NSUInteger maxRow = browsers.count / 9, maxColumn = browsers.count > 9 ? 9 : browsers.count;
    if((browsers.count % 9) == 0) maxRow--;
    NSUInteger row = maxRow, column = 0;
    for (int i = 0; i < browsers.count; i++) {
        BrowserItem *browser = browsers[i];

        NSRect offset = CGRectOffset(buttonRect, width * column, height * row);

        NSButton *button = [self buttonForBrowser:browser
                                       atPosition:i
                                        withFrame:offset];
        [self addSubview:button];

        column++;
        if (column >= 9 && row > 0) {
            row--;
            column = 0;
        }
    }

    NSSize size = NSMakeSize(width * maxColumn + BOX_PADDING * 2, height * (maxRow + 1) + BOX_PADDING * 2);
    return size;
}

-(NSButton*)buttonForBrowser:(BrowserItem*)browser atPosition:(NSUInteger)position withFrame:(NSRect)frame
{
    NSButton *button = [[NSButton alloc] initWithFrame:frame];

    button.image = [self imageForBrowser:browser withBadge:position + 1];
    button.keyEquivalent = [NSString stringWithFormat:@"%ld", position + 1];
    button.attributedTitle = [self titleForButton:browser.name inColor:self.overlayStrokeColor];
    button.target = self;
    button.action = @selector(buttonClicked:);

    NSButtonCell *cell = button.cell;
    cell.imagePosition = NSImageAbove;

    cell.focusRingType = NSFocusRingTypeNone;
    cell.backgroundColor = self.overlayFillColor;
    [cell setBezeled:NO];
    [cell setBordered:NO];
    [cell setTransparent:NO];
    [cell setSelectable:NO];
    [cell setButtonType:NSButtonTypeMomentaryPushIn];
    cell.showsStateBy = NSPushInCellMask;
    cell.highlightsBy = NSContentsCellMask;
    cell.representedObject = browser.identifier;

    return button;
}

-(NSImage*) imageForBrowser:(BrowserItem*)browser withBadge:(NSUInteger)position
{
    NSImage *icon = [ImageUtils fullSizeIconForAppId:browser.identifier
                                            withSize:NSMakeSize(ICON_SIZE, ICON_SIZE)];
    NSColor *strokeColor = self.overlayStrokeColor;
    NSImage *selectionImage = browser.isDefault
        ? [ImageUtils tintInputImage:[NSImage imageNamed:NSImageNameMenuOnStateTemplate] toColor:strokeColor]
        : nil;
    BOOL showBadge = position <= 9 && !browser.isDefault;
    NSString *badge = [NSString stringWithFormat:@"%ld", position];

    return [NSImage imageWithSize:icon.size flipped:NO drawingHandler:^BOOL(NSRect rect) {
        [icon drawInRect:rect];

        if (selectionImage)
        {
            [selectionImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect
                              operation:NSCompositingOperationSourceOver fraction:1];
        }

        if (showBadge)
        {
            NSRect badgeRect = NSMakeRect(0, 0, 20, 20);
            [strokeColor set];
            [[NSBezierPath bezierPathWithRoundedRect:badgeRect xRadius:4 yRadius:4] fill];
            [badge drawInRect:CGRectInset(badgeRect, 7, 2)
               withAttributes:@{NSForegroundColorAttributeName : [NSColor whiteColor]}];
        }
        return YES;
    }];
}


-(NSAttributedString*) titleForButton:(NSString*) plainTitle inColor:(NSColor*) color
{
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:plainTitle];

    NSRange range = NSMakeRange(0, title.length);

    NSFont *font = [NSFont labelFontOfSize:[NSFont labelFontSize] + 2];
    font = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSFontBoldTrait];
    
    [title addAttribute:NSForegroundColorAttributeName
                  value:color
                  range:range];
    [title addAttribute:NSFontAttributeName
                  value:font
                  range:range];
    [title setAlignment:NSTextAlignmentCenter range:range];
    [title fixAttributesInRange:range];

    return [self truncateString:title toWidth:ICON_SIZE];
}

#pragma mark - Utilities

- (NSAttributedString *)truncateString:(NSAttributedString*)attributedString toWidth:(NSUInteger)width
{
	NSAttributedString *result = attributedString;
	if (result.size.width > width)
	{
		NSMutableAttributedString *newString = [[NSMutableAttributedString alloc] initWithAttributedString:result];
		while ([newString size].width > width)
		{
			NSRange range = NSMakeRange(newString.length - 2, 2);
			[newString replaceCharactersInRange:range withString:@"…"];
		}
		result = newString;
	}
	return result;
}

- (NSColor*) colorWithRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha
{
    NSColorSpace *sRGB = [NSColorSpace sRGBColorSpace];
    CGFloat components[4] = { red/255.0f, green/255.0f, blue/255.0f, alpha };
    NSColor *color = [NSColor colorWithColorSpace:sRGB components:(CGFloat*)&components count:4];
    return color;
}
@end
