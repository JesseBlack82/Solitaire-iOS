
#import <Foundation/Foundation.h>
#import "STKBoard.h""

@class STKCard;

@interface STKGameEngine : NSObject


- (instancetype)initWithBoard:(STKBoard *)board;

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
@end