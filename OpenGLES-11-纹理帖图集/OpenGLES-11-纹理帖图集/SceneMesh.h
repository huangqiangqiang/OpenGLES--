//
//  SceneMesh.h
//  OpenGLES-8-旗子
//
//  Created by 黄强强 on 17/4/11.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector2 texCoords0;
}
SceneMeshVertex;

@interface SceneMesh : NSObject

- (instancetype)initWithVertexAttributeData:(NSData *)vertexAttributes indexData:(NSData *)indices;
- (instancetype)initWithPositionCoords:(const GLfloat *)positions normalCoords:(GLfloat *)normals texCoords0:(GLfloat *)texCoords0 numberOfPositions:(size_t)countPositions indices:(GLushort *)indices numberOfIndices:(size_t)countIndices;

@property (nonatomic, strong, readonly) NSData *vertexData;
@property (nonatomic, strong, readonly) NSData *indexData;

- (void)prepareToDraw;

- (void)drawUnindexedWithMode:(GLenum)index startVertexIndex:(GLint)first count:(GLsizei)count;

- (void)makeDynamicAndUpdateWithVertices:(const SceneMeshVertex *)someVerts numberOfVertices:(GLsizei)count;
@end
