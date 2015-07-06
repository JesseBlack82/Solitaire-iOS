#import "STKMove.h"


@interface STKMove ()
@property(nonatomic, strong) NSArray *cards;
@property(nonatomic) STKPileID sourcePileID;
@end

@implementation STKMove

+ (STKMove *)moveWithCards:(NSArray *)cards sourcePileID:(STKPileID)sourcePileID
{
    return [[STKMove alloc] initWithCards:cards sourcePileID:sourcePileID];
}

- (instancetype)initWithCards:(NSArray *)cards sourcePileID:(STKPileID)sourcePileID
{
    self = [super init];

    if (self) {
        [self setCards:cards];
        [self setSourcePileID:sourcePileID];
    }

    return self;
}

@end