
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

+ (BOOL)areCardsDescendingRankWithAlternatingColors:(NSArray *)cards
{
    if ([cards count] == 0) {
        return NO;
    }

    STKCard *previousCard;
    for (STKCard *card in cards) {
        if (previousCard) {
            if (![previousCard isOppositeColor:card] || ![previousCard isCardNextDescendingRank:card]) {
                return NO;
            }
        }

        previousCard = card;
    }

    return YES;
}

- (BOOL)isOppositeColor:(STKCard *)card {
    NSArray *redSuits = @[@(STKCardSuitHearts), @(STKCardSuitDiamonds)];
    NSArray *blackSuits = @[@(STKCardSuitClubs), @(STKCardSuitSpades)];

    if ([redSuits containsObject:@([card suit])]) {
        return [blackSuits containsObject:@([self suit])];
    }

    if ([blackSuits containsObject:@([card suit])]) {
        return [redSuits containsObject:@([self suit])];
    }

    return NO;
}

- (BOOL)isCardNextDescendingRank:(STKCard *)card {
    NSUInteger rank = [[[self class] orderedRanks] indexOfObject:@([self rank])];
    NSUInteger nextRank= [[[self class] orderedRanks] indexOfObject:@([card rank])];

    return nextRank == --rank;
}

@end