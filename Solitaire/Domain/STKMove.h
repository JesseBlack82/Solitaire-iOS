#import <Foundation/Foundation.h>

#import "STKBoard.h"


@interface STKMove : NSObject
+ (STKMove *)moveWithCards:(NSArray *)cards sourcePileID:(STKSourcePileID)sourcePile;

- (instancetype)initWithCards:(NSArray *)cards sourcePileID:(STKSourcePileID)sourcePileID;

- (NSArray *)cards;
- (STKSourcePileID)sourcePileID;

@end