//
//  Qua.h
//  OpenGLES-5-地球月亮
//
//  Created by 黄强强 on 17/3/27.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Qua : NSObject

@property (nonatomic, assign) GLKMatrix4 sensor;
- (void)on;

- (void)off;

@end
