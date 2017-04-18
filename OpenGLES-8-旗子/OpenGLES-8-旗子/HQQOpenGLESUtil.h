//
//  HQQOpenGLESUtil.h
//  OpenGLES-8-旗子
//
//  Created by 黄强强 on 17/4/12.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface HQQOpenGLESUtil : NSObject

+ (void)print4Short:(GLshort *)data count:(NSUInteger)count;
+ (void)print4Float:(GLfloat *)data count:(NSUInteger)count;

@end
