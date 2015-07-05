#import <Foundation/Foundation.h>

#import "STKBoard.h"


@interface STKMove : NSObject
+ (STKMove *)moveWithCards:(NSArray *)cards sourcePileID:(STKPileID)sourcePileID;

- (instancetype)initWithCards:(NSArray *)cards sourcePileID:(STKPileID)sourcePileID;

- (NSArray *)cards;
- (STKPileID)sourcePileID;

@end