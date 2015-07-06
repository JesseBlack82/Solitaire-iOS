#import "STKMove.h"


@interface STKMove ()
@property(nonatomic, strong) NSArray *cards;
@property(nonatomic) STKPile * sourcePile;
@end

@implementation STKMove

+ (STKMove *)moveWithCards:(NSArray *)cards sourcePile:(STKPile *)sourcePile
{
    return [[STKMove alloc] initWithCards:cards sourcePile:sourcePile];
}

- (instancetype)initWithCards:(NSArray *)cards sourcePile:(STKPile *)sourcePile
{
    self = [super init];

    if (self) {
        [self setCards:cards];
        [self setSourcePile:sourcePile];
    }

    return self;
}

@end