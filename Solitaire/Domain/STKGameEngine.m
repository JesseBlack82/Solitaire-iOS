#import "STKGameEngine.h"

@interface STKGameEngine ()
@property(nonatomic, strong) STKBoard *board;
@end

@implementation STKGameEngine

- (instancetype)initWithBoard:(STKBoard *)board
{
    self = [super init];

    if (self) {
        [self setBoard:board];
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

@end