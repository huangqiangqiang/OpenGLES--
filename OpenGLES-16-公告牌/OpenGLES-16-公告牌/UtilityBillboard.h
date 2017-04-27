//
//  UtilityBillboard.h
//  OpenGLES-16-公告牌
//
//  Created by 黄强强 on 17/4/27.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface UtilityBillboard : NSObject

@property (nonatomic, assign) GLKVector3 position;
@property (nonatomic, assign) GLKVector2 size;
@property (nonatomic, assign) GLKVector2 minTextureCoords;
@property (nonatomic, assign) GLKVector2 maxTextureCoords;

@property (assign, nonatomic) GLfloat distanceSquared;

/**
 <#Description#>
 
 @param aPosition 位置
 @param aSize 大小
 @param minCoords <#minCoords description#>
 @param maxCoords <#maxCoords description#>
 @return <#return value description#>
 */
- (id)initWithPosition:(GLKVector3)aPosition
                  size:(GLKVector2)aSize
      minTextureCoords:(GLKVector2)minCoords
      maxTextureCoords:(GLKVector2)maxCoords;

// 计算公告牌与眼睛位置之间的一个有符号的距离，当距离为负的时候就可以不用绘制
- (void)updateWithEyePosition:(GLKVector3)eyePosition lookDirection:(GLKVector3)lookDirection;

/**
 对公告牌从远到近排序
 */
NSComparisonResult UtilityCompareBillboardDistance(UtilityBillboard *a, UtilityBillboard *b, void *context);
@end
