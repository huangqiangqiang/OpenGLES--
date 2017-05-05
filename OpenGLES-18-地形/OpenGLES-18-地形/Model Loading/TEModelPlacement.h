//
//  TEModelPlacement.h
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TETerrain;

@interface TEModelPlacement : NSManagedObject

@property (nonatomic, assign) float angle;
@property (nonatomic, assign) int32_t index;
@property (nonatomic, copy) NSString * modelName;
@property (nonatomic, assign) float positionX;
@property (nonatomic, assign) float positionY;
@property (nonatomic, assign) float positionZ;
@property (nonatomic, strong) TETerrain *terrain;

@end
