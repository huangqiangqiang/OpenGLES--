//
//  UtilityBillboard.m
//  OpenGLES-16-公告牌
//
//  Created by 黄强强 on 17/4/27.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "UtilityBillboard.h"

@interface UtilityBillboard()

@end

@implementation UtilityBillboard

- (id)initWithPosition:(GLKVector3)aPosition
                  size:(GLKVector2)aSize
      minTextureCoords:(GLKVector2)minCoords
      maxTextureCoords:(GLKVector2)maxCoords;
{
    if(nil != (self = [super init]))
    {
        self.position = aPosition;
        self.size = aSize;
        self.minTextureCoords = minCoords;
        self.maxTextureCoords = maxCoords;
    }
    return self;
}

// 计算公告牌与眼睛位置之间的一个有符号的距离，当距离为负的时候就可以不用绘制
- (void)updateWithEyePosition:(GLKVector3)eyePosition lookDirection:(GLKVector3)lookDirection
{
    const GLKVector3 vectorFromEye = GLKVector3Subtract(eyePosition, self.position);
    self.distanceSquared = GLKVector3DotProduct(vectorFromEye, lookDirection);
}


/**
 对公告牌从远到近排序
 */
NSComparisonResult UtilityCompareBillboardDistance(UtilityBillboard *a, UtilityBillboard *b, void *context)
{
    NSInteger result = NSOrderedSame;
    
    if (a.distanceSquared < b.distanceSquared)
    {
        result = NSOrderedDescending;
    }
    else if (a.distanceSquared > b.distanceSquared)
    {
        result = NSOrderedAscending;
    }
    
    return result;
}

@end
