//
//  HQQOpenGLESUtil.m
//  OpenGLES-8-旗子
//
//  Created by 黄强强 on 17/4/12.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "HQQOpenGLESUtil.h"

@implementation HQQOpenGLESUtil

+ (void)print4Short:(short *)data count:(NSUInteger)count
{
    for (int i = 0; i < count; i++) {
        if (i == 0) {
            printf("{");
        }
        printf("%d",data[i]);
        if (i == count - 1) {
            printf("}\n");
        }else{
            printf(",");
        }
    }
}

+ (void)print4Float:(GLfloat *)data count:(NSUInteger)count
{
    for (int i = 0; i < count; i++) {
        if (i == 0) {
            printf("{");
        }
        printf("%f",data[i]);
        if (i == count - 1) {
            printf("}\n");
        }else{
            printf(",");
        }
    }
}

@end
