
#import "STKBoard.h"
#import "STKCard.h"

@interface STKPile ()
@property (nonatomic, weak) STKBoard *board;
@end

@implementation STKPile

- (instancetype)initWithBoard:(STKBoard *)board
{
    self = [super init];

    if (self) {
        [self setBoard:board];
        [self setCards:[NSMutableArray array]];
    }

    return self;
}

- (instancetype)copy
{
    STKPile *copy = [(STKPile *) ([[self class] alloc]) initWithBoard:[self board]];

    [[copy cards] addObjectsFromArray:[self cards]];
    [copy setBoard:[self board]];

    return copy;
}

- (BOOL)isEqual:(id)object
{
    if (![[object class] isKindOfClass:[STKPile class]]) {
        return NO;
    }

    if ([object board] != [self board]) {
        return NO;
    }

    for (STKCard *card in [object cards]) {
        [[self cards] containsObject:card];
    }

    return YES;
}

- (BOOL)hasCards
{
    return [[self cards] count] > 0;
}

- (STKCard *)topCard
{
    return [[self cards] lastObject];
}

- (NSArray *)grabTopCardsFromCard:(STKCard *)card
{
    NSUInteger location = [[self cards] indexOfObject:card];

    if (location != NSNotFound) {
        NSArray *toGrab = [[self cards] subarrayWithRange:NSMakeRange(location, [[self cards] count] - location)];
        [[self cards] removeObjectsInArray:toGrab];
        return toGrab;
    }

    return nil;
}
@end

@implementation STKStockPile
@end

@implementation STKWastePile
@end

@implementation STKStockTableauPile
- (instancetype)initWithBoard:(STKBoard *)board tableauSlot:(STKTableauSlot *)tableauSlot {
    self = [super initWithBoard:board];

    if (self) {
        _tableauSlot = tableauSlot;
    }

    return self;
}

- (instancetype)copy
{
    STKStockTableauPile *copy = [super copy];

    [copy setTableauSlot:[self tableauSlot]];

    return copy;
}
@end

@implementation STKPlayableTableauPile
- (instancetype)initWithBoard:(STKBoard *)board tableauSlot:(STKTableauSlot *)tableauSlot {
    self = [super initWithBoard:board];

    if (self) {
        _tableauSlot = tableauSlot;
    }

    return self;
}

- (instancetype)copy
{
    STKPlayableTableauPile *copy = [super copy];

    [copy setTableauSlot:[self tableauSlot]];

    return copy;
}

- (BOOL)canAddCards:(NSArray *)cards
{
    if ([[cards firstObject] rank] == STKCardRankKing) {
        return ![[[self tableauSlot] playableTableau] hasCards];
    }

    if ([self hasCards]) {
        STKCard *toCard = [self topCard];
        STKPlayableTableauPile *temporaryTableau = [[STKPlayableTableauPile alloc] initWithBoard:[self board] tableauSlot:[self tableauSlot]];
        [[temporaryTableau cards] addObject:toCard];
        [[temporaryTableau cards] addObjectsFromArray:cards];

        return [temporaryTableau isPileValid];
    }

    return NO;
}

- (BOOL)isPileValid
{
    return [STKCard areCardsDescendingRankWithAlternatingColors:[self cards]];
}

- (void)setTableauSlot:(STKTableauSlot *)slot
{
    _tableauSlot = slot;
}
@end

@implementation STKFoundationPile
- (BOOL)canAddCards:(NSArray *)cards
{
    if ([cards count] != 1) {
        return NO;
    }

    STKFoundationPile *temporaryFoundation = [self copy];
    [[temporaryFoundation cards] addObjectsFromArray:cards];

    return [temporaryFoundation isPileValid];
}

- (BOOL)isPileValid
{
    return [[[self cards] firstObject] rank] == STKCardRankAce && [STKCard areCardsAscendingRankWithMatchingSuit:[self cards]];
}

@end

@implementation STKTableauSlot

- (id)initWithPlayablePile:(STKPlayableTableauPile *)playablePile stockPile:(STKStockTableauPile *)stockPile
{
    self = [super init];

    if (self) {
        _playableTableau = playablePile;
        _stockTableau = stockPile;
        [[self playableTableau] setTableauSlot:self];
    }

    return self;
}

+ (NSArray *)stockTableaus:(NSArray *)tableauSlots
{
    NSMutableArray *tableaus = [NSMutableArray array];

    for (STKTableauSlot *tableauSlot in tableauSlots) {
        [tableaus addObject:[tableauSlot stockTableau]];
    }

    return [tableaus copy];
}

