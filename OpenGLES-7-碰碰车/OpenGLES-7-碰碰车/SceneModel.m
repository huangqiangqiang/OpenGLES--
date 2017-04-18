//
//  SceneModel.m
//  OpenGLES-7-碰碰车
//
//  Created by 黄强强 on 17/3/27.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "SceneModel.h"

@interface SceneModel()
@property (nonatomic, strong) SceneMesh *mesh;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) GLsizei numberOfVertices;
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

- (void)draw
{
    [self.mesh prepareToDraw];
    [self.mesh drawUnidexedWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:self.numberOfVertices];
}


- (void)updateAlignedBoundingBoxForVertices:(float *)bumperRinkVerts count:(unsigned int)count
{
    SceneAxisAllignedBoundingBox result = {{0.0,0.0,0.0},{0.0,0.0,0.0}};
    
    if (0 < count) {
        result.min.x = result.max.x = bumperRinkVerts[0];
        result.min.y = result.max.y = bumperRinkVerts[1];
        result.min.z = result.max.z = bumperRinkVerts[2];
    }
    for (int i = 0; i < count; i++) {
        result.min.x = MIN(result.min.x, bumperRinkVerts[i * 3 + 0]);
        result.min.y = MIN(result.min.y, bumperRinkVerts[i * 3 + 1]);
        result.min.z = MIN(result.min.z, bumperRinkVerts[i * 3 + 2]);
        result.max.x = MAX(result.max.x, bumperRinkVerts[i * 3 + 0]);
        result.max.y = MAX(result.max.y, bumperRinkVerts[i * 3 + 1]);
        result.max.z = MAX(result.max.z, bumperRinkVerts[i * 3 + 2]);
    }
    self.axisAlignedBoundingBox = result;
}

@end
