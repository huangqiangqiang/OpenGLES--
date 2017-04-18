//
//  SceneModel.m
//  OpenGLES-9-灯光旗子
//
//  Created by 黄强强 on 17/4/12.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "SceneModel.h"

@interface SceneModel()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) SceneMesh *mesh;
@property (nonatomic, assign) GLsizei numberOfVertices;
@end

@implementation SceneModel

- (instancetype)initWithName:(NSString *)name mesh:(SceneMesh *)mesh numberOfVertices:(GLsizei)aCount
{
    if (self = [super init]) {
        self.name = name;
        self.mesh = mesh;
        self.numberOfVertices = aCount;
    }
    return self;
}

// 计算自己的边界
- (void)updateAlignedBoundingBoxForVertices:(float *)verts count:(unsigned int)aCount
{
    SceneAxisAllignedBoundingBox result = {{0, 0, 0},{0, 0, 0}};
    const GLKVector3 *positions = (const GLKVector3 *)verts;
    
    if(0 < aCount)
    {
        result.min.x = result.max.x = positions[0].x;
        result.min.y = result.max.y = positions[0].y;
        result.min.z = result.max.z = positions[0].z;
    }
    for(int i = 1; i < aCount; i++)
    {
        result.min.x = MIN(result.min.x, positions[i].x);
        result.min.y = MIN(result.min.y, positions[i].y);
        result.min.z = MIN(result.min.z, positions[i].z);
        result.max.x = MAX(result.max.x, positions[i].x);
        result.max.y = MAX(result.max.y, positions[i].y);
        result.max.z = MAX(result.max.z, positions[i].z);
    }
    
    self.axisAlignedBoundingBox = result;
}

- (void)draw
{
    [self.mesh prepareToDraw];
    [self.mesh drawUnindexedWithMode:GL_TRIANGLES startVertexIndex:0 count:self.numberOfVertices];
}

@end
