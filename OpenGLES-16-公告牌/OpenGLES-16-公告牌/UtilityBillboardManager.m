//
//  UtilityBillboardManager.m
//  OpenGLES-16-公告牌
//
//  Created by 黄强强 on 17/4/26.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "UtilityBillboardManager.h"
#import "UtilityBillboard.h"

@interface UtilityBillboardManager()

@end

@implementation UtilityBillboardManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mutableSortedBillboards = [NSMutableArray array];
    }
    return self;
}

- (void)addBillboardAtPosition:(GLKVector3)aPosition size:(GLKVector2)aSize minTextureCoords:(GLKVector2)minCoords maxTextureCoords:(GLKVector2)maxCoords
{
    UtilityBillboard *billboard = [[UtilityBillboard alloc] initWithPosition:aPosition size:aSize minTextureCoords:minCoords maxTextureCoords:maxCoords];
    [self addBillboard:billboard];
}

- (void)addBillboard:(UtilityBillboard *)aBillboard;
{
    [self.mutableSortedBillboards addObject:aBillboard];
}

- (void)updateWithEyePosition:(GLKVector3)eyePosition lookDirection:(GLKVector3)lookDirection
{
    // Make sure lookDirection is a unit vector
    lookDirection = GLKVector3Normalize(lookDirection);
    
    for(UtilityBillboard *currentBillboard in self.mutableSortedBillboards)
    {
        [currentBillboard updateWithEyePosition:eyePosition lookDirection:lookDirection];
    }
    
    // 对公告牌从远到近排序
    [self.mutableSortedBillboards sortUsingFunction:UtilityCompareBillboardDistance context:NULL];
}

@end
