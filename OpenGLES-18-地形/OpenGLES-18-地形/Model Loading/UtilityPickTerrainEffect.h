//
//  UtilityPickTerrainEffect.h
//  OpenGLES-18-地形
//
//  Created by 黄强强 on 17/5/4.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "UtilityEffect.h"
#import "TETerrain.h"


typedef struct
{
    GLKVector2 position;
    unsigned char modelIndex;
}
TEPickTerrainInfo;

@interface UtilityPickTerrainEffect : UtilityEffect

@property(assign, nonatomic) GLKMatrix4 projectionMatrix;
@property(assign, nonatomic) GLKMatrix4 modelviewMatrix;
@property(assign, nonatomic) unsigned char modelIndex;

- (instancetype)initWithTerrain:(TETerrain *)aTerrain;

- (TEPickTerrainInfo)terrainInfoForProjectionPosition:(GLKVector2)aPosition;

@end
