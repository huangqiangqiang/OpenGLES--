//
//  SceneModel.h
//  OpenGLES-7-碰碰车
//
//  Created by 黄强强 on 17/3/27.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SceneMesh.h"

typedef struct {
    GLKVector3 min;
    GLKVector3 max;
}
SceneAxisAllignedBoundingBox;

@interface SceneModel : NSObject

@property (nonatomic, assign) SceneAxisAllignedBoundingBox axisAlignedBoundingBox;

- (instancetype)initWithName:(NSString *)name mesh:(SceneMesh *)mesh  numberOfVertices:(GLsizei)aCount;

- (void)draw;


/**
 计算每个物体自己的边界

 @param bumperRinkVerts <#bumperRinkVerts description#>
 @param count <#count description#>
 */
- (void)updateAlignedBoundingBoxForVertices:(float *)bumperRinkVerts count:(unsigned int)count;

@end
