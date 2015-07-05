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

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

    [self setBoard:[[STKBoard alloc] init]];
    [self setEngine:[[STKGameEngine alloc] initWithBoard:[self board]]];
    [[self engine] dealCards:[STKCard deck]];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self setBoard:nil];
    [self setEngine:nil];

    [super tearDown];
}

- (void)testStockHas24CardsAfterSetup
{
    XCTAssertEqual(24, [[[self engine] stock] count]);
}

- (void)testWasteHas0CardsAfterSetup
{
    XCTAssertEqual(0, [[[self engine] waste] count]);
}

- (void)testFoundationsHave0CardsAfterSetup
{
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

- (void)testTableausHave1CardAfterSetup
{
    for (NSArray *tableau in [[self board] tableaus]) {
        XCTAssertEqual(1, [tableau count]);
    }
}

- (void)testCanDrawStockToWasteWhenStockIsNonEmpty
{
    XCTAssertTrue([[self engine] canDrawStockToWaste]);
}

- (void)testCanNotDrawStockToWasteWhenStockIsEmpty
{
    while ([[[self engine] stock] count] > 0) {
        [STKBoard moveTopCard:[[self board] stock] toPile:[[self board] waste]];
    }

    XCTAssertFalse([[self engine] canDrawStockToWaste]);
}

- (void)testCanRedealWasteToStockWhenStockIsEmptyAndWasteIsNonEmpty
{
    while ([[[self engine] stock] count] > 0) {
        [STKBoard moveTopCard:[[self board] stock] toPile:[[self board] waste]];
    }

    XCTAssertTrue([[self engine] canResetWasteToStock]);
}

- (void)testCanNotRedealWasteToStockWhenStockIsNonEmpty
{
    // stock is already none empty, make sure to populate waste to make the next test more valuable
    [STKBoard moveTopCard:[[self board] stock] toPile:[[self board] waste]];

    XCTAssertFalse([[self engine] canResetWasteToStock]);
}

- (void)testCanNotRedealWasteToStockWhenWasteIsEmpty
{
    [[[self board] stock] removeAllObjects];
    [[[self board] waste] removeAllObjects];

    XCTAssertFalse([[self engine] canResetWasteToStock]);
}

- (void)testCanGrabTopWasteCard
{
    [STKBoard moveTopCard:[[self board] stock] toPile:[[self board] waste]];

    STKCard *topWasteCard = [[[self engine] waste] lastObject];
    XCTAssertTrue([[self engine] canGrab:topWasteCard]);
}

- (void)testCanNotGrabCoveredWasteCard
{
    while ([[[self engine] stock] count]) {
        [STKBoard moveTopCard:[[self board] stock] toPile:[[self board] waste]];
    }

    for (STKCard *card in [[self engine] waste]) {
        if (card != [[[self engine] waste] lastObject]) {
            XCTAssertFalse([[self engine] canGrab:card]);
        }
    }
}

- (void)testCanGrabTopFoundationCards
{
    for (NSMutableArray *foundation in [[self board] foundations]) {
        [STKBoard moveTopCard:[[self board] stock] toPile:foundation];

        XCTAssertTrue([[self engine] canGrab:[foundation lastObject]]);
    }
}

- (void)testCanNotGrabCoveredFoundationCards
{
    while ([[[self engine] stock] count] > 0) {
        for (NSMutableArray *foundation in [[self board] foundations]) {
            [STKBoard moveTopCard:[[self board] stock] toPile:foundation];
        }
    }

    for (NSArray *foundation in [[self engine] foundations]) {
        for (int i = 1; i < [foundation count]; ++i) {
            XCTAssertFalse([[self engine] canGrab:[foundation objectAtIndex:0]]);
        }
    }
}

- (void)testCanGrabTopTableauCards
{
    while ([[[self engine] stock] count] > 0) {
        for (NSMutableArray *tableau in [[self board] tableaus]) {
            [STKBoard moveTopCard:[[self board] stock] toPile:tableau];
        }
    }

    for (NSArray *tableau in [[self engine] tableaus]) {
        XCTAssertTrue([[self engine] canGrab:[tableau lastObject]]);
    }
}

- (void)testCanGrabCoveredCardsFromTableau // from covered card all the way to top
{
    while ([[[self engine] stock] count] > 0) {
        for (NSMutableArray *tableau in [[self board] tableaus]) {
            [STKBoard moveTopCard:[[self board] stock] toPile:tableau];
        }
    }

    for (NSArray *tableau in [[self engine] tableaus]) {
        for (STKCard *card in tableau) {
            if (card == [tableau lastObject]) {
                return;
            }
            XCTAssertTrue([[self engine] canGrab:[tableau lastObject]]);
        }
    }
}

@end
