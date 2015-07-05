
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

- (NSArray *)grabPileFromCard:(STKCard *)card
{
    NSMutableArray *sourcePile = [self sourcePileForCard:card];
    NSUInteger cardLocation = [sourcePile indexOfObject:card];

    NSArray *cards = [sourcePile subarrayWithRange:NSMakeRange(cardLocation, [sourcePile count] - cardLocation)];
    [sourcePile removeObjectsInArray:cards];

    return cards;
}

- (STKPileID)pileIDForCard:(STKCard *)card
{
    NSMutableArray *sourcePile = [self sourcePileForCard:card];
    return [self pileIDForPile:sourcePile];
}

- (NSMutableArray *)sourcePileForCard:(STKCard *)card
{
    for (NSMutableArray *pile in [self allPiles]) {
        if ([pile containsObject:card]) {
            return pile;
        }
    }

    return nil;
}

- (STKPileID)pileIDForPile:(NSMutableArray *)pile
{
    return [[self allPiles] indexOfObject:pile];
}

- (NSMutableArray *)allPiles
{
    NSMutableArray *piles = [NSMutableArray array];
    for (NSUInteger i = 0; i < [[self class] numberOfTableaus]; ++i) {
        [piles addObject:[[self tableaus] objectAtIndex:i]];
        [piles addObject:[[self stockTableaus] objectAtIndex:i]];
    }

    for (NSUInteger i = 0; i < [[self class] numberOfFoundations]; ++i) {
        [piles addObject:[[self foundations] objectAtIndex:i]];
    }

    [piles addObject:[self stock]];
    [piles addObject:[self waste]];

    return piles;
}
@end