//
//  SceneCar.h
//  OpenGLES-7-碰碰车
//
//  Created by 黄强强 on 17/3/28.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "SceneCarModel.h"

@protocol SceneCarControllerProtocal <NSObject>
- (NSTimeInterval)timeSinceLastUpdate;
- (SceneAxisAllignedBoundingBox)rinkBoundingBox;
- (NSArray *)cars;
@end

@interface SceneCar : NSObject
@property (nonatomic, strong) SceneModel *model;
@property (nonatomic, assign) GLKVector3 position;
@property (nonatomic, assign) GLKVector3 nextPosition;
@property (nonatomic, assign) GLKVector3 velocity;
@property (nonatomic, assign) GLKVector4 color;
@property (nonatomic, assign) GLfloat radius;

- (instancetype)initWithModel:(SceneModel *)aModel position:(GLKVector3)aPosition velocity:(GLKVector3)aVelocity color:(GLKVector4)aColor;

- (void)drawWithBaseEffect:(GLKBaseEffect *)baseEffect;


/**
 更新坐标，速度信息

 @param viewController <#viewController description#>
 */
- (void)updateWithController:(UIViewController *)viewController;
@end
