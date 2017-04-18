//
//  SceneAnimateMesh.h
//  OpenGLES-8-旗子
//
//  Created by 黄强强 on 17/4/11.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "SceneMesh.h"

@interface SceneAnimateMesh : SceneMesh

- (void)updateMeshWithElapsedTime:(NSTimeInterval)anInterval;
- (void)drawEntireMesh;

@end
