//
//  GLKVertexAttribArrayBuffer.m
//  OpenGLES-8-旗子
//
//  Created by 黄强强 on 17/4/11.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "GLKVertexAttribArrayBuffer.h"

@interface GLKVertexAttribArrayBuffer()
@property (nonatomic, assign) GLuint name;
@property (nonatomic, assign) GLsizei stride;
@end
@implementation GLKVertexAttribArrayBuffer

- (instancetype)initWithStride:(GLsizei)stride count:(GLsizei)count bytes:(const void *)dataPtr usage:(GLenum)usage
{
    if (self = [super init]) {
        glGenBuffers(1, &_name);
        glBindBuffer(GL_ARRAY_BUFFER, self.name);
        self.stride = stride;
        GLsizeiptr size = stride * count;
        /*
         size就是data占用的内存大小（字节数）,如果data初始化的时候指定了大小，则使用sizeof(data)就可以算出size，如果初始化的时候没有指定大小，则必须自己算，不能用sizeof函数
         dataPtr 就是data的起始指针
         */
        
        glBufferData(GL_ARRAY_BUFFER, size, dataPtr, usage);
    }
    return self;
}

- (void)reinitWithStride:(GLsizei)stride count:(GLsizei)count bytes:(const void *)dataPtr
{
    self.stride = stride;
    glGenBuffers(1, &_name);
    glBindBuffer(GL_ARRAY_BUFFER, self.name);
    glBufferData(GL_ARRAY_BUFFER, stride * count, dataPtr, GL_DYNAMIC_DRAW);
}

- (void)prepareToDrawWithAttrib:(GLuint)index numberOfCoordinates:(GLint)count offset:(GLsizeiptr)offset
{
    glBindBuffer(GL_ARRAY_BUFFER, self.name);
    glEnableVertexAttribArray(index);
    glVertexAttribPointer(index, count, GL_FLOAT, GL_FALSE, self.stride, NULL + offset);
}

@end
