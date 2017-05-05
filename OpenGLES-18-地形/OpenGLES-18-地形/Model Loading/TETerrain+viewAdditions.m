//
//  TETerrain+viewAdditions.m
//  OpenGLES-18-地形
//
//  Created by 黄强强 on 17/5/3.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "TETerrain+viewAdditions.h"
#import "TETerrainTile.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

@implementation TETerrain (viewAdditions)

- (NSArray *)tiles;
{
    NSMutableArray *tilesArray = [NSMutableArray array];
    const NSInteger constLength = self.length;
    const NSInteger constWidth = self.width;
    
    for(NSInteger j = 0; j < constLength; j += (TETerrainTileDefaultLength - 1))
    {
        for(NSInteger i = 0; i < constWidth; i += (TETerrainTileDefaultWidth - 1))
        {
            TETerrainTile *tile = [[TETerrainTile alloc]
                                   initWithTerrain:self
                                   tileOriginX:i
                                   tileOriginY:j
                                   tileWidth:MIN(constWidth - i, TETerrainTileDefaultWidth)
                                   tileLength:MIN(constLength - j, TETerrainTileDefaultLength)];
            
            [tilesArray addObject:tile];
            
            // 应该是把瓦片放到相应的展示的位置上
            [tile manageContainedModelPlacements:self.modelPlacements];
        }
    }
    
    return tilesArray;
}

- (void)prepareTerrainAttributes
{
    if (self.glVertexAttributeBufferID == 0) {
        GLuint glName;
        glGenBuffers(1, &glName);
        glBindBuffer(GL_ARRAY_BUFFER, glName);
        glBufferData(GL_ARRAY_BUFFER, [self.positionAttributesData length], [self.positionAttributesData bytes], GL_STATIC_DRAW);
        self.glVertexAttributeBufferID = glName;
    }
    else{
        glBindBuffer(GL_ARRAY_BUFFER, self.glVertexAttributeBufferID);
    }
    glEnableVertexAttribArray(TETerrainPositionAttrib);
}

- (void)drawTerrainWithinTiles:(NSArray *)tiles
                    withCamera:(UtilityCamera *)aCamera
                 terrainEffect:(UtilityTerrainEffect *)aTerrainEffect;
{
    glBindVertexArray(0);
    
    aTerrainEffect.projectionMatrix = aCamera.projectionMatrix;
    aTerrainEffect.modelviewMatrix = aCamera.modelviewMatrix;
    
    // 准备顶点数据
    [self prepareTerrainAttributes];
    [aTerrainEffect prepareToDraw];
    
    // 绘制地形
    [self drawTiles:tiles];
}

- (void)drawTiles:(NSArray *)tiles;
{
    for(TETerrainTile *tile in tiles)
    {
        glVertexAttribPointer(TETerrainPositionAttrib,
                              3,
                              GL_FLOAT,
                              GL_FALSE,
                              sizeof(GLKVector3),
                              ((GLKVector3 *)NULL) +
                              (tile.originY * self.width) +
                              tile.originX);
        
        [tile draw];
    }
}

- (void)prepareToPickTerrain:(NSArray *)tiles
                  withCamera:(UtilityCamera *)aCamera
                  pickEffect:(UtilityPickTerrainEffect *)aPickEffect;
{
    glBindVertexArray(0);
    
    // Draw the terrain for tiles that weren't culled
    aPickEffect.modelIndex = 0;
    aPickEffect.projectionMatrix = aCamera.projectionMatrix;
    aPickEffect.modelviewMatrix = aCamera.modelviewMatrix;
    
    [self prepareTerrainAttributes];
    [aPickEffect prepareToDraw];
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self drawTiles:tiles];
}

@end
