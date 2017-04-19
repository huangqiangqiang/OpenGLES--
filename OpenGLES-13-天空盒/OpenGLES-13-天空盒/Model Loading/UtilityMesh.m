//
//  UtilityMesh.m
//  OpenGLES-12-使用模型
//
//  Created by 黄强强 on 17/4/17.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "UtilityMesh.h"

@interface UtilityMesh()
@property (strong, nonatomic) NSMutableData *mutableVertexData;
@property (strong, nonatomic) NSMutableData *mutableIndexData;
@end

@implementation UtilityMesh

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.mutableVertexData = [[NSMutableData alloc] init];
        self.mutableIndexData = [[NSMutableData alloc] init];
        self.commands = [NSMutableArray array];
        self.shouldUseVAOExtension = YES;
    }
    return self;
}

- (instancetype)initWithPlistRepresentation:(NSDictionary *)aDictionary
{
    if (self = [self init]) {
        [self.mutableVertexData appendData:[aDictionary objectForKey:@"vertexAttributeData"]];
        [self.mutableIndexData appendData:[aDictionary objectForKey:@"indexData"]];
        NSArray *arrM = [self.commands arrayByAddingObjectsFromArray:[aDictionary objectForKey:@"commands"]];
        self.commands = [arrM mutableCopy];
    }
    return self;
}

- (NSMutableArray *)commands
{
    if (!_commands) {
        _commands = [NSMutableArray array];
    }
    return _commands;
}


@end
