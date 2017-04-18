//
//  SceneMesh.m
//  OpenGLES-8-旗子
//
//  Created by 黄强强 on 17/4/11.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "SceneMesh.h"
#import "GLKVertexAttribArrayBuffer.h"

@interface SceneMesh()
@property (nonatomic, strong) NSData *vertexData;
@property (nonatomic, strong) NSData *indexData;
@property (nonatomic, strong) GLKVertexAttribArrayBuffer *vertexAttribBuffer;
@property (nonatomic, assign) GLuint indexBufferID;
@end

@implementation SceneMesh

- (instancetype)initWithVertexAttributeData:(NSData *)vertexAttributes indexData:(NSData *)indices
{
    if (self = [super init]) {
        self.vertexData = vertexAttributes;
        self.indexData = indices;
    }
    return self;
}


- (void)prepareToDraw
{
    // NSData的lenth方法返回data有多少个字节
    if (self.vertexAttribBuffer == nil && [self.vertexData length] > 0) {
        self.vertexAttribBuffer = [[GLKVertexAttribArrayBuffer alloc] initWithStride:sizeof(SceneMeshVertex) count:(GLsizei)[self.vertexData length] / sizeof(SceneMeshVertex) bytes:[self.vertexData bytes] usage:GL_STATIC_DRAW];
        
        self.vertexData = nil;
    }
    
    if (self.indexBufferID == 0 && [self.indexData length] > 0) {
        glGenBuffers(1, &_indexBufferID);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBufferID);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, [self.indexData length], [self.indexData bytes], GL_STATIC_DRAW);
        
        self.indexData = nil;
    }

    [self.vertexAttribBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 offset:offsetof(SceneMeshVertex, position)];
    [self.vertexAttribBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 offset:offsetof(SceneMeshVertex, normal)];
    [self.vertexAttribBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 offset:offsetof(SceneMeshVertex, texCoords0)];
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBufferID);
}

/////////////////////////////////////////////////////////////////
// This method sends count sets of vertex attributes read from
// someVerts to the GPU. This method also marks the resulting
// vertex attribute array as a dynamic array prone to frequent
// updates.
- (void)makeDynamicAndUpdateWithVertices:(const SceneMeshVertex *)someVerts numberOfVertices:(GLsizei)count
{
    NSParameterAssert(NULL != someVerts);
    NSParameterAssert(0 < count);
    
    if(nil == self.vertexAttribBuffer)
    {
        // vertex attiributes haven't been sent to GPU yet
        self.vertexAttribBuffer = [[GLKVertexAttribArrayBuffer alloc] initWithStride:sizeof(SceneMeshVertex) count:count bytes:[self.vertexData bytes] usage:GL_DYNAMIC_DRAW];
    }
    else
    {
        [self.vertexAttribBuffer reinitWithStride:sizeof(SceneMeshVertex) count:count bytes:someVerts];
    }
}

@end
