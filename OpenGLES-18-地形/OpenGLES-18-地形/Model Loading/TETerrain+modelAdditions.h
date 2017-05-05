//
//  TETerrain+modelAdditions.h
//  OpenGLES-18-地形
//
//  Created by 黄强强 on 17/5/4.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "TETerrain.h"
#import <GLKit/GLKit.h>

@interface TETerrain (modelAdditions)


- (GLfloat)widthMeters;
- (GLfloat)heightMeters;
- (GLfloat)lengthMeters;

- (GLfloat)calculatedHeightAtXPosMeters:(GLfloat)x
                             zPosMeters:(GLfloat)z
                          surfaceNormal:(GLKVector3 *)aNormal;
@end
