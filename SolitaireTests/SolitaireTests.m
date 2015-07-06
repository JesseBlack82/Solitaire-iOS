#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "STKBoard.h"
#import "STKGameEngine.h"
#import "STKCard.h"
#import "STKMove.h"

@interface SolitaireTests : XCTestCase
@property(nonatomic, strong) STKBoard *board;
@property(nonatomic, strong) STKGameEngine *engine;
@end

@implementation SolitaireTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

    [self setBoard:[[STKBoard alloc] init]];
    [self setEngine:[[STKGameEngine alloc] initWithBoard:[self board]
                                               drawCount:[STKGameEngine defaultDrawCount]]];
    [[self engine] dealCards:[STKCard deck]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self setBoard:nil];
    [self setEngine:nil];

    [super tearDown];
}

- (void)moveStockCardsToWaste {
    while ([[[self engine] stock] count] > 0) {
        [STKBoard moveTopCard:[[self board] stock] toPile:[[self board] waste]];
    }
}

- (void)clearStock {
    [[[[self board] stock] cards] removeAllObjects];
}

- (void)clearWaste {
    [[[[self board] waste] cards] removeAllObjects];
}

- (void)clearPlayableTableauAtIndex:(NSUInteger)index {
    [[[[self board] tableauAtIndex:index] cards] removeAllObjects];
}

- (void)testStockHas24CardsAfterSetup {
    XCTAssertEqual(24, [[[self engine] stock] count]);
}

- (void)testWasteHas0CardsAfterSetup {
    XCTAssertEqual(0, [[[self engine] waste] count]);
}

- (void)testFoundationsHave0CardsAfterSetup {
    for (STKFoundationPile *foundation in [[self board] foundations]) {
        XCTAssertFalse([foundation hasCards]);
    }
}

- (void)testStockTableausHaveAscendingCounts0toNAfterSetup //0-6
{
    NSUInteger expected = 0;
    for (STKStockTableauPile *stockTableau in [[self board] stockTableaus]) {
        XCTAssertEqual(expected++, [[stockTableau cards] count]);
    }
}

- (void)testTableausHave1CardAfterSetup {
    for (STKPlayableTableauPile *tableau in [[self board] playableTableaus]) {
        XCTAssertEqual(1, [[tableau cards] count]);
    }
}

- (void)testCanDrawStockToWasteWhenStockIsNonEmpty {
    XCTAssertTrue([[self engine] canDrawStockToWaste]);
}

- (void)testCanNotDrawStockToWasteWhenStockIsEmpty {
    [self moveStockCardsToWaste];

    XCTAssertFalse([[self engine] canDrawStockToWaste]);
}

- (void)testCanRedealWasteToStockWhenStockIsEmptyAndWasteIsNonEmpty {
    [self moveStockCardsToWaste];

    XCTAssertTrue([[self engine] canResetWasteToStock]);
}

- (void)testCanNotRedealWasteToStockWhenStockIsNonEmpty {
    // stock is already none empty, make sure to populate waste to make the next test more valuable
    [STKBoard moveTopCard:[[self board] stock] toPile:[[self board] waste]];

    XCTAssertFalse([[self engine] canResetWasteToStock]);
}

- (void)testCanNotRedealWasteToStockWhenWasteIsEmpty {
    [self clearStock];
    [self clearWaste];

    XCTAssertFalse([[self engine] canResetWasteToStock]);
}

- (void)testCanGrabTopWasteCard {
    [STKBoard moveTopCard:[[self board] stock] toPile:[[self board] waste]];

    STKCard *topWasteCard = [[[self engine] waste] lastObject];
    XCTAssertTrue([[self engine] canGrab:topWasteCard]);
}

- (void)testCanNotGrabCoveredWasteCard {
    [self moveStockCardsToWaste];

    for (STKCard *card in [[self engine] waste]) {
        if (card != [[[self engine] waste] lastObject]) {
            XCTAssertFalse([[self engine] canGrab:card]);
        }
    }
}

- (void)testCanGrabTopFoundationCards {
    for (STKPile *foundation in [[self board] foundations]) {
        [STKBoard moveTopCard:[[self board] stock] toPile:foundation];

        XCTAssertTrue([[self engine] canGrab:[[foundation cards] lastObject]]);
    }
}

- (void)testCanNotGrabCoveredFoundationCards {
    while ([[[self engine] stock] count] > 0) {
        for (STKFoundationPile *foundation in [[self board] foundations]) {
            [STKBoard moveTopCard:[[self board] stock] toPile:foundation];
        }
    }

    for (STKPile *foundationPile in [[self engine] foundations]) {
        for (int i = 0; i < [[foundationPile cards] count] - 1; ++i) {
            XCTAssertFalse([[self engine] canGrab:[foundationPile cards][i]]);
        }
    }
}

