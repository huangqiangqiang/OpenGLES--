//
//  UtilityModelManager.h
//  OpenGLES-12-使用模型
//
//  Created by 黄强强 on 17/4/17.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "UtilityModel.h"

@interface UtilityModelManager : NSObject
@property (nonatomic, strong, readonly) GLKTextureInfo *textureInfo;

- (instancetype)initWithModelPath:(NSString *)modelpath;
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError;

- (UtilityModel *)modelNamed:(NSString *)aName;

- (void)prepareToDraw;

@end
