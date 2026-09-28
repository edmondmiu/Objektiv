//
//  BrowserResolverTests.m
//  ObjektivTests
//

#import <XCTest/XCTest.h>
#import "BrowserResolver.h"

static NSString *const Own = @"com.nthloop.Objektiv";

@interface BrowserResolverTests : XCTestCase
@end

@implementation BrowserResolverTests

- (void)testPatternMatchIsCaseInsensitiveSubstring
{
    XCTAssertTrue([BrowserResolver identifier:@"com.nthloop.Objektiv" matchesAnyPattern:@[@"com.nthloop.objektiv"]]);
    XCTAssertTrue([BrowserResolver identifier:@"com.googlecode.iterm2" matchesAnyPattern:@[@"com.googlecode.iterm"]]);
    XCTAssertFalse([BrowserResolver identifier:@"com.google.Chrome" matchesAnyPattern:@[@"com.evernote"]]);
    XCTAssertFalse([BrowserResolver identifier:@"com.google.Chrome" matchesAnyPattern:@[@""]]);
    XCTAssertFalse([BrowserResolver identifier:@"com.google.Chrome" matchesAnyPattern:nil]);
}

- (void)testFilterDropsOwnBlacklistedAndDuplicates
{
    NSArray *input = @[@"com.apple.Safari", @"com.nthloop.objektiv", @"com.evernote.Evernote",
                       @"com.google.Chrome", @"com.apple.safari"];
    NSArray *result = [BrowserResolver filterIdentifiers:input blacklist:@[@"com.evernote"] ownIdentifier:Own];
    XCTAssertEqualObjects(result, (@[@"com.apple.Safari", @"com.google.Chrome"]));
}

- (void)testTargetPrefersInstalledSelection
{
    NSArray *installed = @[@"com.apple.Safari", @"com.google.Chrome"];
    XCTAssertEqualObjects([BrowserResolver targetForSelected:@"com.google.chrome" installed:installed ownIdentifier:Own],
                          @"com.google.Chrome");
}

- (void)testTargetFallsBackWhenSelectionMissingOrSelf
{
    NSArray *installed = @[@"com.google.Chrome", @"com.apple.Safari"];
    XCTAssertEqualObjects([BrowserResolver targetForSelected:@"org.mozilla.firefox" installed:installed ownIdentifier:Own],
                          @"com.apple.Safari");
    XCTAssertEqualObjects([BrowserResolver targetForSelected:Own installed:installed ownIdentifier:Own],
                          @"com.apple.Safari");
    XCTAssertEqualObjects([BrowserResolver targetForSelected:nil installed:installed ownIdentifier:Own],
                          @"com.apple.Safari");
}

- (void)testTargetNeverReturnsSelf
{
    NSArray *installed = @[Own, @"com.google.Chrome"];
    XCTAssertEqualObjects([BrowserResolver targetForSelected:nil installed:installed ownIdentifier:Own],
                          @"com.google.Chrome");
    NSArray *onlySelf = @[Own];
    XCTAssertNil([BrowserResolver targetForSelected:nil installed:onlySelf ownIdentifier:Own]);
}

@end
