
#import "STKBoard.h"
#import "STKCard.h"

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

- (BOOL)isCardTopWasteCard:(STKCard *)card
{
    return [[self waste] count] > 0 && [[self waste] lastObject] == card;
}

- (BOOL)isTableauCard:(STKCard *)card
{
    for (NSArray *tableau in [self tableaus]) {
        for (STKCard *tableauCard in tableau) {
            if (tableauCard == card) {
                return YES;
            }
        }
    }

    return NO;
}

- (BOOL)isTopFoundationCard:(STKCard *)card
{
    for (NSArray *foundation in [self foundations]) {
        if ([foundation lastObject] == card) {
            return YES;
        }
    }
    return NO;
}

@end