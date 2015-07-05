
#import "STKCard.h"

@implementation STKCard

+ (NSArray *)deck
{
    NSMutableArray *deck = [NSMutableArray array];
    for (int i = 0; i < 52; ++i) {
        [deck addObject:[[STKCard alloc] init]];
    }

    return [deck copy];
}


@end