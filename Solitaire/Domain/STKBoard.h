
#import <Foundation/Foundation.h>

@class STKCard;
@class STKBoard;
@class STKTableauSlot;

@interface STKPile : NSObject
- (instancetype)initWithBoard:(STKBoard *)board;
- (instancetype)copy;

@property (nonatomic, strong) NSMutableArray *cards;

- (BOOL)hasCards;
- (STKCard *)topCard;

- (NSArray *)grabTopCardsFromCard:(STKCard *)card;
@end

@interface STKStockPile : STKPile
@end

@interface STKWastePile : STKPile
@end

@interface STKStockTableauPile : STKPile
@property(nonatomic, weak) STKTableauSlot *tableauSlot;
- (instancetype)initWithBoard:(STKBoard *)board tableauSlot:(STKTableauSlot *)tableauSlot;
@end

@protocol STKPlayablePile
- (BOOL)canAddCards:(NSArray *)cards;
- (BOOL)isPileValid;
@end

@interface STKPlayableTableauPile : STKPile <STKPlayablePile>
@property(nonatomic, weak) STKTableauSlot *tableauSlot;
- (id)initWithBoard:(STKBoard *)board tableauSlot:(STKTableauSlot *)slot;
@end

@interface STKFoundationPile : STKPile <STKPlayablePile>
@end

@interface STKTableauSlot : NSObject
+ (NSArray *)stockTableaus:(NSArray *)tableauSlots;
+ (NSArray *)playableTableaus:(NSArray *)tableauSlots;

- (id)initWithPlayablePile:(STKPlayableTableauPile *)playablePile stockPile:(STKStockTableauPile *)stockPile;

@property (nonatomic, readonly, strong) STKPlayableTableauPile *playableTableau;
@property (nonatomic, readonly, strong) STKStockTableauPile *stockTableau;

@end

@interface STKBoard : NSObject
@property (nonatomic, strong) STKStockPile* stock;
@property (nonatomic, strong) STKWastePile* waste;
@property (nonatomic, strong) NSArray *foundations;
@property (nonatomic, strong) NSArray *tableauSlots;

+ (NSUInteger)numberOfTableaus;
+ (NSUInteger)numberOfFoundations;

+ (void)moveTopCard:(STKPile *)sourcePile toPile:(STKPile *)toPile;

- (NSMutableArray *)allPiles;
- (STKFoundationPile *)foundationAtIndex:(NSUInteger)foundationIndex;
- (STKPlayableTableauPile *)tableauAtIndex:(NSUInteger)tableauIndex;
- (STKStockTableauPile *)stockTableauAtIndex:(NSUInteger)tableauIndex;
- (NSArray *)stockTableaus;
- (NSArray *)playableTableaus;

- (BOOL)isCardTopWasteCard:(STKCard *)card;
- (BOOL)isPlayableTableauCard:(STKCard *)card;
- (BOOL)isTopFoundationCard:(STKCard *)card;

- (STKPile *)pileContainingCard:(STKCard *)card;
@end
