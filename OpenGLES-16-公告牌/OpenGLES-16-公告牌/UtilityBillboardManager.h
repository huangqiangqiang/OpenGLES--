//
//  UtilityBillboardManager.h
//  OpenGLES-16-公告牌
//
//  Created by 黄强强 on 17/4/26.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface UtilityBillboardManager : NSObject

@property (strong, nonatomic) NSMutableArray *mutableSortedBillboards;

/**
 添加一棵树

 @param aPosition 树的位置
 @param aSize 树的大小
 @param minCoords 纹理坐标
 @param maxCoords 纹理坐标
 */
- (void)addBillboardAtPosition:(GLKVector3)aPosition
                          size:(GLKVector2)aSize
              minTextureCoords:(GLKVector2)minCoords
              maxTextureCoords:(GLKVector2)maxCoords;


/**
 <#Description#>

 @param eyePosition <#eyePosition description#>
 @param lookDirection <#lookDirection description#>
 */
- (void)updateWithEyePosition:(GLKVector3)eyePosition
                lookDirection:(GLKVector3)lookDirection;
@end
