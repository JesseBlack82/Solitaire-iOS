
#import <Foundation/Foundation.h>

@class STKCard;

typedef NSUInteger STKPileID;

typedef enum {
    STKPileTypeStock,
    STKPileTypeWaste,
    STKPileTypeTableau,
    STKPileTypeStockTableau,
    STKPileTypeFoundation
} STKPileType;

@interface STKBoard : NSObject

@property (nonatomic, strong) NSMutableArray* stock;
@property (nonatomic, strong) NSMutableArray* waste;
@property (nonatomic, strong) NSArray *foundations;
@property (nonatomic, strong) NSArray *stockTableaus;
@property (nonatomic, strong) NSArray *tableaus;

+ (NSUInteger)numberOfTableaus;
+ (NSUInteger)numberOfFoundations;
+ (void)moveTopCard:(NSMutableArray *)sourcePile toPile:(NSMutableArray *)toPile;

+ (STKPileType)pileTypeForPileID:(STKPileID)pileID;

- (NSMutableArray *)foundationAtIndex:(NSUInteger)foundationIndex;
- (NSMutableArray *)tableauAtIndex:(NSUInteger)tableauIndex;
- (NSMutableArray *)stockTableauAtIndex:(NSUInteger)tableauIndex;

- (BOOL)isCardTopWasteCard:(STKCard *)card;
- (BOOL)isTableauCard:(STKCard *)card;
- (BOOL)isTopFoundationCard:(STKCard *)card;

- (STKPileID)pileIDForCard:(STKCard *)card;
- (STKPileID)pileIDForPile:(NSMutableArray *)pile;

- (NSMutableArray *)allPiles;

- (NSMutableArray *)getPile:(STKPileID)pileID;

- (NSArray *)grabPileFromCard:(STKCard *)card;
@end