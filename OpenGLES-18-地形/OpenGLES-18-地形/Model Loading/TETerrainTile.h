//
//  TETerrainTile.h
//  OpenGLES-18-地形
//
//  Created by 黄强强 on 17/5/3.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "TETerrain.h"
#import "TEModelPlacement.h"

@interface TETerrainTile : NSObject

@property (assign, nonatomic) NSInteger originX;
@property (assign, nonatomic) NSInteger originY;

- (instancetype)initWithTerrain:(TETerrain *)aTerrain
          tileOriginX:(NSInteger)x
          tileOriginY:(NSInteger)y
            tileWidth:(NSInteger)aWidth
           tileLength:(NSInteger)aLength;


- (void)manageContainedModelPlacements:(NSSet *)somePlacements;

- (void)draw;

@end

static const NSInteger TETerrainTileDefaultWidth = 32;
static const NSInteger TETerrainTileDefaultLength = 32;
