//
//  UtilityCamera.h
//  OpenGLES-18-地形
//
//  Created by 黄强强 on 17/5/3.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <GLKit/GLKit.h>


@class UtilityCamera;
@protocol UtilityOpenGLCameraDelegate <NSObject>

// Returning NO prevents changes.
@optional
- (BOOL)camera:(UtilityCamera *)aCamera willChangeEyePosition:(GLKVector3 *)eyePositionPtr lookAtPosition:(GLKVector3 *)lookAtPositionPtr;

@end

@interface UtilityCamera : NSObject

@property (nonatomic, weak) id<UtilityOpenGLCameraDelegate> delegate;

@property(assign, nonatomic, readonly) GLKMatrix4 projectionMatrix;
@property(assign, nonatomic, readonly) GLKMatrix4 modelviewMatrix;
@property(assign, nonatomic, readonly) GLKVector3 position;
@property(assign, nonatomic, readonly) GLKVector3 lookAtPosition;
@property(assign, nonatomic, readonly) GLKVector3 upUnitVector;


/**
 设置model view矩阵
 */
- (void)setPosition:(GLKVector3)aPosition lookAtPosition:(GLKVector3)lookAtPosition;


/**
 设置投影矩阵
 */
- (void)configurePerspectiveFieldOfViewRad:(GLfloat)angle aspectRatio:(GLfloat)anAspectRatio near:(GLfloat)nearLimit far:(GLfloat)farLimit;


/**
 移动摄像头
 */
- (void)moveBy:(GLKVector3)aVector;

@end
