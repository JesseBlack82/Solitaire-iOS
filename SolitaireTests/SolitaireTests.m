
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "STKBoard.h"
#import "STKGameEngine.h"
#import "STKCard.h"

@interface SolitaireTests : XCTestCase

@end

@interface SolitaireTests ()
@property(nonatomic, strong) STKBoard *board;
@property(nonatomic, strong) STKGameEngine *engine;
@end

@implementation SolitaireTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

    [self setBoard:[[STKBoard alloc] init]];
    [self setEngine:[[STKGameEngine alloc] initWithBoard:[self board]]];
    [[self engine] dealCards:[STKCard deck]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self setBoard:nil];
    [self setEngine:nil];

    [super tearDown];
}

- (void)testStockHas24CardsAfterSetup {
    XCTAssertEqual(24, [[[self engine] stock] count]);
}

- (void)testWasteHas0CardsAfterSetup {
    XCTAssertEqual(0, [[[self engine] waste] count]);
}

- (void)testFoundationsHave0CardsAfterSetup {
    for (NSArray *foundation in [[self board] foundations]) {
        XCTAssertEqual(0, [foundation count]);
    }
}

- (void)testStockTableausHaveAscendingCounts0toNAfterSetup //0-6
{
    NSUInteger expected = 0;
    for (NSArray *stockTableau in [[self board] stockTableaus]) {
        XCTAssertEqual(expected++, [stockTableau count]);
    }
}

- (void)testTableausHave1CardAfterSetup {
    for (NSArray *tableau in [[self board] tableaus]) {
        XCTAssertEqual(1, [tableau count]);
    }
}

- (void)testCanDrawStockToWasteWhenStockIsNonEmpty {
    XCTAssertTrue([[self engine] canDrawStockToWaste]);
}

- (void)testCanNotDrawStockToWasteWhenStockIsEmpty {
    while ([[[self engine] stock] count] > 0) {
        [STKBoard moveTopCard:[[self board] stock] toPile:[[self board] waste]];
    }

    XCTAssertFalse([[self engine] canDrawStockToWaste]);
}

- (void)testCanRedealWasteToStockWhenStockIsEmptyAndWasteIsNonEmpty {
    while ([[[self engine] stock] count] > 0) {
        [STKBoard moveTopCard:[[self board] stock] toPile:[[self board] waste]];
    }

    XCTAssertTrue([[self engine] canResetWasteToStock]);
}

- (void)testCanNotRedealWasteToStockWhenStockIsNonEmpty {
    // stock is already none empty, make sure to populate waste to make the next test more valuable
    [STKBoard moveTopCard:[[self board] stock] toPile:[[self board] waste]];

    XCTAssertFalse([[self engine] canResetWasteToStock]);
}

- (void)testCanNotRedealWasteToStockWhenWasteIsEmpty {
    [[[self board] stock] removeAllObjects];
    [[[self board] waste] removeAllObjects];

    XCTAssertFalse([[self engine] canResetWasteToStock]);
}

@end
