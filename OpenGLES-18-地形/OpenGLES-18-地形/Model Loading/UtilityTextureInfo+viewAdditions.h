//
//  UtilityTextureInfo+viewAdditions.h
//  OpenGLES-12-使用模型
//
//  Created by 黄强强 on 17/4/17.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "UtilityTextureInfo.h"

@interface GLKTextureInfo (utilityAdditions)

+ (GLKTextureInfo *)textureInfoFromUtilityPlistRepresentation:(NSDictionary *)aDictionary;

@end

@interface UtilityTextureInfo (viewAdditions)

@property (nonatomic, readonly, assign) GLuint name;
@property (nonatomic, readonly, assign) GLenum target;

@end
