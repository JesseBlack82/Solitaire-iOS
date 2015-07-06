
#import <Foundation/Foundation.h>

#import "STKBoard.h"

@interface STKMove : NSObject

+ (STKMove *)moveWithCards:(NSArray *)cards sourcePile:(STKPile *)sourcePile;
- (instancetype)initWithCards:(NSArray *)cards sourcePile:(STKPile *)sourcePile;

- (NSArray *)cards;
- (STKPile *)sourcePile;

@end