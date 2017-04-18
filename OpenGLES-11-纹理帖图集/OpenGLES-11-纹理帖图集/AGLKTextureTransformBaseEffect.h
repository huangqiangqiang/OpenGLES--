//
//  AGLKTextureTransformBaseEffect.h
//  OpenGLES-9-灯光旗子
//
//  Created by 黄强强 on 17/4/12.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <GLKit/GLKit.h>


@interface AGLKTextureTransformBaseEffect : GLKBaseEffect

@property (assign, nonatomic) GLKVector4 light0Position;
@property (assign, nonatomic) GLKVector3 light0SpotDirection;
@property (assign, nonatomic) GLKVector4 light1Position;
@property (assign, nonatomic) GLKVector3 light1SpotDirection;
@property (assign, nonatomic) GLKVector4 light2Position;

/**
 纹理矩阵1
 */
@property (nonatomic, assign) GLKMatrix4 textureMatrix2d0;
@property (nonatomic, assign) GLKMatrix4 textureMatrix2d1;

- (void)prepareToDrawMultitextures;

@end
