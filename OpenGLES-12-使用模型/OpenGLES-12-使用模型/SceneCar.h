//
//  SceneCar.h
//  OpenGLES-12-使用模型
//
//  Created by 黄强强 on 17/4/17.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UtilityModel.h"
#import "AGLKAxisAllignedBoundingBox.h"

@protocol SceneCarControllerProtocol

- (NSTimeInterval)timeSinceLastUpdate;
- (AGLKAxisAllignedBoundingBox)rinkBoundingBox;
- (NSArray *)cars;

@end

@interface SceneCar : NSObject

@property (strong, nonatomic, readonly) UtilityModel *model;
@property (assign, nonatomic, readonly) GLKVector3 position;
@property (assign, nonatomic, readonly) GLKVector3 nextPosition;
@property (assign, nonatomic, readonly) GLKVector3 velocity;
@property (assign, nonatomic, readonly) GLfloat yawRadians;
@property (assign, nonatomic, readonly) GLfloat targetYawRadians;
@property (assign, nonatomic, readonly) GLKVector4 color;
@property (assign, nonatomic, readonly) GLfloat radius;

- (id)initWithModel:(UtilityModel *)aModel position:(GLKVector3)aPosition velocity:(GLKVector3)aVelocity color:(GLKVector4)aColor;

- (void)updateWithController:(id <SceneCarControllerProtocol>)controller;
- (void)drawWithBaseEffect:(GLKBaseEffect *)anEffect;

@end
