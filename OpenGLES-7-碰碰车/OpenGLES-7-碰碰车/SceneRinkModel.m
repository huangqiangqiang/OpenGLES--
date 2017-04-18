//
//  SceneRinkModel.m
//  OpenGLES-7-碰碰车
//
//  Created by 黄强强 on 17/3/27.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "SceneRinkModel.h"
#import "SceneMesh.h"
#import "bumperRink.h"
#import <GLKit/GLKit.h>


@interface SceneRinkModel()
@end

@implementation SceneRinkModel

- (instancetype)init
{
    SceneMesh *rinkMesh = [[SceneMesh alloc] initWithPositionCoords:bumperRinkVerts normalCoords:bumperRinkNormals textureCoords:NULL numberOfPositions:bumperRinkNumVerts];
    self = [super initWithName:@"bumberRink" mesh:rinkMesh numberOfVertices:bumperRinkNumVerts];
    if (self) {
        // 计算场地的边界
        [self updateAlignedBoundingBoxForVertices:bumperRinkVerts count:bumperRinkNumVerts];
    }
    return self;
}

@end
