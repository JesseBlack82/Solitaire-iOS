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

- (void)testTableauPileIDs {
    // tableau are the first n even pileIDs
    STKPileID expectedPileID = 0;
    for (NSMutableArray *tableau in [[self board] tableaus]) {
        XCTAssertEqual(expectedPileID, [[self board] pileIDForPile:tableau]);

        expectedPileID += 2;
    }
}

- (void)testStockTableauPileIDs {
    // stock tableaus are the first n odd pileIDs
    STKPileID expectedPileID = 1;
    for (NSMutableArray *stockTableau in [[self board] stockTableaus]) {
        XCTAssertEqual(expectedPileID, [[self board] pileIDForPile:stockTableau]);

        expectedPileID += 2;
    }
}

- (void)testFoundationPileIDs {
    // foundations are after the stockTableau and tableau piles
    STKPileID expectedPileID = [STKBoard numberOfTableaus]*2;
    for (NSMutableArray *foundation in [[self board] foundations]) {
        XCTAssertEqual(expectedPileID, [[self board] pileIDForPile:foundation]);

        ++expectedPileID;
    }
}

- (void)testStockPileIDs {
    // stock is second to last
    STKPileID expectedPileID = [[[self board] allPiles] count] - 2;
    XCTAssertEqual(expectedPileID, [[self board] pileIDForPile:[[self board] stock]]);
}

- (void)testAllPilesContainsNoDuplicates {
    for (int index; index < [[[self board] allPiles] count]; ++index) {
        NSArray *pile = [[self board] getPile:index];
        for (int seek = 0; seek < [[[self board] allPiles] count]; ++seek) {
            if (seek != index) {
                NSArray *potentialMatch = [[self board] getPile:seek];
                XCTAssertFalse(potentialMatch == pile);
            }
        }
    }
}

- (void)testStockTableausAndFoundationAreDistinctPiles {
    NSCountedSet *countedSet = [NSCountedSet setWithArray:[[self board] stockTableaus]];
    [countedSet addObjectsFromArray:[[self board] foundations]];

    NSUInteger expected = [STKBoard numberOfTableaus] + [STKBoard numberOfFoundations];
    for (id object in [countedSet objectEnumerator]) {
        XCTAssertEqual(expected, [countedSet countForObject:object]);
    }
}
@end