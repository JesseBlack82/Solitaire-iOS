
#import <Foundation/Foundation.h>

typedef enum {
    STKCardSuitHearts,
    STKCardSuitDiamonds,
    STKCardSuitSpades,
    STKCardSuitClubs

} STKCardSuit;

typedef enum {
    STKCardRankAce,
    STKCardRankTwo,
    STKCardRankThree,
    STKCardRankFour,
    STKCardRankFive,
    STKCardRankSix,
    STKCardRankSeven,
    STKCardRankEight,
    STKCardRankNine,
    STKCardRankTen,
    STKCardRankJack,
    STKCardRankQueen,
    STKCardRankKing
} STKCardRank;

@interface STKCard : NSObject

+ (NSArray *)deck;
+ (NSArray *)allSuits;
+ (NSArray *)orderedRanks;

+ (NSArray *)completeAscendingSuit:(STKCardSuit)suit;
+ (BOOL)areCardsDescendingRankWithAlternatingColors:(NSArray *)cards;

+ (instancetype)cardWithRank:(STKCardRank)rank suit:(STKCardSuit)suit;
- (id)initWithRank:(STKCardRank)rank suit:(STKCardSuit)suit;

@property (nonatomic, readonly) STKCardSuit suit;
@property (nonatomic, readonly) STKCardRank rank;

- (BOOL)isOppositeColor:(STKCard *)card;
- (BOOL)isCardNextDescendingRank:(STKCard *)card;


@end