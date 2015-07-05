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
    return [[[self board] stock] copy];
}

- (NSArray *)waste
{
    return [[[self board] waste] copy];
}

- (NSArray *)tableauAtIndex:(NSUInteger)tableauIndex
{
    return [[[self board] tableauAtIndex:tableauIndex] copy];
}

- (NSArray *)stockTableauAtIndex:(NSUInteger)tableauIndex
{
    return [[[self board] stockTableauAtIndex:tableauIndex] copy];
}

- (NSArray *)foundationAtIndex:(NSUInteger)foundationIndex
{
    return [[[self board] foundationAtIndex:foundationIndex] copy];
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

    if ([[self board] isTableauCard:card]) {
        return YES;
    }

    if ([[self board] isTopFoundationCard:card]) {
        return YES;
    }
    return NO;
}

- (BOOL)canFlipStockTableauAtIndex:(NSUInteger)index
{
    NSArray *stockTableau = [self stockTableauAtIndex:index];
    NSArray *tableau = [self tableauAtIndex:index];

    return [stockTableau count] > 0 && [tableau count] == 0;
}

- (void)dealCards:(NSArray *)cards
{
    NSMutableArray *deck = [cards mutableCopy];

    NSMutableArray *remainingStockStacks = [[[[self board] stockTableaus] subarrayWithRange:NSMakeRange(1,
            [STKBoard numberOfTableaus] - 1)] mutableCopy];
    NSMutableArray *remainingPlayStacks = [[[self board] tableaus] mutableCopy];

    void (^dealCard)(NSMutableArray *, NSMutableArray *) = ^(NSMutableArray *stack, NSMutableArray *remainingCards) {
        [stack addObject:[remainingCards lastObject]];
        [remainingCards removeLastObject];
    };

    void (^dealStockCards)(NSMutableArray *, NSMutableArray *) = ^(NSMutableArray *remainingStockStacks, NSMutableArray *remainingCards) {
        for (NSMutableArray *stack in remainingStockStacks) {
            dealCard(stack, remainingCards);
        }
    };

    void (^dealRound)(NSMutableArray *, NSMutableArray *, NSMutableArray *) =
            ^(NSMutableArray *remainingPlayStacks, NSMutableArray *remainingStockStacks, NSMutableArray *remainingCards) {
                dealCard([remainingPlayStacks firstObject], remainingCards);
                [remainingPlayStacks removeObjectAtIndex:0];

                if ([remainingStockStacks count] > 0) {
                    dealStockCards(remainingStockStacks, remainingCards);
                    [remainingStockStacks removeObjectAtIndex:0];
                }
            };

    while ([remainingPlayStacks count] > 0) {
        dealRound(remainingPlayStacks, remainingStockStacks, deck);
    }

    [[[self board] stock] addObjectsFromArray:deck];
}

- (NSArray *)foundations
{
    NSMutableArray *foundations = [NSMutableArray array];
    for (NSMutableArray *foundation in [[self board] foundations]) {
        [foundations addObject:[foundation copy]];
    }
    return [foundations copy];
}

- (NSArray *)tableaus
{
    NSMutableArray *tableaus = [NSMutableArray array];
    for (NSMutableArray *tableaus in [[self board] tableaus]) {
        [tableaus addObject:[tableaus copy]];
    }
    return [tableaus copy];
}

- (STKMove *)grabPileFromCard:(STKCard *)card
{
    if ([self canGrab:card] == false) {
        return nil;
    }

    NSArray *cards = [[self board] grabPileFromCard:card];
    STKMove *move = [STKMove moveWithCards:cards sourcePileID:[[self board] pileIDForCard:card]];

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

- (BOOL)areWinningConditionsSatisfied
{
    NSArray *foundations = [self foundations];
    NSMutableArray *remainingSuits = [[STKCard allSuits] mutableCopy];
    for (NSArray *foundation in foundations) {
        STKCardSuit suit = [[foundation firstObject] suit];
        NSMutableArray *remainingRanks = [[STKCard orderedRanks] mutableCopy];
        for (STKCard *card in foundation) {
            if (!([card rank] == [[remainingRanks firstObject] unsignedIntegerValue] || [card suit] == suit)) {
                return NO;
            }
            [remainingRanks removeObject:0];
        }
        [remainingSuits removeObject:@(suit)];

    }

    return [remainingSuits count] == 0;
}

@end