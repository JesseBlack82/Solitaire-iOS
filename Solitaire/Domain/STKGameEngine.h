
#import <Foundation/Foundation.h>
#import "STKBoard.h"

@class STKCard;
@class STKMove;

@interface STKGameEngine : NSObject

+ (NSUInteger)defaultDrawCount;

- (instancetype)initWithBoard:(STKBoard *)board;
- (instancetype)initWithBoard:(STKBoard *)board drawCount:(NSUInteger)count;

- (NSArray *)stock;
- (NSArray *)waste;
- (NSArray *)tableauAtIndex:(NSUInteger)tableauIndex;
- (NSArray *)stockTableauAtIndex:(NSUInteger)tableauIndex;
- (NSArray *)foundationAtIndex:(NSUInteger)foundationIndex;
- (NSArray *)foundations;
- (NSArray *)tableaus;

- (NSUInteger)drawCount;

- (void)dealCards:(NSArray *)deck;

- (BOOL)canDrawStockToWaste;
- (BOOL)canResetWasteToStock;
- (BOOL)canGrab:(STKCard *)card;
- (BOOL)canFlipStockTableauAtIndex:(NSUInteger)index;

- (void)drawStockToWaste;
- (void)resetWasteToStock;
- (STKMove *)grabPileFromCard:(STKCard *)card;

@end