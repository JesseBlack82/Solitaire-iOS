#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "STKBoard.h"

@interface BoardTests : XCTestCase
@property (nonatomic, strong) STKBoard *board;
@property (nonatomic, strong) NSArray *allPiles;
@end

@implementation BoardTests

- (void)setUp {
    [super setUp];

    [self setBoard:[[STKBoard alloc] init]];
    [self setAllPiles:[[self board] allPiles]];
}

- (void)tearDown {
    [self setBoard:nil];
    [self setAllPiles:nil];

    [super tearDown];
}

- (void)testAllPilesCount {
    NSUInteger stockPileCount = 1;
    NSUInteger wastePileCount = 1;
    NSUInteger typesOfTableaus = 2;
    NSUInteger expected = [STKBoard numberOfTableaus] * typesOfTableaus + [STKBoard numberOfFoundations]
            + stockPileCount + wastePileCount;

    XCTAssertEqual(expected, [[[self board] allPiles] count]);
}

@end