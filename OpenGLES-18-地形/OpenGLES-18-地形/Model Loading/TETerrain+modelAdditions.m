//
//  TETerrain+modelAdditions.m
//  OpenGLES-18-地形
//
//  Created by 黄强强 on 17/5/4.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "TETerrain+modelAdditions.h"

@implementation TETerrain (modelAdditions)

static inline const GLKVector3 *TETerrainPostitionPtrAt
(
 TETerrain *terrain,
 NSData *positionAttributes,
 NSInteger x,
 NSInteger z)
{
    NSCParameterAssert(nil != terrain);
    NSCParameterAssert(nil != positionAttributes);
    NSCParameterAssert(x >= 0 && x < terrain.width);
    NSCParameterAssert(z >= 0 && z < terrain.length);
    
    return ((const GLKVector3 *)[positionAttributes bytes]) +
    (z * terrain.width + x);
}

#define AGLKVerySmallMagnitude (FLT_EPSILON * 8.0f)

BOOL AGLKRayDoesIntersectTriangle(
                                  GLKVector3 d,
                                  GLKVector3 p,
                                  GLKVector3 v0,
                                  GLKVector3 v1,
                                  GLKVector3 v2,
                                  GLKVector3 *intersectionPoint)
{  // The parametric equation of the line is p + t * d where p
    // is a point in the line and d is a unit vector in the line's
    // direction and t is a distance from p along the line.
    // If there is a point that belongs both to the line and the
    // triangle {v0, v1, v2} then
    // p + t * d = (1-u-v) * v0 + u * v1 + v * v2
    // Is function answeres whether there a triplet (t,u,v) that
    // satisfies the equation.
    d = GLKVector3Normalize(d);
    GLKVector3 e1 = GLKVector3Subtract(v1, v2);
    GLKVector3 e2 = GLKVector3Subtract(v2, v0);
    GLKVector3 h = GLKVector3CrossProduct(d, e2);
    GLfloat a = GLKVector3DotProduct(e1, h);
    
    if(a > -AGLKVerySmallMagnitude && a < AGLKVerySmallMagnitude)
    {  // ray and triangle are parallel and therefore don't
        // interesct
        return NO;
    }
    
    GLfloat f = 1.0f / a;
    GLKVector3 s = GLKVector3Subtract(p, v0);
    GLfloat u = f * GLKVector3DotProduct(s, h);
    
    if(u < 0.0f || u > 1.0f)
    {  // Ray passes outside side v2<-->v0
        return NO;
    }
    
    GLKVector3 q = GLKVector3CrossProduct(s, e1);
    GLfloat v = f * GLKVector3DotProduct(d, q);
    
    if(v < 0.0f || v > 1.0f)
    {  // Ray passes outside side v1<-->v2
        return NO;
    }
    
    // at this stage we can compute t to find out where
    // the intersection point is on the line
    GLfloat t = f * GLKVector3DotProduct(e2, q);
    
    if(t > AGLKVerySmallMagnitude)
    { // Found intersection (Ray passes inside side v0<-->v1
        if(NULL != intersectionPoint)
        {
            *intersectionPoint = GLKVector3Add(p,
                                               GLKVector3MultiplyScalar(d, t));
        }
        
        return YES;
    }
    
    return NO;
}


- (GLfloat)widthMeters;
{
    return self.width * self.metersPerUnit;
}


/////////////////////////////////////////////////////////////////
// Returns the maximum height of the terrain in meters based on
// the receiver's metersPerUnit property.
- (GLfloat)heightMeters;
{
    return self.heightScaleFactor * self.metersPerUnit;
}


/////////////////////////////////////////////////////////////////
// Returns the length of the terrain in meters based on the
// receiver's metersPerUnit property.
- (GLfloat)lengthMeters;
{
    return self.length * self.metersPerUnit;
}


- (GLfloat)calculatedHeightAtXPosMeters:(GLfloat)x
                             zPosMeters:(GLfloat)z
                          surfaceNormal:(GLKVector3 *)aNormal;
{
    GLfloat metersPerUnit = self.metersPerUnit;
    x = x / metersPerUnit;
    z = z / metersPerUnit;
    
    // 坐标去单位再计算点位与地形的高度
    GLfloat result = [self calculatedHeightAtXPos:x zPos:z surfaceNormal:aNormal];
    
    return result;
}

- (GLfloat)calculatedHeightAtXPos:(GLfloat)x zPos:(GLfloat)z surfaceNormal:(GLKVector3 *)aNormal;
{
    GLfloat       result = 0.0f;
    GLfloat metersPerUnit = self.metersPerUnit;
    
    // First, find out which triangle contains the point
    // 计算这个点在哪个三角形内
    GLKVector3 a = {floorf(x), 0.0f, floorf(z)};
    GLKVector3 b = {floorf(x), 0.0f, ceilf(z + 0.0001)};
    GLKVector3 c = {ceilf(x + 0.0001), 0.0f, floorf(z)};
    GLKVector3 d = {ceilf(x + 0.0001), 0.0f, ceilf(z + 0.0001)};
    GLKVector3 p = {x, 0.0f, z};
    GLKVector3 rayDirection = {0.0f, 1.0f, 0.0f};
    
    a.y = [self heightAtXPos:a.x zPos:a.z] / metersPerUnit;
    b.y = [self heightAtXPos:b.x zPos:b.z] / metersPerUnit;
    c.y = [self heightAtXPos:c.x zPos:c.z] / metersPerUnit;
    d.y = [self heightAtXPos:d.x zPos:d.z] / metersPerUnit;
    
    GLKVector3 intersectionPoint;
    
    if(AGLKRayDoesIntersectTriangle(rayDirection,
                                    p,
                                    a,
                                    b,
                                    c,
                                    &intersectionPoint))
    {
        if(NULL != aNormal)
        {
            *aNormal = GLKVector3CrossProduct(
                                              GLKVector3Normalize(GLKVector3Subtract(b, a)),
                                              GLKVector3Normalize(GLKVector3Subtract(c, a)));
        }
        result = intersectionPoint.y * metersPerUnit;
    }
    else if(AGLKRayDoesIntersectTriangle(
                                         rayDirection,
                                         p,
                                         d,
                                         b,
                                         c,
                                         &intersectionPoint)
            )
    {
        if(NULL != aNormal)
        {
            *aNormal = GLKVector3CrossProduct(
                                              GLKVector3Normalize(GLKVector3Subtract(c, d)),
                                              GLKVector3Normalize(GLKVector3Subtract(b, d)));
            
            NSAssert(0.9 < GLKVector3DotProduct(
                                                *aNormal, 
                                                *aNormal),
                     @"Invalid surfaceNormal");
        }
        result = intersectionPoint.y * metersPerUnit;
    }
    
    
    return result;
}

- (GLfloat)heightAtXPos:(NSInteger)x zPos:(NSInteger)z
{
    GLfloat       result = 0.0f;
    const NSInteger constLength = self.length;
    const NSInteger constWidth = self.width;
    
    if(nil != self.positionAttributesData && x < constWidth &&
       z < constLength && 0 <= x && 0 <= z)
    {
        result = TETerrainPostitionPtrAt(self, self.positionAttributesData, x, z)->y;
    }
    
    return result;
}

@end
