//
//  SceneCanLightModel.m
//  OpenGLES-9-灯光旗子
//
//  Created by 黄强强 on 17/4/12.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "SceneCanLightModel.h"
#import "SceneMesh.h"
#import "canLight.h"

@implementation SceneCanLightModel

- (instancetype)init
{
    SceneMesh *canLightMesh = [[SceneMesh alloc] initWithPositionCoords:canLightVerts normalCoords:canLightNormals texCoords0:NULL numberOfPositions:canLightNumVerts indices:NULL numberOfIndices:0];
    
    if (self = [super initWithName:@"canLight" mesh:canLightMesh numberOfVertices:canLightNumVerts]) {
        [super updateAlignedBoundingBoxForVertices:canLightVerts count:canLightNumVerts];
    }
    return self;
}

@end
