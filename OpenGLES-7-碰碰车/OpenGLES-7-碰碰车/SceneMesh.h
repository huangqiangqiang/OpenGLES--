//
//  SceneMesh.h
//  OpenGLES-7-碰碰车
//
//  Created by 黄强强 on 17/3/27.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface SceneMesh : NSObject

- (instancetype)initWithPositionCoords:(float *)somePositions normalCoords:(float *)someNormals textureCoords:(float *)someTexCoords numberOfPositions:(size_t)countPositions;

- (void)prepareToDraw;

- (void)drawUnidexedWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count;

@end
