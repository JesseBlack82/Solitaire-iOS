
#import <Foundation/Foundation.h>
#import "STKBoard.h"

@class STKCard;
@class STKMove;

@interface STKGameEngine : NSObject

+ (NSUInteger)defaultDrawCount;

- (instancetype)initWithBoard:(STKBoard *)board;
- (instancetype)initWithBoard:(STKBoard *)board drawCount:(NSUInteger)count;

@property (nonatomic, readonly) NSUInteger drawCount;

- (NSArray *)stock;
- (NSArray *)waste;
- (NSArray *)tableauAtIndex:(NSUInteger)tableauIndex;
- (NSArray *)stockTableauAtIndex:(NSUInteger)tableauIndex;
- (NSArray *)foundationAtIndex:(NSUInteger)foundationIndex;
- (NSArray *)foundations;
- (NSArray *)playableTableaus;

- (void)dealCards:(NSArray *)deck;

- (BOOL)isBoardSolved;

- (BOOL)canDrawStockToWaste;
- (BOOL)canResetWasteToStock;
- (BOOL)canGrab:(STKCard *)card;
- (BOOL)canFlipStockTableauAtIndex:(NSUInteger)index;
- (BOOL)canCompleteMove:(STKMove *)move withTargetPile:(STKPile *)targetPile;

- (void)drawStockToWaste;
- (void)resetWasteToStock;
- (STKMove *)grabTopCardsFromCard:(STKCard *)card;

@end