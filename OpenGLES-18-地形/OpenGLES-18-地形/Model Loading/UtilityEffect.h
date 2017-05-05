//
//  UtilityEffect.h
//  OpenGLES-18-地形
//
//  Created by 黄强强 on 17/5/3.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface UtilityEffect : NSObject <GLKNamedEffect>

@property (assign, nonatomic, readonly) GLuint program;

- (void)prepareOpenGL;
- (void)updateUniformValues;

// Required overrides
- (void)bindAttribLocations;
- (void)configureUniformLocations;

- (BOOL)loadShadersWithName:(NSString *)aShaderName;
@end
