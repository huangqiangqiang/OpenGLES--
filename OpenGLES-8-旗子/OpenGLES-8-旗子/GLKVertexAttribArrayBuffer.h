//
//  GLKVertexAttribArrayBuffer.h
//  OpenGLES-8-旗子
//
//  Created by 黄强强 on 17/4/11.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface GLKVertexAttribArrayBuffer : NSObject

- (instancetype)initWithStride:(GLsizei)stride count:(GLsizei)count bytes:(const void *)dataPtr usage:(GLenum)usage;
- (void)reinitWithStride:(GLsizei)stride count:(GLsizei)count bytes:(const void *)dataPtr;


/**
 <#Description#>

 @param index GLKVertexAttribPosition、GLKVertexAttribNormal、GLKVertexAttribTexCoord0...
 @param count index类型的顶点有几个分量
 */
- (void)prepareToDrawWithAttrib:(GLuint)index numberOfCoordinates:(GLint)count offset:(GLsizeiptr)offset;
@end
