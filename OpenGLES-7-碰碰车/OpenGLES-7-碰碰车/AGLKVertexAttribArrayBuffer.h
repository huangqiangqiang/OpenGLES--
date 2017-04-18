//
//  AGLKVertexAttribArrayBuffer.h
//  OpenGLES-7-碰碰车
//
//  Created by 黄强强 on 17/3/28.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface AGLKVertexAttribArrayBuffer : NSObject


/**
 创建顶点数据

 @param stride 有多少个分量
 @param count 有多少个顶点
 @param dataPtr 数据
 @param usage 指定GPU分配的内存区域，需不需要经常修改
 */
- (instancetype)initWithAttribStride:(GLsizei)stride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr usage:(GLenum)usage;


/**
 在draw之前赋值顶点数据

 @param index 顶点类型（position，normal，texture）
 @param count 一个顶点有几个分量
 @param offset 顶点在数据中的初始位置偏移量
 @param shouldEnable 是否enable
 */
- (void)prepareToDrawWithAttrib:(GLuint)index numberOfCoordinates:(GLint)count attribOffset:(GLsizeiptr)offset shouldEnable:(BOOL)shouldEnable;


/**
 绘制

 @param mode 绘制类型
 @param first <#first description#>
 @param count <#count description#>
 */
- (void)drawArrayWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count;

@end
