
#import <Foundation/Foundation.h>
#import "STKBoard.h""

@interface STKGameEngine : NSObject


- (instancetype)initWithBoard:(STKBoard *)board;

- (NSArray *)stock;
- (NSArray *)waste;
- (NSArray *)tableauAtIndex:(NSUInteger)tableauIndex;
- (NSArray *)stockTableauAtIndex:(NSUInteger)tableauIndex;
- (NSArray *)foundationAtIndex:(NSUInteger)foundationIndex;


- (void)dealCards:(NSArray *)deck;


@end