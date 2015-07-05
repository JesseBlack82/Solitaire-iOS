
#import <Foundation/Foundation.h>

@class STKCard;

typedef NSUInteger STKSourcePileID;

@interface STKBoard : NSObject

@property (nonatomic, strong) NSMutableArray* stock;
@property (nonatomic, strong) NSMutableArray* waste;
@property (nonatomic, strong) NSArray *foundations;
@property (nonatomic, strong) NSArray *stockTableaus;
@property (nonatomic, strong) NSArray *tableaus;

+ (NSUInteger)numberOfTableaus;

+ (NSUInteger)numberOfFoundations;

- (NSMutableArray *)foundationAtIndex:(NSUInteger)foundationIndex;

+ (void)moveTopCard:(NSMutableArray *)sourcePile toPile:(NSMutableArray *)toPile;

- (NSMutableArray *)tableauAtIndex:(NSUInteger)tableauIndex;
- (NSMutableArray *)stockTableauAtIndex:(NSUInteger)tableauIndex;

- (BOOL)isCardTopWasteCard:(STKCard *)card;

- (BOOL)isTableauCard:(STKCard *)card;

- (BOOL)isTopFoundationCard:(STKCard *)card;

- (NSArray *)grabPileFromCard:(STKCard *)card;

- (STKSourcePileID)sourcePileIDForCard:(STKCard *)card;

- (STKSourcePileID)sourcePileIDForPile:(NSMutableArray *)pile;
@end