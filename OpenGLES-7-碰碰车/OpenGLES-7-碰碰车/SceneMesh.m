//
//  SceneMesh.m
//  OpenGLES-7-碰碰车
//
//  Created by 黄强强 on 17/3/27.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "SceneMesh.h"
#import <GLKit/GLKit.h>
#import "AGLKVertexAttribArrayBuffer.h"

typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector2 texCoords0;
}
SceneMeshVertex;

@interface SceneMesh()
@property (nonatomic, strong) NSMutableData *vertexAttributesData;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexAttributeBuffer;
@end

@implementation SceneMesh

- (instancetype)initWithPositionCoords:(float *)somePositions normalCoords:(float *)someNormals textureCoords:(float *)someTexCoords numberOfPositions:(size_t)countPositions
{
    NSParameterAssert(NULL != somePositions);
    NSParameterAssert(NULL != someNormals);
    NSParameterAssert(0 < countPositions);
    
    NSMutableData *vertexAttributesData = [[NSMutableData alloc] init];
    
    for (int i = 0; i < countPositions; i++) {
        SceneMeshVertex vertex;
        vertex.position.x = somePositions[i * 3 + 0];
        vertex.position.y = somePositions[i * 3 + 1];
        vertex.position.z = somePositions[i * 3 + 2];
        
        vertex.normal.x = someNormals[i * 3 + 0];
        vertex.normal.y = someNormals[i * 3 + 1];
        vertex.normal.z = someNormals[i * 3 + 2];
        
        if (NULL != someTexCoords) {
            vertex.texCoords0.s = someTexCoords[i * 2 + 0];
            vertex.texCoords0.t = someTexCoords[i * 2 + 1];
        } else {
            vertex.texCoords0.s = 0.0;
            vertex.texCoords0.t = 0.0;
        }
        [vertexAttributesData appendBytes:&vertex length:sizeof(vertex)];
    }
    
    return [self initWithVertexAttributesData:vertexAttributesData];
}

- (instancetype)initWithVertexAttributesData:(NSMutableData *)vertexAttributesData
{
    if (self = [super init]) {
        self.vertexAttributesData = vertexAttributesData;
    }
    return self;
}

- (void)prepareToDraw
{
    if (self.vertexAttributeBuffer == nil && self.vertexAttributesData.length > 0) {
        self.vertexAttributeBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneMeshVertex) numberOfVertices:(GLsizei)[self.vertexAttributesData length] / sizeof(SceneMeshVertex) bytes:[self.vertexAttributesData bytes] usage:GL_STATIC_DRAW];
    }
    
    [self.vertexAttributeBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneMeshVertex, position) shouldEnable:YES];
    [self.vertexAttributeBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:offsetof(SceneMeshVertex, normal) shouldEnable:YES];
    [self.vertexAttributeBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneMeshVertex, texCoords0) shouldEnable:YES];
}

- (void)drawUnidexedWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count
{
    [self.vertexAttributeBuffer drawArrayWithMode:mode startVertexIndex:first numberOfVertices:count];
}

@end
