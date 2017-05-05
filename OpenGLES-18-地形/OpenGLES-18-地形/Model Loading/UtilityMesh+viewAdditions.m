//
//  UtilityMesh+viewAdditions.m
//  OpenGLES-12-使用模型
//
//  Created by 黄强强 on 17/4/17.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "UtilityMesh+viewAdditions.h"
#import <OpenGLES/ES3/glext.h>
#import <OpenGLES/ES3/gl.h>


typedef enum
{
    UtilityVertexAttribPosition = GLKVertexAttribPosition,
    UtilityVertexAttribNormal = GLKVertexAttribNormal,
    UtilityVertexAttribColor = GLKVertexAttribColor,
    UtilityVertexAttribTexCoord0 = GLKVertexAttribTexCoord0,
    UtilityVertexAttribTexCoord1 = GLKVertexAttribTexCoord1,
    UtilityVertexAttribOpacity,
    UtilityVertexAttribJointMatrixIndices,
    UtilityVertexAttribJointNormalizedWeights,
    UtilityVertexNumberOfAttributes,
} UtilityVertexAttribute;

@implementation UtilityMesh (viewAdditions)


- (void)prepareToDraw
{
    if (vertexArrayID != 0) {
        glBindVertexArray(vertexArrayID);
    }
    else if(0 < [self.mutableVertexData length]) {
        if (self.shouldUseVAOExtension) {
            glGenVertexArrays(1, &vertexArrayID);
            glBindVertexArray(vertexArrayID);
        }
        if (vertexBufferID == 0) {
            glGenBuffers(1, &vertexBufferID);
            glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
            glBufferData(GL_ARRAY_BUFFER,[self.mutableVertexData length],[self.mutableVertexData bytes],GL_STATIC_DRAW);
        }
        else{
            glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
        }
        
        glEnableVertexAttribArray(UtilityVertexAttribPosition);
        glVertexAttribPointer(UtilityVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(UtilityMeshVertex), (GLbyte *)NULL + offsetof(UtilityMeshVertex, position));
        
        glEnableVertexAttribArray(UtilityVertexAttribNormal);
        glVertexAttribPointer(UtilityVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(UtilityMeshVertex), (GLbyte *)NULL + offsetof(UtilityMeshVertex, normal));
        
        glEnableVertexAttribArray(UtilityVertexAttribTexCoord0);
        glVertexAttribPointer(UtilityVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(UtilityMeshVertex), (GLbyte *)NULL + offsetof(UtilityMeshVertex, texCoords0));
        
        glEnableVertexAttribArray(UtilityVertexAttribTexCoord1); 
        glVertexAttribPointer(UtilityVertexAttribTexCoord1, 2, GL_FLOAT, GL_FALSE, sizeof(UtilityMeshVertex), (GLbyte *)NULL + offsetof(UtilityMeshVertex, texCoords1));
    }
    
    if(0 != indexBufferID)
    {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
    }
    else if(0 < [self.mutableIndexData length])
    {
        glGenBuffers(1, &indexBufferID);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, [self.mutableIndexData length], [self.mutableIndexData bytes], GL_STATIC_DRAW);
    }
}


/**
 (
     {
         command = 4;
         firstIndex = 0;
         numberOfIndices = 180;
     },
     {
         command = 4;
         firstIndex = 180;
         numberOfIndices = 21;
     },
     {
         command = 4;
         firstIndex = 201;
         numberOfIndices = 432;
     },
     {
         command = 4;
         firstIndex = 633;
         numberOfIndices = 123;
     },
     {
         command = 4;
         firstIndex = 756;
         numberOfIndices = 6;
     }
 )
 */
- (void)drawCommandsInRange:(NSRange)aRange
{
    if(0 < aRange.length)
    {
        const NSUInteger lastCommandIndex = (aRange.location + aRange.length) - 1;
        
        NSParameterAssert(aRange.location < [self.commands count]);
        NSParameterAssert(lastCommandIndex < [self.commands count]);
        
        for(NSUInteger i = aRange.location; i <= lastCommandIndex; i++)
        {
            NSDictionary *currentCommand = [self.commands objectAtIndex:i];
            
            const GLsizei  numberOfIndices = (GLsizei)[[currentCommand objectForKey:@"numberOfIndices"] unsignedIntegerValue];
            const GLsizei  firstIndex = (GLsizei)[[currentCommand objectForKey:@"firstIndex"] unsignedIntegerValue];
            GLenum mode = (GLenum)[[currentCommand objectForKey:@"command"] unsignedIntegerValue];
            
            glDrawElements(mode, (GLsizei)numberOfIndices, GL_UNSIGNED_SHORT, ((GLushort *)NULL + firstIndex));
        }
    }
}

@end
