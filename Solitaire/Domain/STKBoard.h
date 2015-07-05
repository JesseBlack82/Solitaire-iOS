
#import <Foundation/Foundation.h>

@interface STKBoard : NSObject

@property (nonatomic, strong) NSMutableArray* stock;
@property (nonatomic, strong) NSMutableArray* waste;
@property (nonatomic, strong) NSArray *foundations;
@property (nonatomic, strong) NSArray *stockTableaus;
@property (nonatomic, strong) NSArray *tableaus;

+ (NSUInteger)numberOfTableaus;

+ (NSUInteger)numberOfFoundations;

- (NSMutableArray *)foundationAtIndex:(NSUInteger)foundationIndex;
- (NSMutableArray *)tableauAtIndex:(NSUInteger)tableauIndex;
- (NSMutableArray *)stockTableauAtIndex:(NSUInteger)tableauIndex;

@end