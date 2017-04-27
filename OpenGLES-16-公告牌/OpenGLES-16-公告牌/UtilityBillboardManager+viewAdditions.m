//
//  UtilityBillboardManager+viewAdditions.m
//  OpenGLES-16-公告牌
//
//  Created by 黄强强 on 17/4/27.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "UtilityBillboardManager+viewAdditions.h"
#import "UtilityBillboard.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

@implementation UtilityBillboardManager (viewAdditions)

- (void)drawWithEyePosition:(GLKVector3)eyePosition
              lookDirection:(GLKVector3)lookDirection
                   upVector:(GLKVector3)upVector
{
    lookDirection = GLKVector3Normalize(lookDirection);
    
    // 上向量
    GLKVector3 upUnitVector = GLKVector3Make(0.0f, 1.0f, 0.0f);
    
    // 左向量
    GLKVector3 rightVector = GLKVector3CrossProduct(upUnitVector, lookDirection);
    
    // 法向量
    const GLKVector3 normalVector = GLKVector3Negate(lookDirection);
    
    // 顶点数据
    NSMutableData *billboardVertices = [NSMutableData data];
    
    // Update and store the vertices for all visible particles.
    for (UtilityBillboard *billboard in [self.mutableSortedBillboards reverseObjectEnumerator])
    {
        if(0 <= billboard.distanceSquared)
        {
            break;
        }
        else
        {
            // 公告牌的大小和位置
            const GLKVector2 size = billboard.size;
            const GLKVector3 position = billboard.position;
            
            // 公告牌的四个顶点
            GLKVector3 leftBottomPosition = GLKVector3Add(GLKVector3MultiplyScalar(rightVector, size.x * -0.5f), position);
            GLKVector3 rightBottomPosition = GLKVector3Add(GLKVector3MultiplyScalar(rightVector, size.x * 0.5f), position);
            GLKVector3 leftTopPosition = GLKVector3Add(leftBottomPosition, GLKVector3MultiplyScalar(upUnitVector, size.y));
            GLKVector3 rightTopPosition = GLKVector3Add(rightBottomPosition, GLKVector3MultiplyScalar(upUnitVector, size.y));
            
            // Store vertices for two triangles that compose one
            // billboard.
            const GLKVector2 maxTextureCoords = billboard.maxTextureCoords;
            const GLKVector2 minTextureCoords = billboard.minTextureCoords;
            
            BillboardVertex vertices[6];
            vertices[2].position = leftBottomPosition;
            vertices[2].normal = normalVector;
            vertices[2].textureCoords.x = minTextureCoords.x;
            vertices[2].textureCoords.y = maxTextureCoords.y;
            vertices[1].position = rightBottomPosition;
            vertices[1].normal = normalVector;
            vertices[1].textureCoords = maxTextureCoords;
            vertices[0].position = leftTopPosition;
            vertices[0].normal = normalVector;
            vertices[0].textureCoords = minTextureCoords;
            vertices[5].position = leftTopPosition;
            vertices[5].normal = normalVector;
            vertices[5].textureCoords = minTextureCoords;
            vertices[4].position = rightBottomPosition;
            vertices[4].normal = normalVector;
            vertices[4].textureCoords = maxTextureCoords;
            vertices[3].position = rightTopPosition;
            vertices[3].normal = normalVector;
            vertices[3].textureCoords.x = maxTextureCoords.x;
            vertices[3].textureCoords.y = minTextureCoords.y;
            
            [billboardVertices appendBytes:vertices length:sizeof(vertices)];
        }
    }
    
    glBindVertexArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(
                          GLKVertexAttribPosition,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(BillboardVertex),
                          (GLbyte *)[billboardVertices bytes] +
                          offsetof(BillboardVertex, position));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(
                          GLKVertexAttribNormal,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(BillboardVertex),
                          (GLbyte *)[billboardVertices bytes] + 
                          offsetof(BillboardVertex, normal));       
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0); 
    glVertexAttribPointer(            
                          GLKVertexAttribTexCoord0,       
                          2,                
                          GL_FLOAT,            
                          GL_FALSE,            
                          sizeof(BillboardVertex),         
                          (GLbyte *)[billboardVertices bytes] + 
                          offsetof(BillboardVertex, textureCoords));       
    
    glDepthMask(GL_FALSE);  // Disable depth buffer writes
    glDrawArrays(GL_TRIANGLES, 0, (GLsizei)([billboardVertices length] / sizeof(BillboardVertex)));
    glDepthMask(GL_TRUE);   // Reenable depth buffer writes
}

@end
