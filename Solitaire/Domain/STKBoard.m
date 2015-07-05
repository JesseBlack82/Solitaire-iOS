
#import "STKBoard.h"

@interface STKBoard ()
@end

@implementation STKBoard

+ (NSUInteger)numberOfTableaus
{
    return 7;
}

+ (NSUInteger)numberOfFoundations
{
    return 4;
}

- (instancetype)init
{
    self = [super init];

    if (self) {
        [self setStock:[NSMutableArray array]];
        [self setWaste:[NSMutableArray array]];

        NSMutableArray *t = [NSMutableArray array];
        NSMutableArray *st = [NSMutableArray array];
        for (int i = 0; i < [[self class] numberOfTableaus]; i++) {
            [t addObject:[NSMutableArray array]];
            [st addObject:[NSMutableArray array]];
        }

        [self setTableaus:[t copy]];
        [self setStockTableaus:[st copy]];

        NSMutableArray *f = [NSMutableArray array];
        for (int i = 0; i < [[self class] numberOfFoundations]; i++) {
            [f addObject:[NSMutableArray array]];
        }

        [self setFoundations:[f copy]];
    }

    return self;
}

+ (void)moveTopCard:(NSMutableArray *)sourcePile toPile:(NSMutableArray *)toPile
{
    if ([sourcePile count] > 0) {
        [toPile addObject:[sourcePile lastObject]];
        [sourcePile removeLastObject];
    }
}

- (NSMutableArray *)foundationAtIndex:(NSUInteger)foundationIndex
{
    return [self foundations][foundationIndex];
}

- (NSMutableArray *)tableauAtIndex:(NSUInteger)tableauIndex
{
    return [self tableaus][tableauIndex];
}

- (NSMutableArray *)stockTableauAtIndex:(NSUInteger)tableauIndex
{
    return [self stockTableaus][tableauIndex];
}

@end