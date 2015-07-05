
#import "STKCard.h"

@interface STKCard ()
@property(nonatomic) STKCardSuit suit;
@property(nonatomic) STKCardRank rank;
@end

@implementation STKCard

+ (instancetype)cardWithRank:(STKCardRank)rank suit:(STKCardSuit)suit
{
    return [[STKCard alloc] initWithRank:rank suit:suit];
}

- (id)initWithRank:(STKCardRank)rank suit:(STKCardSuit)suit
{
    self = [super init];

    if (self) {
        [self setRank:rank];
        [self setSuit:suit];
    }

    return self;
}

+ (NSArray *)deck
{
    NSMutableArray *deck = [NSMutableArray array];
    for (int i = 0; i < 52; ++i) {
        [deck addObject:[[STKCard alloc] init]];
    }

    return [deck copy];
}

+ (NSArray *)allSuits
{
    return @[@(STKCardSuitHearts), @(STKCardSuitDiamonds), @(STKCardSuitClubs), @(STKCardSuitSpades)];
}

+ (NSArray *)orderedRanks
{
    return @[@(STKCardRankAce), @(STKCardRankTwo), @(STKCardRankThree), @(STKCardRankFour),
            @(STKCardRankFive), @(STKCardRankSix), @(STKCardRankSeven), @(STKCardRankEight),
            @(STKCardRankNine), @(STKCardRankTen), @(STKCardRankJack), @(STKCardRankQueen),
            @(STKCardRankKing)];
}

+ (NSArray *)completeAscendingSuit:(STKCardSuit)suit
{
    NSMutableArray *cards = [NSMutableArray array];

    for (NSNumber *rank in [self orderedRanks]) {
        [cards addObject:[STKCard cardWithRank:[rank intValue] suit:suit]];
    }

    return [cards copy];
}


@end