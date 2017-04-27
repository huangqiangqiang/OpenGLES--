//
//  UtilityMesh.h
//  OpenGLES-12-使用模型
//
//  Created by 黄强强 on 17/4/17.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef struct
{
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector2 texCoords0;
    GLKVector2 texCoords1;
}
UtilityMeshVertex;

@interface UtilityMesh : NSObject
{
    GLuint indexBufferID;
    GLuint vertexArrayID;
    GLuint vertexBufferID;
}

@property (strong, nonatomic, readonly) NSMutableData *mutableVertexData;
@property (strong, nonatomic, readonly) NSMutableData *mutableIndexData;
@property (strong, nonatomic) NSMutableArray *commands;

@property (nonatomic, assign) BOOL shouldUseVAOExtension;

- (instancetype)initWithPlistRepresentation:(NSDictionary *)aDictionary;

@end
