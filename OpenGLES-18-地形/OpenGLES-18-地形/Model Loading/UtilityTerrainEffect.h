//
//  UtilityTerrainEffect.h
//  OpenGLES-18-地形
//
//  Created by 黄强强 on 17/5/3.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "UtilityEffect.h"
#import "TETerrain.h"
#import "UtilityTextureInfo.h"

enum
{
    TETerrainMVPMatrix,
    TETerrainTexureMatrices,
    TETerrainSamplers2D,
    TETerrainGlobalAmbientColor,
    TETerrainNumUniforms
};

@interface UtilityTerrainEffect : UtilityEffect

/**
 全局环境光
 */
@property (assign, nonatomic) GLKVector4 globalAmbientLightColor;

@property (assign, nonatomic) GLKMatrix4 projectionMatrix;
@property (assign, nonatomic) GLKMatrix4 modelviewMatrix;

@property (strong, nonatomic) UtilityTextureInfo *lightAndWeightsTextureInfo;
@property (strong, nonatomic) UtilityTextureInfo *detailTextureInfo0;
@property (strong, nonatomic) UtilityTextureInfo *detailTextureInfo1;
@property (strong, nonatomic) UtilityTextureInfo *detailTextureInfo2;
@property (strong, nonatomic) UtilityTextureInfo *detailTextureInfo3;

// Designated initializer
- (instancetype)initWithTerrain:(TETerrain *)aTerrain;

@end
