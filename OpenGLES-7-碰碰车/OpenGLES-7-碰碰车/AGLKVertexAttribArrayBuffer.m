//
//  AGLKVertexAttribArrayBuffer.m
//  OpenGLES-7-碰碰车
//
//  Created by 黄强强 on 17/3/28.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "AGLKVertexAttribArrayBuffer.h"

@interface AGLKVertexAttribArrayBuffer()

/**
 一个顶点到下一个顶点之间的间隔
 */
@property (nonatomic, assign) GLsizei stride;

/**
 bufferID
 */
@property (nonatomic, assign) GLuint name;

/**
 数据总大小
 */
@property (nonatomic, assign) GLint bufferSizeBytes;
@end

@implementation AGLKVertexAttribArrayBuffer

- (instancetype)initWithAttribStride:(GLsizei)aStride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr usage:(GLenum)usage
{
    NSParameterAssert(0 < aStride);
    NSAssert((0 < count && NULL != dataPtr) || (0 == count && NULL == dataPtr), @"data must not be NULL or count > 0");
    
    if(nil != (self = [super init])) {
        _stride = aStride;
        _bufferSizeBytes = _stride * count;
        
        glGenBuffers(1,&_name);
        glBindBuffer(GL_ARRAY_BUFFER,self.name);
        /*
         buffer类型
         需要拷贝的数据大小
         拷贝的数据
         指定GPU分配的内存区域，需不需要经常修改
         */
        glBufferData(GL_ARRAY_BUFFER, _bufferSizeBytes, dataPtr, usage);
        
        NSAssert(0 != _name, @"Failed to generate name");
    }
    
    return self;
}

- (void)prepareToDrawWithAttrib:(GLuint)index numberOfCoordinates:(GLint)count attribOffset:(GLsizeiptr)offset shouldEnable:(BOOL)shouldEnable
{
    NSParameterAssert((0 < count) && (count < 4));
    NSParameterAssert(offset < self.stride);
    NSAssert(0 != _name, @"Invalid name");
    
    glBindBuffer(GL_ARRAY_BUFFER,self.name);
    
    if(shouldEnable) {
        glEnableVertexAttribArray(index);
    }
    
    glVertexAttribPointer(index,count,GL_FLOAT,GL_FALSE,(self.stride),NULL + offset);
}

- (void)drawArrayWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count
{
    glDrawArrays(mode, first, count);
}

@end
