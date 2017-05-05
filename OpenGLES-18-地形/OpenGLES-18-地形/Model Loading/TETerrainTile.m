//
//  TETerrainTile.m
//  OpenGLES-18-地形
//
//  Created by 黄强强 on 17/5/3.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "TETerrainTile.h"

@interface TETerrainTile()
@property (strong, nonatomic) TETerrain *terrain;
@property (strong, nonatomic, readwrite) NSMutableSet *modelPlacements;

@property (assign, nonatomic) NSInteger tileWidth;
@property (assign, nonatomic) NSInteger tileLength;

@property (strong, nonatomic) NSData *indexData;
@property (assign, nonatomic) GLsizei numberOfIndices;
@property (nonatomic, assign) GLuint indexBufferID;
@end

@implementation TETerrainTile

- (id)initWithTerrain:(TETerrain *)aTerrain
          tileOriginX:(NSInteger)x
          tileOriginY:(NSInteger)y
            tileWidth:(NSInteger)aWidth
           tileLength:(NSInteger)aLength
{
    if(nil != (self = [super init]))
    {
        self.terrain = aTerrain;
        self.originX = x;
        self.originY = y;
        self.tileWidth = aWidth;
        self.tileLength = aLength;
        
        // 算出索引坐标
        self.indexData = [self generateIndicesForTileOriginX:x tileOriginY:y tileWidth:aWidth tileLength:aLength];
        self.numberOfIndices = (GLsizei)([self.indexData length] / sizeof(GLushort));
        
        self.modelPlacements = [NSMutableSet set];
    }
    
    return self;
}


// 返回顶点索引数据
- (NSData *)generateIndicesForTileOriginX:(NSInteger)x
                              tileOriginY:(NSInteger)y
                                tileWidth:(NSInteger)aWidth
                               tileLength:(NSInteger)aLength
{
    NSMutableData *indices = [NSMutableData data];
    
    const NSInteger constTerrainWidth = self.terrain.width;
    
    NSInteger i = 0;
    NSInteger j = 0;
    
    // 这个索引序列产生具有退化顶点的三角形条，所以可以通过单次调用glDrawElements（）来渲染整个图块。
    while(j < (aLength - 1))
    {
        for(i = 0; i < (aWidth - 1); i++)
        {
            // lower left
            GLushort currentIndex = i + (j + 0) * constTerrainWidth;
            [indices appendBytes:&currentIndex
                          length:sizeof(currentIndex)];
            
            // upper left
            currentIndex = i + (j + 1) * constTerrainWidth;
            [indices appendBytes:&currentIndex
                          length:sizeof(currentIndex)];
        }
        {
            // lower left (i always equals aWidth - 1 here)
            GLushort currentIndex = i + (j + 0) * constTerrainWidth;
            [indices appendBytes:&currentIndex
                          length:sizeof(currentIndex)];
            
            // upper left
            currentIndex = i + (j + 1) * constTerrainWidth;
            [indices appendBytes:&currentIndex
                          length:sizeof(currentIndex)];
            [indices appendBytes:&currentIndex
                          length:sizeof(currentIndex)];
        }
        j++;
        
        if(j < (aLength - 1))
        {
            for(i = aWidth - 1; i > 0; i--)
            {
                // lower left
                GLushort currentIndex = i + (j + 0) * constTerrainWidth;
                [indices appendBytes:&currentIndex
                              length:sizeof(currentIndex)];
                
                // upper left
                currentIndex = i + (j + 1) * constTerrainWidth;
                [indices appendBytes:&currentIndex
                              length:sizeof(currentIndex)];
            }
            {
                // lower left (i always equals 0 here)
                GLushort currentIndex = i + (j + 0) * constTerrainWidth;
                [indices appendBytes:&currentIndex
                              length:sizeof(currentIndex)];
                
                // upper left
                currentIndex = i + (j + 1) * constTerrainWidth;
                [indices appendBytes:&currentIndex
                              length:sizeof(currentIndex)];
                [indices appendBytes:&currentIndex
                              length:sizeof(currentIndex)];
            }            
            j++;
        }
    }
    
    {           
        // lower left (j always equals length - 1 here)
        // i is either equal to width-1 or to 0
        GLushort currentIndex = i + (j + 0) * constTerrainWidth; 
        [indices appendBytes:&currentIndex 
                      length:sizeof(currentIndex)];
    }
    
    return indices;
}

- (void)manageContainedModelPlacements:(NSSet *)somePlacements;
{
    for(TEModelPlacement *currentPlacement in somePlacements)
    {
        GLKVector3 position =
        {
            currentPlacement.positionX,
            currentPlacement.positionY,
            currentPlacement.positionZ
        };
        
        if(position.x >= self.originX &&
           position.x < (self.originX + self.tileWidth) &&
           position.z >= self.originY &&
           position.z < (self.originY + self.tileLength))
        {
            [self.modelPlacements addObject:currentPlacement];
        }
    }
}

- (void)draw
{
    if (self.indexBufferID == 0 && [self.indexData length] > 0) {
        GLuint buffer;
        glGenBuffers(1, &buffer);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffer);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, [self.indexData length], [self.indexData bytes], GL_STATIC_DRAW);
        self.indexBufferID = buffer;
        self.indexData = nil;
    }
    else{
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBufferID);
    }
    glDrawElements(GL_TRIANGLE_STRIP, self.numberOfIndices, GL_UNSIGNED_SHORT, NULL);
}

@end
