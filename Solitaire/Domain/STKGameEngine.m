#import "STKGameEngine.h"
#import "STKCard.h"
#import "STKMove.h"

@interface STKGameEngine ()
@property (nonatomic, strong) STKBoard *board;
@property (nonatomic) NSUInteger drawCount;
@end

@implementation STKGameEngine

+ (NSUInteger)defaultDrawCount
{
    return 3;
}

- (instancetype)initWithBoard:(STKBoard *)board
{
    return [self initWithBoard:board drawCount:[[self class] defaultDrawCount]];
}

- (instancetype)initWithBoard:(STKBoard *)board drawCount:(NSUInteger)count
{
    self = [super init];

    if (self) {
        [self setBoard:board];
        [self setDrawCount:count];
    }

    return self;
}

- (NSArray *)stock
{
    return [[[[self board] stock] cards] copy];
}

- (NSArray *)waste
{
    return [[[[self board] waste] cards] copy];
}

- (NSArray *)tableauAtIndex:(NSUInteger)tableauIndex
{
    return [[[[self board] tableauAtIndex:tableauIndex] cards] copy];
}

- (NSArray *)stockTableauAtIndex:(NSUInteger)tableauIndex
{
    return [[[[self board] stockTableauAtIndex:tableauIndex] cards] copy];
}

- (NSArray *)foundationAtIndex:(NSUInteger)foundationIndex
{
    return [[[[self board] foundationAtIndex:foundationIndex] cards] copy];
}

- (BOOL)canDrawStockToWaste
{
    return [[self stock] count] > 0;
}

- (BOOL)canResetWasteToStock
{
    return [[self stock] count] == 0 && [[self waste] count] > 0;
}

- (BOOL)canGrab:(STKCard *)card
{
    if ([[self board] isCardTopWasteCard:card]) {
        return YES;
    }

    if ([[self board] isPlayableTableauCard:card]) {
        return YES;
    }

    return [[self board] isTopFoundationCard:card];
}

- (BOOL)canFlipStockTableauAtIndex:(NSUInteger)index
{
    NSArray *stockTableau = [self stockTableauAtIndex:index];
    NSArray *tableau = [self tableauAtIndex:index];

    return [stockTableau count] > 0 && [tableau count] == 0;
}

- (BOOL)canCompleteMove:(STKMove *)move withTargetPile:(STKPile *)targetPile
{
    return [self canMoveCards:[move cards] toPile:targetPile];
}

- (BOOL)canMoveCards:(NSArray *)cards toPile:(STKPile *)targetPile
{
    STKPile *pileCopy = [targetPile copy];
    if ([pileCopy conformsToProtocol:@protocol(STKPlayablePile)]) {
        return [(id <STKPlayablePile>) pileCopy canAddCards:cards];
    }

    return NO;
}

- (void)dealCards:(NSArray *)cards
{
    NSMutableArray *deck = [cards mutableCopy];

    NSMutableArray *stockTableauPiles = [[[[self board] stockTableaus] subarrayWithRange:NSMakeRange(1,
            [STKBoard numberOfTableaus] - 1)] mutableCopy];
    NSMutableArray * playableTableaus = [[[self board] playableTableaus] mutableCopy];

    void (^dealCard)(STKPile *, NSMutableArray *) = ^(STKPile *pile, NSMutableArray *remainingCards) {
        [[pile cards] addObject:[remainingCards lastObject]];
        [remainingCards removeLastObject];
    };

    void (^dealStockCards)(NSMutableArray *, NSMutableArray *) = ^(NSMutableArray *remainingStockPiles, NSMutableArray *remainingCards) {
        for (STKStockTableauPile *pile in remainingStockPiles) {
            dealCard(pile, remainingCards);
        }
    };

    void (^dealRound)(NSMutableArray *, NSMutableArray *, NSMutableArray *) =
            ^(NSMutableArray *remainingPlayPiles, NSMutableArray *remainingStockPiles, NSMutableArray *remainingCards) {
                dealCard([remainingPlayPiles firstObject], remainingCards);
                [remainingPlayPiles removeObjectAtIndex:0];

                if ([remainingStockPiles count] > 0) {
                    dealStockCards(remainingStockPiles, remainingCards);
                    [remainingStockPiles removeObjectAtIndex:0];
                }
            };

    while ([playableTableaus count] > 0) {
        dealRound(playableTableaus, stockTableauPiles, deck);
    }

    [[[[self board] stock] cards] addObjectsFromArray:deck];
}

- (NSArray *)foundations
{
    NSMutableArray *foundations = [NSMutableArray array];
    for (NSMutableArray *foundation in [[self board] foundations]) {
        [foundations addObject:[foundation copy]];
    }
    return [foundations copy];
}

- (NSArray *)playableTableaus
{
    NSMutableArray *tableaus = [NSMutableArray array];
    for (STKPlayableTableauPile *tableau in [[self board] playableTableaus]) {
        [tableaus addObject:[[tableau cards] copy]];
    }
    return [tableaus copy];
}

- (STKMove *)grabTopCardsFromCard:(STKCard *)card
{
    if ([self canGrab:card] == false) {
        return nil;
    }

    STKPile *sourcePile = [[self board] pileContainingCard:card];
    NSArray *cards = [sourcePile grabTopCardsFromCard:card];
    STKMove *move = [STKMove moveWithCards:cards sourcePile:sourcePile];

    return move;
}

- (void)drawStockToWaste
{
    NSUInteger availableDrawCount = MIN([[self stock] count], [self drawCount]);
    for (NSUInteger i = 0; i < availableDrawCount; ++i) {
        [STKBoard moveTopCard:[[self board] stock] toPile:[[self board] waste]];
    }
}

- (void)resetWasteToStock
{
    if (![self canResetWasteToStock]) {
        return;
    }

    while ([[self waste] count] > 0) {
        [STKBoard moveTopCard:[[self board] waste] toPile:[[self board] stock]];
    }
}

- (BOOL)isBoardSolved
{
    NSArray *foundations = [self foundations];
    NSMutableArray *remainingSuits = [[STKCard allSuits] mutableCopy];
    for (STKFoundationPile *foundation in foundations) {
        STKCardSuit suit = (STKCardSuit) [[foundation topCard] suit];
        NSMutableArray *remainingRanks = [[STKCard orderedRanks] mutableCopy];
        for (STKCard *card in [foundation cards]) {
            if (!([card rank] == [[remainingRanks firstObject] intValue] || ![card suit] == suit)) {
                return NO;
            }
            [remainingRanks removeObjectAtIndex:0];
        }
        [remainingSuits removeObject:@(suit)];

    }

    return [remainingSuits count] == 0;
}

@end