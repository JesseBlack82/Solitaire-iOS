#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "STKBoard.h"
#import "STKGameEngine.h"
#import "STKCard.h"
#import "STKMove.h"

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
    [self setEngine:[[STKGameEngine alloc] initWithBoard:[self board]
                                               drawCount:[STKGameEngine defaultDrawCount]]];
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

- (void)testGrabbingTopWasteCard {
    [STKBoard moveTopCard:[[self board] stock] toPile:[[self board] waste]];

    STKCard *topWasteCard = [[[self engine] waste] lastObject];
    STKMove *move = [[self engine] grabPileFromCard:topWasteCard];

    XCTAssertEqual([[move cards] firstObject], topWasteCard);
    XCTAssertEqual([[move cards] count], 1);
    XCTAssertFalse([[[self engine] waste] containsObject:topWasteCard]);

    STKPileID expectedPileID = [[self board] pileIDForCard:topWasteCard];
    XCTAssertEqual(expectedPileID, [move sourcePileID]);
}

- (void)testGrabbingTopFoundationCard
{
    for (NSMutableArray *foundation in [[self board] foundations]) {
        [STKBoard moveTopCard:[[self board] stock] toPile:foundation];
    }

    for (NSUInteger i = 0; i < [[[self engine] foundations] count]; ++i) {
        NSArray *foundation = [[self engine] foundationAtIndex:i];
        STKCard *topFoundationCard = [foundation lastObject];
        STKMove *move = [[self engine] grabPileFromCard:topFoundationCard];

        XCTAssertEqual([[move cards] firstObject], topFoundationCard);
        XCTAssertEqual([[move cards] count], 1);
        XCTAssertFalse([[[self engine] foundationAtIndex:i] containsObject:topFoundationCard]);

        STKPileID expectedPileID = [[self board] pileIDForCard:topFoundationCard];
        XCTAssertEqual(expectedPileID, [move sourcePileID]);
    }
}

- (void)testGrabbingTopTableauCard {
    for (NSMutableArray *tableau in [[self board] tableaus]) {
        [STKBoard moveTopCard:[[self board] stock] toPile:tableau];
    }

    for (NSUInteger i = 0; i < [[[self engine] tableaus] count]; ++i) {
        NSArray *tableau = [[self engine] tableauAtIndex:i];
        STKCard *topTableauCard = [tableau lastObject];
        STKMove *move = [[self engine] grabPileFromCard:topTableauCard];

        XCTAssertEqual([[move cards] firstObject], topTableauCard);
        XCTAssertEqual([[move cards] count], 1);
        XCTAssertFalse([[[self engine] tableauAtIndex:i] containsObject:topTableauCard]);

        STKPileID expectedPileID = [[self board] pileIDForCard:topTableauCard];
        XCTAssertEqual(expectedPileID, [move sourcePileID]);
    }
}

- (void)testGrabbingTopTableauCards {
    for (NSMutableArray *tableau in [[self board] tableaus]) {
        [STKBoard moveTopCard:[[self board] stock] toPile:tableau];
    }

    for (NSArray *tableau in [[self engine] tableaus]) {
        NSUInteger expectedGrabbedCardsCount = [tableau count] - 1;
        NSUInteger tableauIndex = [[[self engine] tableaus] indexOfObject:tableau];
        STKPileID expectedPileID = [[self board] pileIDForPile:[[self board] tableauAtIndex:tableauIndex]];

        for (STKCard *card in tableau) {
            if (card == [tableau lastObject]) {
                break;
            }

            STKMove *move = [[self engine] grabPileFromCard:card];

            XCTAssertEqual([[move cards] firstObject], card);
            XCTAssertEqual([[move cards] count], expectedGrabbedCardsCount--);
            XCTAssertFalse([tableau containsObject:tableau]);
            XCTAssertEqual(expectedPileID, [move sourcePileID]);
        }
    }
}

- (void)testDrawingStockToWaste {
    NSUInteger expectedLength = [[self engine] drawCount];
    NSArray *expectedWaste = [[[self engine] stock] subarrayWithRange:NSMakeRange([[[self engine] stock] count] - expectedLength, expectedLength)];
    NSEnumerator *expectedWasteEnumerator = [expectedWaste reverseObjectEnumerator];

    [[self engine] drawStockToWaste];

    NSUInteger wasteIndex = [[[self engine] waste] count] - expectedLength;
    for (STKCard *card in expectedWasteEnumerator) {

        XCTAssertEqual(card, [[[self engine] waste] objectAtIndex:wasteIndex++]);
        XCTAssertFalse([[[self engine] stock] containsObject:card]);
    }
}

- (void)testDrawingLessThanDrawCountFromStockToWaste {
    //default draw count = 3
    NSUInteger initialStockCount = [[[self engine] stock] count];
    NSUInteger expectedLength = [[self engine] drawCount] - 1;
    NSUInteger amountToMove = initialStockCount - expectedLength;

    for (NSUInteger i = 0; i < amountToMove; ++i) {
        [STKBoard moveTopCard:[[self board] stock] toPile:[[self board] waste]];
    }

    NSArray *expectedWaste = [[[self engine] stock] subarrayWithRange:NSMakeRange([[[self engine] stock] count] - expectedLength, expectedLength)];
    NSEnumerator *expectedWasteEnumerator = [expectedWaste reverseObjectEnumerator];

    [[self engine] drawStockToWaste];

    NSUInteger wasteIndex = [[[self engine] waste] count] - expectedLength;
    for (STKCard *card in expectedWasteEnumerator) {
        XCTAssertEqual(card, [[[self engine] waste] objectAtIndex:wasteIndex++]);
        XCTAssertFalse([[[self engine] stock] containsObject:card]);
    }
}

