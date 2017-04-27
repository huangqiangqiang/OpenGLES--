//
//  UtilityModel.h
//  OpenGLES-12-使用模型
//
//  Created by 黄强强 on 17/4/17.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UtilityMesh.h"
#import "AGLKAxisAllignedBoundingBox.h"

@interface UtilityModel : NSObject

@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) UtilityMesh *mesh;
@property (assign, nonatomic) NSUInteger indexOfFirstCommand;
@property (assign, nonatomic) NSUInteger numberOfCommands;
@property (assign, nonatomic) AGLKAxisAllignedBoundingBox axisAlignedBoundingBox;

- (instancetype)initWithPlistRepresentation:(NSDictionary *)aDictionary mesh:(UtilityMesh *)aMesh;

- (void)draw;

@end