+ (NSArray *)playableTableaus:(NSArray *)tableauSlots
{
    NSMutableArray *tableaus = [NSMutableArray array];

    for (STKTableauSlot *tableauSlot in tableauSlots) {
        [tableaus addObject:[tableauSlot playableTableau]];
    }

    return [tableaus copy];
}

@end

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
        [self setStock:[[STKStockPile alloc] initWithBoard:self]];
        [self setWaste:[[STKWastePile alloc] initWithBoard:self]];

        NSMutableArray *tableauSlots = [NSMutableArray array];
        for (int i = 0; i < [[self class] numberOfTableaus]; i++) {
            STKPlayableTableauPile *playable = [[STKPlayableTableauPile alloc] initWithBoard:self];
            STKStockTableauPile *stock = [[STKStockTableauPile alloc] initWithBoard:self];

            STKTableauSlot *tableauSlot = [[STKTableauSlot alloc] initWithPlayablePile:playable stockPile:stock];
            [tableauSlots addObject:tableauSlot];
            [playable setTableauSlot:tableauSlot];
            [stock setTableauSlot:tableauSlot];
        }
        [self setTableauSlots:tableauSlots];

        NSMutableArray *f = [NSMutableArray array];
        for (int i = 0; i < [[self class] numberOfFoundations]; i++) {
            [f addObject:[[STKFoundationPile alloc] initWithBoard:self]];
        }

        [self setFoundations:[f copy]];
    }

    return self;
}

+ (void)moveTopCard:(STKPile *)sourcePile toPile:(STKPile *)toPile
{
    if ([sourcePile hasCards]) {
        [[toPile cards] addObject:[sourcePile topCard]];
        [[sourcePile cards] removeLastObject];
    }
}

- (STKFoundationPile *)foundationAtIndex:(NSUInteger)foundationIndex
{
    return [self foundations][foundationIndex];
}

- (STKPlayableTableauPile *)tableauAtIndex:(NSUInteger)tableauIndex
{
    return [self playableTableaus][tableauIndex];
}

- (STKStockTableauPile *)stockTableauAtIndex:(NSUInteger)tableauIndex
{
    return [self stockTableaus][tableauIndex];
}

- (BOOL)isCardTopWasteCard:(STKCard *)card
{
    return [[self waste] hasCards] && [[self waste] topCard] == card;
}

- (BOOL)isPlayableTableauCard:(STKCard *)card
{
    for (STKPlayableTableauPile *tableau in [self playableTableaus]) {
        for (STKCard *tableauCard in [tableau cards]) {
            if (tableauCard == card) {
                return YES;
            }
        }
    }

    return NO;
}

- (BOOL)isTopFoundationCard:(STKCard *)card
{
    for (STKFoundationPile *foundation in [self foundations]) {
        if ([foundation topCard] == card) {
            return YES;
        }
    }
    return NO;
}

- (STKPile *)pileContainingCard:(STKCard *)card
{
    for (STKPile *pile in [self allPiles]) {
        if ([[pile cards] containsObject:card]) {
            return pile;
        }
    }

    return nil;
}

- (NSArray *)grabPileFromCard:(STKCard *)card
{
    STKPile *sourcePile = [self sourcePileForCard:card];
    NSUInteger cardLocation = [[sourcePile cards] indexOfObject:card];

    NSArray *cards = [[sourcePile cards] subarrayWithRange:NSMakeRange(cardLocation, [[sourcePile cards] count] - cardLocation)];
    [[sourcePile cards] removeObjectsInArray:cards];

    return cards;
}

- (STKPile *)sourcePileForCard:(STKCard *)card
{
    for (STKPile *pile in [self allPiles]) {
        if ([[pile cards] containsObject:card]) {
            return pile;
        }
    }

    return nil;
}

- (NSMutableArray *)allPiles
{
    NSMutableArray *piles = [NSMutableArray array];
    for (NSUInteger i = 0; i < [[self class] numberOfTableaus]; ++i) {
        [piles addObject:[self playableTableaus][i]];
        [piles addObject:[self stockTableaus][i]];
    }

    for (NSUInteger i = 0; i < [[self class] numberOfFoundations]; ++i) {
        [piles addObject:[self foundations][i]];
    }

    [piles addObject:[self stock]];
    [piles addObject:[self waste]];

    return piles;
}

- (NSArray *)stockTableaus
{
    return [STKTableauSlot stockTableaus:[self tableauSlots]];
}

- (NSArray *)playableTableaus
{
    return [STKTableauSlot playableTableaus:[self tableauSlots]];
}

@end
