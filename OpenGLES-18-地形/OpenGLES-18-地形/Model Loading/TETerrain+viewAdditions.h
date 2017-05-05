//
//  TETerrain+viewAdditions.h
//  OpenGLES-18-地形
//
//  Created by 黄强强 on 17/5/3.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "TETerrain.h"
#import "UtilityCamera.h"
#import "UtilityTerrainEffect.h"
#import "UtilityPickTerrainEffect.h"

typedef enum
{
    TETerrainPositionAttrib,
    TETerrainNumberOfAttributes
} TETerrainAttribute;

@interface TETerrain (viewAdditions)


/**
 分割整个地形为一个个的小瓦片

 @return <#return value description#>
 */
- (NSArray *)tiles;

- (void)prepareTerrainAttributes;

- (void)drawTerrainWithinTiles:(NSArray *)tiles withCamera:(UtilityCamera *)aCamera terrainEffect:(UtilityTerrainEffect *)aTerrainEffect;

- (void)prepareToPickTerrain:(NSArray *)tiles
                  withCamera:(UtilityCamera *)aCamera
                  pickEffect:(UtilityPickTerrainEffect *)aPickEffect;

@end
