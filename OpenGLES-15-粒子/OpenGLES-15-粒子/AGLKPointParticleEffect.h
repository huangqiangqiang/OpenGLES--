//
//  AGLKPointParticleEffect.h
//  OpenGLES-15-粒子
//
//  Created by 黄强强 on 17/4/19.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <GLKit/GLKit.h>

extern const GLKVector3 AGLKDefaultGravity;

@interface AGLKPointParticleEffect : NSObject <GLKNamedEffect>

@property (nonatomic, assign) GLKVector3 gravity;
@property (nonatomic, assign) GLfloat elapsedSeconds;
@property (nonatomic, readonly) GLKEffectPropertyTexture *texture2d0, *texture2d1;
@property (nonatomic, readonly) GLKEffectPropertyTransform *transform;

/**
 初始化
 
 @param aPosition 初始位置
 @param aVelocity 速度
 @param aForce 力向量
 @param aSize 尺寸
 @param aSpan 栗子的寿命
 @param aDuration 淡出的时间
 */
- (void)addParticleAtPosition:(GLKVector3)aPosition velocity:(GLKVector3)aVelocity force:(GLKVector3)aForce size:(float)aSize lifeSpanSeconds:(NSTimeInterval)aSpan fadeDurationSeconds:(NSTimeInterval)aDuration;

- (void)prepareToDraw;

- (void)draw;

@end
