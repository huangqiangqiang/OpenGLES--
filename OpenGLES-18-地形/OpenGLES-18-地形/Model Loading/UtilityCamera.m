//
//  UtilityCamera.m
//  OpenGLES-18-地形
//
//  Created by 黄强强 on 17/5/3.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "UtilityCamera.h"
#import "AGLKFrustum.h"

@interface UtilityCamera()
@property (nonatomic, assign) AGLKFrustum frustum;
@property (nonatomic, assign) BOOL isInCallback;
@end

@implementation UtilityCamera

- (void)setPosition:(GLKVector3)aPosition lookAtPosition:(GLKVector3)lookAtPosition
{
    if (!self.isInCallback) {
        self.isInCallback = YES;
        
        BOOL shouldMakeChange = YES;
        
        if([self.delegate respondsToSelector:@selector(camera:willChangeEyePosition:lookAtPosition:)])
        {
            shouldMakeChange = [self.delegate camera:self willChangeEyePosition:&aPosition lookAtPosition:&lookAtPosition];
        }
        
        if(shouldMakeChange)
        {
            const GLKVector3 upUnitVector = GLKVector3Make(0.0f, 1.0f, 0.0f); // Assume Y up
            AGLKFrustumSetPositionAndDirection(&_frustum, aPosition, lookAtPosition, upUnitVector);
        }
        
        self.isInCallback = NO;
    }
}


- (void)configurePerspectiveFieldOfViewRad:(GLfloat)angle
                               aspectRatio:(GLfloat)anAspectRatio
                                      near:(GLfloat)nearLimit
                                       far:(GLfloat)farLimit
{
    AGLKFrustumSetPerspective(&_frustum, angle, anAspectRatio, nearLimit, farLimit);
}


- (void)moveBy:(GLKVector3)aVector
{
    const GLKVector3 currentEyePosition = [self position];
    const GLKVector3 currentLookAtPosition = [self lookAtPosition];
    
    [self setPosition:GLKVector3Add(currentEyePosition, aVector) lookAtPosition:GLKVector3Add(currentLookAtPosition, aVector)];
}


- (GLKMatrix4)projectionMatrix
{
    return AGLKFrustumMakePerspective(&_frustum);
}


- (GLKMatrix4)modelviewMatrix
{
    return AGLKFrustumMakeModelview(&_frustum);
}


- (GLKVector3)position
{
    return _frustum.eyePosition;
}

- (GLKVector3)lookAtPosition
{
    const GLKVector3 eyePosition = _frustum.eyePosition;
    const GLKVector3 lookAtPosition = GLKVector3Add(eyePosition, _frustum.zUnitVector);
    
    return lookAtPosition;
}

@end
