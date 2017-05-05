//
//  UtilityTextureInfo+viewAdditions.m
//  OpenGLES-12-使用模型
//
//  Created by 黄强强 on 17/4/17.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "UtilityTextureInfo+viewAdditions.h"

@implementation GLKTextureInfo (utilityAdditions)

+ (GLKTextureInfo *)textureInfoFromUtilityPlistRepresentation:(NSDictionary *)aDictionary
{
    GLKTextureInfo *result = nil;
    
    const size_t imageWidth = (size_t)[[aDictionary objectForKey:@"width"] unsignedIntegerValue];
    const size_t imageHeight = (size_t)[[aDictionary objectForKey:@"height"] unsignedIntegerValue];
    
    UIImage *image = [UIImage imageWithData:[aDictionary objectForKey:@"imageData"]];
    
    if(nil != image && 0 != imageWidth && 0 != imageHeight)
    {
        NSError *error;
        result = [GLKTextureLoader textureWithCGImage:[image CGImage] options:[NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:YES], GLKTextureLoaderGenerateMipmaps, [NSNumber numberWithBool:NO], GLKTextureLoaderOriginBottomLeft, [NSNumber numberWithBool:NO], GLKTextureLoaderApplyPremultiplication, nil] error:&error];
        
        if(nil == result) {
            NSLog(@"%@", error);
        }
        else{
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        }
    }
    return result;
}

@end

@implementation UtilityTextureInfo (viewAdditions)

- (GLuint)name;
{
    if(nil == self.userInfo)
    {
        // 解出GLKTextureInfo对象
        self.userInfo = [GLKTextureInfo textureInfoFromUtilityPlistRepresentation:self.plist];
        [self discardPlist];
    }
    NSAssert([self.userInfo isKindOfClass:[GLKTextureInfo class]],
             @"Invalid userInfo");
    
    return [(GLKTextureInfo *)self.userInfo name];
}


- (GLenum)target;
{
    if(nil == self.userInfo)
    {
        self.userInfo = [GLKTextureInfo textureInfoFromUtilityPlistRepresentation:self.plist];
        [self discardPlist];
    }
    NSAssert([self.userInfo isKindOfClass:[GLKTextureInfo class]],
             @"Invalid userInfo");
    
    return [(GLKTextureInfo *)self.userInfo target];
}

@end