- (void)testCanGrabTopTableauCards {
    while ([[[self engine] stock] count] > 0) {
        for (STKPlayableTableauPile *tableau in [[self board] playableTableaus]) {
            [STKBoard moveTopCard:[[self board] stock] toPile:tableau];
        }
    }

    for (NSArray *tableau in [[self engine] playableTableaus]) {
        XCTAssertTrue([[self engine] canGrab:[tableau lastObject]]);
    }
}

- (void)testCanGrabCoveredCardsFromTableau // from covered card all the way to top
{
    while ([[[self engine] stock] count] > 0) {
        for (STKPlayableTableauPile *tableau in [[self board] playableTableaus]) {
            [STKBoard moveTopCard:[[self board] stock] toPile:tableau];
        }
    }

    for (NSArray *tableau in [[self engine] playableTableaus]) {
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
    STKPile *expectedPile = [[self board] pileContainingCard:topWasteCard];

    STKMove *move = [[self engine] grabTopCardsFromCard:topWasteCard];

    XCTAssertEqual([[move cards] firstObject], topWasteCard);
    XCTAssertEqual([[move cards] count], 1);
    XCTAssertFalse([[[self engine] waste] containsObject:topWasteCard]);
    XCTAssertEqual(expectedPile, [move sourcePile]);
}

- (void)testGrabbingTopFoundationCard {
    for (STKFoundationPile *foundation in [[self board] foundations]) {
        [STKBoard moveTopCard:[[self board] stock] toPile:foundation];
    }

    for (NSUInteger i = 0; i < [[[self engine] foundations] count]; ++i) {
        NSArray *foundation = [[self engine] foundationAtIndex:i];
        STKCard *topFoundationCard = [foundation lastObject];
        STKPile *expectedPile = [[self board] pileContainingCard:topFoundationCard];

        STKMove *move = [[self engine] grabTopCardsFromCard:topFoundationCard];

        XCTAssertEqual([[move cards] firstObject], topFoundationCard);
        XCTAssertEqual([[move cards] count], 1);
        XCTAssertFalse([[[self engine] foundationAtIndex:i] containsObject:topFoundationCard]);
        XCTAssertEqual(expectedPile, [move sourcePile]);
    }
}

- (void)testGrabbingTopTableauCard {
    for (STKPlayableTableauPile *tableau in [[self board] playableTableaus]) {
        [STKBoard moveTopCard:[[self board] stock] toPile:tableau];
    }

    for (NSUInteger i = 0; i < [[[self engine] playableTableaus] count]; ++i) {
        NSArray *tableau = [[self engine] tableauAtIndex:i];
        STKCard *topTableauCard = [tableau lastObject];
        STKPile *expectedSourcePile = [[self board] pileContainingCard:topTableauCard];

        STKMove *move = [[self engine] grabTopCardsFromCard:topTableauCard];

        XCTAssertEqual([[move cards] firstObject], topTableauCard);
        XCTAssertEqual([[move cards] count], 1);
        XCTAssertFalse([[[self engine] tableauAtIndex:i] containsObject:topTableauCard]);
        XCTAssertEqual(expectedSourcePile, [move sourcePile]);
    }
}

- (void)testGrabbingTopTableauCards {
    NSUInteger tableauIndex = 0;
    for (NSArray *tableau in [[self engine] playableTableaus]) {
        NSUInteger expectedGrabbedCardsCount = [tableau count] - 1;
        STKPile *expectedPile = [[self board] tableauAtIndex:tableauIndex++];

        for (STKCard *card in tableau) {
            if (card == [tableau lastObject]) {
                break;
            }

            STKMove *move = [[self engine] grabTopCardsFromCard:card];

            XCTAssertEqual([[move cards] firstObject], card);
            XCTAssertEqual([[move cards] count], expectedGrabbedCardsCount--);
            XCTAssertFalse([tableau containsObject:tableau]);
            XCTAssertEqual(expectedPile, [move sourcePile]);
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
        XCTAssertEqual(card, [[self engine] waste][wasteIndex++]);
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
        XCTAssertEqual(card, [[self engine] waste][wasteIndex++]);
        XCTAssertFalse([[[self engine] stock] containsObject:card]);
    }
}

- (void)testRedealWasteToStock {
    //redeal should put waste back to stock, in the back in the original stock order
    NSArray *expectedStock = [[self engine] waste];
    while ([[[self engine] stock] count]) {
        [[self engine] drawStockToWaste];
    }

    [[self engine] resetWasteToStock];

    NSUInteger stockIndex = 0;
    for (STKCard *card in expectedStock) {
        XCTAssertEqual(card, [[self engine] stock][stockIndex++]);
        XCTAssertFalse([[[self engine] waste] containsObject:card]);
    }
}

- (void)testCanFlipStockTableauWhenTableauIsEmptyAndStockTableauIsNotEmpty {
    // first tableau stock is always empty
    for (NSUInteger i = 1; i < [[[self engine] playableTableaus] count]; ++i) {
        [self clearPlayableTableauAtIndex:i];
        XCTAssertTrue([[self engine] canFlipStockTableauAtIndex:i]);
    }
}

- (void)testCanNotFlipStockTableauWhenStockTableauIsEmpty {
    // first tableau stock is always empty
    XCTAssertFalse([[self engine] canFlipStockTableauAtIndex:0]);
}

- (void)testCanNotFlipStockTableauWhenTableauIsNotEmpty {
    XCTAssertFalse([[self engine] canFlipStockTableauAtIndex:1]);
}

- (void)testPatienceEngineCanValidateSolvedBoard {
    //set up winning board starting with a clear board
    [self setBoard:[[STKBoard alloc] init]];
    [self setEngine:[[STKGameEngine alloc] initWithBoard:[self board]]];

    for (NSUInteger i = 0; i < [[[self board] foundations] count]; ++i) {
        STKFoundationPile *foundation = [[self board] foundationAtIndex:i];
        STKCardSuit suit = (STKCardSuit) [[STKCard allSuits][i] intValue];
        [[foundation cards] addObjectsFromArray:[STKCard completeAscendingSuit:suit]];
    }

    XCTAssertTrue([[self engine] isBoardSolved]);
}

- (void)testCanMoveValidCardsToNonEmptyTableau {
    STKPlayableTableauPile *tableau = [[[self board] playableTableaus] firstObject];
    [[tableau cards] removeAllObjects];
    [[tableau cards] addObject:[STKCard cardWithRank:STKCardRankFive suit:STKCardSuitSpades]];

    NSArray *validCards = @[[STKCard cardWithRank:STKCardRankFour suit:STKCardSuitHearts],
            [STKCard cardWithRank:STKCardRankThree suit:STKCardSuitClubs]];

    STKMove *validMove = [[STKMove alloc] initWithCards:validCards sourcePile:nil];
    XCTAssertTrue([[self engine] canCompleteMove:validMove withTargetPile:tableau]);
}

- (void)testCanNotMoveInvalidCardsToNonEmptyTableau {
    STKPlayableTableauPile *tableau = [[[self board] playableTableaus] firstObject];
    [[tableau cards] removeAllObjects];
    [[tableau cards] addObject:[STKCard cardWithRank:STKCardRankFive suit:STKCardSuitSpades]];

    NSArray *invalidCards = @[[STKCard cardWithRank:STKCardRankFive suit:STKCardSuitHearts],
            [STKCard cardWithRank:STKCardRankThree suit:STKCardSuitClubs]];

    STKMove *invalidMove = [[STKMove alloc] initWithCards:invalidCards sourcePile:nil];
    XCTAssertFalse([[self engine] canCompleteMove:invalidMove withTargetPile:tableau]);
}

- (void)testCanMoveKingToTableauWhenTableauAndStockTableauAreEmpty {
    STKStockTableauPile *stockTableau = [[[self board] stockTableaus] firstObject];
    STKPlayableTableauPile *tableau = [[[self board] playableTableaus] firstObject];
    [[stockTableau cards] removeAllObjects];
    [[tableau cards] removeAllObjects];

    NSArray *cards = @[[STKCard cardWithRank:STKCardRankKing suit:(STKCardSuit) -1]];

    STKMove *validMove = [[STKMove alloc] initWithCards:cards sourcePile:nil];
    XCTAssertTrue([[self engine] canCompleteMove:validMove withTargetPile:tableau]);
}

- (void)testCanMoveAceToFoundationWhenFoundationIsEmpty {
    STKFoundationPile *foundation = [[[self board] foundations] firstObject];

    NSArray *cards = @[[STKCard cardWithRank:STKCardRankAce suit:(STKCardSuit) -1]];

    STKMove *validMove = [STKMove moveWithCards:cards sourcePile:nil];
    XCTAssertTrue([[self engine] canCompleteMove:validMove withTargetPile:foundation]);
}

- (void)testCanMoveValidCardToNonEmptyFoundation {
    STKFoundationPile *foundation = [[[self board] foundations] firstObject];
    [[foundation cards] addObject:[STKCard cardWithRank:STKCardRankAce suit:STKCardSuitHearts]];

    NSArray *cards = @[[STKCard cardWithRank:STKCardRankTwo suit:STKCardSuitHearts]];

    STKMove *validMove = [[STKMove alloc] initWithCards:cards sourcePile:nil];
    XCTAssertTrue([[self engine] canCompleteMove:validMove withTargetPile:foundation]);
}

- (void)testCanNotMoveInvalidCardToNonEmptyFoundation {
    STKFoundationPile *foundation = [[[self board] foundations] firstObject];
    [[foundation cards] addObject:[STKCard cardWithRank:STKCardRankAce suit:STKCardSuitHearts]];

    NSArray *cards = @[[STKCard cardWithRank:STKCardRankKing suit:STKCardSuitHearts]];

    STKMove *invalidMove = [[STKMove alloc] initWithCards:cards sourcePile:nil];
    XCTAssertFalse([[self engine] canCompleteMove:invalidMove withTargetPile:foundation]);
}

@end
