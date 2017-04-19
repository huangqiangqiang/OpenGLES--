//
//  UtilityModel+viewAdditions.m
//  OpenGLES-12-使用模型
//
//  Created by 黄强强 on 17/4/17.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "UtilityModel+viewAdditions.h"
#import "UtilityMesh+viewAdditions.h"

@implementation UtilityModel (viewAdditions)

- (void)draw
{
    [self.mesh drawCommandsInRange:NSMakeRange(self.indexOfFirstCommand, self.numberOfCommands)];
}

@end
