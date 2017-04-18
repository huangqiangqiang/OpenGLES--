//
//  SceneModel.h
//  OpenGLES-9-灯光旗子
//
//  Created by 黄强强 on 17/4/12.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SceneMesh.h"

typedef struct {
    GLKVector3 min;
    GLKVector3 max;
}
SceneAxisAllignedBoundingBox;

@interface SceneModel : NSObject

- (instancetype)initWithName:(NSString *)name mesh:(SceneMesh *)mesh numberOfVertices:(GLsizei)aCount;

- (void)draw;

@property (nonatomic, assign) SceneAxisAllignedBoundingBox axisAlignedBoundingBox;

- (void)updateAlignedBoundingBoxForVertices:(float *)verts count:(unsigned int)aCount;
@end
