//
//  SceneCarModel.m
//  OpenGLES-7-碰碰车
//
//  Created by 黄强强 on 17/3/28.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "SceneCarModel.h"
#import "bumperCar.h"

@implementation SceneCarModel

- (instancetype)init
{
    SceneMesh *mesh = [[SceneMesh alloc] initWithPositionCoords:bumperCarVerts normalCoords:bumperCarNormals textureCoords:NULL numberOfPositions:bumperCarNumVerts];
    
    self = [super initWithName:@"bumperCar" mesh:mesh numberOfVertices:bumperCarNumVerts];
    if (self) {
        [self updateAlignedBoundingBoxForVertices:bumperCarVerts count:bumperCarNumVerts];
    }
    return self;
}

@end
