#import "STKMove.h"


@interface STKMove ()
@property(nonatomic, strong) NSArray *cards;
@property(nonatomic) STKSourcePileID sourcePileID;
@end

@implementation STKMove
+ (STKMove *)moveWithCards:(NSArray *)cards sourcePileID:(STKSourcePileID)sourcePileID
{
    return [[STKMove alloc] initWithCards:cards sourcePileID:sourcePileID];
}

- (instancetype)initWithCards:(NSArray *)cards sourcePileID:(STKSourcePileID)sourcePileID
{
    self = [super init];

    if (self) {
        [self setCards:cards];
        [self setSourcePileID:sourcePileID];
    }

    return self;
}

- (NSArray *)cards
{
    return _cards;
}

- (STKSourcePileID)sourcePileID
{
    return _sourcePileID;
}


@end