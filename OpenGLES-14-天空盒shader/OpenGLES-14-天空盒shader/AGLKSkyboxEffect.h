//
//  AGLKSkyboxEffect.h
//  OpenGLES-14-天空盒shader
//
//  Created by 黄强强 on 17/4/18.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface AGLKSkyboxEffect : NSObject <GLKNamedEffect>
@property (nonatomic, assign) GLKVector3 center;
@property (nonatomic, assign) float xSize, ySize, zSize;
@property (nonatomic, readonly) GLKEffectPropertyTexture *textureCubeMap;
@property (nonatomic, readonly) GLKEffectPropertyTransform *transform;

- (void)prepareToDraw;
- (void)draw;
@end
