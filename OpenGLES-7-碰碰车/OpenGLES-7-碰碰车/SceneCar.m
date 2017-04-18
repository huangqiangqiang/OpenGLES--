//
//  SceneCar.m
//  OpenGLES-7-碰碰车
//
//  Created by 黄强强 on 17/3/28.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "SceneCar.h"

@implementation SceneCar

- (instancetype)initWithModel:(SceneModel *)aModel position:(GLKVector3)aPosition velocity:(GLKVector3)aVelocity color:(GLKVector4)aColor
{
    self = [super init];
    if (self) {
        self.model = aModel;
        self.position = aPosition;
        self.velocity = aVelocity;
        self.color = aColor;
        
        // 取宽度最大的作为半径
        SceneAxisAllignedBoundingBox axisAlignedBoundingBox = self.model.axisAlignedBoundingBox;
        self.radius = 0.5f * MAX((axisAlignedBoundingBox.max.x - axisAlignedBoundingBox.min.x), (axisAlignedBoundingBox.max.z - axisAlignedBoundingBox.min.z));
    }
    return self;
}

- (void)drawWithBaseEffect:(GLKBaseEffect *)baseEffect
{
    GLKMatrix4 saveModelViewMatrix = baseEffect.transform.modelviewMatrix;
    GLKVector4 saveDiffuseColor = baseEffect.material.diffuseColor;
    GLKVector4 saveAmbientColor = baseEffect.material.ambientColor;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(saveModelViewMatrix, self.position.x, self.position.y, self.position.z);
    baseEffect.transform.modelviewMatrix = modelViewMatrix;
    baseEffect.material.diffuseColor = self.color;
    baseEffect.material.ambientColor = self.color;
    
    [baseEffect prepareToDraw];
    [self.model draw];
    
    baseEffect.transform.modelviewMatrix = saveModelViewMatrix;
    baseEffect.material.diffuseColor = saveDiffuseColor;
    baseEffect.material.ambientColor = saveAmbientColor;
}

- (void)updateWithController:(id<SceneCarControllerProtocal>)viewController
{
    // 上一次更新和这次的时间差
    NSTimeInterval elapsedTimeSeconds = [viewController timeSinceLastUpdate];
    // 计算下一个位置的坐标
    GLKVector3 distance = GLKVector3MultiplyScalar(self.velocity, elapsedTimeSeconds);
    self.nextPosition = GLKVector3Add(self.position, distance);
    // 碰撞检测
    [self bounceOffCars:[viewController cars] elapsedTime:elapsedTimeSeconds];
    [self bounceOffWallsWithBoundingBox:[viewController rinkBoundingBox]];
    self.position = self.nextPosition;
}

/**
 车与车之间的碰撞检测
 */
- (void)bounceOffCars:(NSArray *)cars elapsedTime:(NSTimeInterval)elapsedTimeSeconds
{
    for(SceneCar *currentCar in cars)
    {
        if(currentCar != self)
        {
            float distance = GLKVector3Distance(self.nextPosition, currentCar.nextPosition);
            
            if((2.0f * self.radius) > distance)
            {  // cars have collided
                GLKVector3 ownVelocity = self.velocity;
                GLKVector3 otherVelocity = currentCar.velocity;
                GLKVector3 directionToOtherCar = GLKVector3Subtract(currentCar.position,self.position);
                
                directionToOtherCar = GLKVector3Normalize(directionToOtherCar);
                GLKVector3 negDirectionToOtherCar = GLKVector3Negate(directionToOtherCar);
                
                GLKVector3 tanOwnVelocity = GLKVector3MultiplyScalar(negDirectionToOtherCar, GLKVector3DotProduct(ownVelocity, negDirectionToOtherCar));
                GLKVector3 tanOtherVelocity = GLKVector3MultiplyScalar(directionToOtherCar, GLKVector3DotProduct(otherVelocity, directionToOtherCar));
                
                {  // Update own velocity
                    self.velocity = GLKVector3Subtract(ownVelocity,tanOwnVelocity);
                    
                    // Scale velocity based on elapsed time
                    GLKVector3 travelDistance = GLKVector3MultiplyScalar(self.velocity,elapsedTimeSeconds);
                    
                    // Update position based on velocity and time since last
                    // update
                    self.nextPosition = GLKVector3Add(self.position, travelDistance);
                }
                
                {  // Update other car's velocity
                    currentCar.velocity = GLKVector3Subtract(otherVelocity,tanOtherVelocity);
                    
                    // Scale velocity based on elapsed time
                    GLKVector3 travelDistance = GLKVector3MultiplyScalar(currentCar.velocity,elapsedTimeSeconds);
                    
                    // Update position based on velocity and time since last 
                    // update
                    currentCar.nextPosition = GLKVector3Add(currentCar.position,travelDistance);
                }
            }
        }
    }
}

/**
 车与墙之间的碰撞检测
 */
- (void)bounceOffWallsWithBoundingBox:(SceneAxisAllignedBoundingBox)rinkBoundingBox
{
    if((rinkBoundingBox.min.x + self.radius) > self.nextPosition.x)
    {
        self.nextPosition = GLKVector3Make((rinkBoundingBox.min.x + self.radius),self.nextPosition.y, self.nextPosition.z);
        self.velocity = GLKVector3Make(-self.velocity.x, self.velocity.y, self.velocity.z);
    }
    else if((rinkBoundingBox.max.x - self.radius) < self.nextPosition.x)
    {
        self.nextPosition = GLKVector3Make((rinkBoundingBox.max.x - self.radius),self.nextPosition.y, self.nextPosition.z);
        self.velocity = GLKVector3Make(-self.velocity.x, self.velocity.y, self.velocity.z);
    }
    
    if((rinkBoundingBox.min.z + self.radius) > self.nextPosition.z)
    {
        self.nextPosition = GLKVector3Make(self.nextPosition.x, self.nextPosition.y, (rinkBoundingBox.min.z + self.radius));
        self.velocity = GLKVector3Make(self.velocity.x, self.velocity.y, -self.velocity.z);
    }
    else if((rinkBoundingBox.max.z - self.radius) < self.nextPosition.z)
    {
        self.nextPosition = GLKVector3Make(self.nextPosition.x, self.nextPosition.y, (rinkBoundingBox.max.z - self.radius));
        self.velocity = GLKVector3Make(self.velocity.x, self.velocity.y, -self.velocity.z);
    }
}

@end
