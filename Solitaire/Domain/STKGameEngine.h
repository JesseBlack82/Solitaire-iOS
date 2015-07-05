
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

- (BOOL)canDrawStockToWaste;
- (BOOL)canResetWasteToStock;
- (BOOL)canGrab:(STKCard *)card;

- (void)dealCards:(NSArray *)deck;

- (NSArray *)foundations;

- (NSArray *)tableaus;

- (STKMove *)grabPileFromCard:(STKCard *)card;

- (NSUInteger)drawCount;
@end