- (void)testRedealWasteToStock {
    while ([[[self engine] stock] count]) {
        [[self engine] drawStockToWaste];
    }

    NSEnumerator *expectedStock = [[[self engine] waste] reverseObjectEnumerator];

    [[self engine] resetWasteToStock];

    NSUInteger stockIndex = 0;
    for (STKCard *card in expectedStock) {
        XCTAssertEqual(card, [[[self engine] stock] objectAtIndex:stockIndex++]);
        XCTAssertFalse([[[self engine] waste] containsObject:card]);
    }
}

- (void)testCanFlipStockTableauWhenTableauIsEmptyAndStockTableauIsNotEmpty
{
    // first tableau stock is always empty
    NSMutableArray *tableau = [[self board] tableauAtIndex:1];
    [tableau removeAllObjects];

    XCTAssertTrue([[self engine] canFlipStockTableauAtIndex:1]);
}

- (void)testCanNotFlipStockTableauWhenStockTableauIsEmpty {
    // first tableau stock is always empty
    XCTAssertFalse([[self engine] canFlipStockTableauAtIndex:0]);
}

- (void)testCanNotFlipStockTableauWhenTableauIsNotEmpty {
    XCTAssertFalse([[self engine] canFlipStockTableauAtIndex:1]);
}

- (void)testPatienceEngineCanValidateWinningConditions
{
    [self setBoard:[[STKBoard alloc] init]];
    [self setEngine:[[STKGameEngine alloc] initWithBoard:[self board]]];

    //set up winning board

    for (NSUInteger i = 0; i < [[[self board] foundations] count]; ++i) {
        NSMutableArray *foundation = [[self board] foundationAtIndex:i];
        STKCardSuit suit = [[[STKCard allSuits] objectAtIndex:i] intValue];
        [foundation addObjectsFromArray:[STKCard completeAscendingSuit:suit]];
    }

    for (NSUInteger i = 0; i < [STKBoard numberOfTableaus]; ++i) {
        [[[self board] tableauAtIndex:i] removeAllObjects];
        [[[self board] stockTableauAtIndex:i] removeAllObjects];
    }

    [[[self board] waste] removeAllObjects];
    [[[self board] stock] removeAllObjects];

    XCTAssertTrue([[self engine] areWinningConditionsSatisfied]);
}

- (void)testCanMoveValidCardsToNonEmptyTableau {
    NSMutableArray *tableau = [[[self board] tableaus] firstObject];
    [tableau removeAllObjects];
    [tableau addObject:[STKCard cardWithRank:STKCardRankFive suit:STKCardSuitSpades]];

    STKPileID tableauID = [[self board] pileIDForPile:tableau];

    NSArray *validCards = @[
            [STKCard cardWithRank:STKCardRankFour suit:STKCardSuitHearts],
            [STKCard cardWithRank:STKCardRankThree suit:STKCardSuitClubs]
    ];

    STKMove *validMove = [[STKMove alloc] initWithCards:validCards sourcePileID:kNilOptions];

    XCTAssertTrue([[self engine] canCompleteMove:validMove withTargetPileID:tableauID]);
}

- (void)testCanNotMoveInvalidCardsToNonEmptyTableau {
    NSMutableArray *tableau = [[[self board] tableaus] firstObject];
    [tableau addObject:[STKCard cardWithRank:STKCardRankFive suit:STKCardSuitSpades]];

    STKPileID tableauID = [[self board] pileIDForPile:tableau];

    NSArray *invalidCards = @[
            [STKCard cardWithRank:STKCardRankFive suit:STKCardSuitHearts],
            [STKCard cardWithRank:STKCardRankThree suit:STKCardSuitClubs]
    ];

    STKMove *invalidMove = [[STKMove alloc] initWithCards:invalidCards sourcePileID:-1];
    XCTAssertFalse([[self engine] canCompleteMove:invalidMove withTargetPileID:tableauID]);
}

- (void)testCanMoveKingWhenTableauAndStockTableauAreEmpty {
    NSMutableArray *stockTableau = [[[self board] stockTableaus] firstObject];
    NSMutableArray *tableau = [[[self board] tableaus] firstObject];
    [stockTableau removeAllObjects];
    [tableau removeAllObjects];

    STKPileID tableauID = [[self board] pileIDForPile:tableau];

    NSArray *cards = @[
            [STKCard cardWithRank:STKCardRankKing suit:STKCardSuitClubs]
    ];

    STKMove *validMove = [[STKMove alloc] initWithCards:cards sourcePileID:-1];
    XCTAssertTrue([[self engine] canCompleteMove:validMove withTargetPileID:tableauID]);
}

@end
