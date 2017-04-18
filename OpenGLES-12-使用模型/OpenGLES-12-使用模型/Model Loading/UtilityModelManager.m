//
//  UtilityModelManager.m
//  OpenGLES-12-使用模型
//
//  Created by 黄强强 on 17/4/17.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "UtilityModelManager.h"
#import "UtilityMesh+viewAdditions.h"
#import "UtilityModel.h"
#import "UtilityTextureInfo+viewAdditions.h"

@interface UtilityModelManager()
@property (nonatomic, strong) GLKTextureInfo *textureInfo;
@property (nonatomic, strong) UtilityMesh *consolidatedMesh;
@property (nonatomic, strong) NSDictionary *modelsDictionary;
@end

@implementation UtilityModelManager

- (instancetype)initWithModelPath:(NSString *)modelpath
{
    if (self = [super init]) {
        NSError *modelLoadingError = nil;
        NSData *data = [NSData dataWithContentsOfFile:modelpath options:0 error:&modelLoadingError];
        if (data != nil) {
            [self readFromData:data ofType:[modelpath pathExtension] error:&modelLoadingError];
        }
    }
    return self;
}

/*
 
 {
     mesh =     {
         commands =         (
             {
                 command = 4;
                 firstIndex = 0;
                 numberOfIndices = 180;
             },
             {
                 command = 4;
                 firstIndex = 180;
                 numberOfIndices = 21;
             }
         );
         indexData = <00000100 02000300 04000500 06000700>;
         vertexAttributeData = <3e21473c bcfecc3e 96057abe 00000000>;
     };
     textureImageInfo =     {
         height = 512;
         imageData = <959280ff 959280ff 928f7cff 8e8c77ff>;
         width = 512;
     };
     models =     {
         bumperCar =         {
             axisAlignedBoundingBox = "{-0.45, 0.02, -0.46},{0.46, 2.30, 0.46}";
             indexOfFirstCommand = 0;
             name = bumperCar;
             numberOfCommands = 8;
         };
         bumperRinkFloor =         {
             axisAlignedBoundingBox = "{-5.00, -0.00, -4.98},{5.00, 0.00, 5.02}";
             indexOfFirstCommand = 8;
             name = bumperRinkFloor;
             numberOfCommands = 1;
         };
         bumperRinkWalls =         {
             axisAlignedBoundingBox = "{-5.10, -0.00, -5.10},{5.10, 0.50, 5.10}";
             indexOfFirstCommand = 9;
             name = bumperRinkWalls;
             numberOfCommands = 2;
         };
     };
 }
 */
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    NSDictionary *documentDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    // 纹理
    self.textureInfo = [GLKTextureInfo textureInfoFromUtilityPlistRepresentation:documentDictionary[UtilityModelManagerTextureImageInfo]];
    // 网格
    self.consolidatedMesh = [[UtilityMesh alloc] initWithPlistRepresentation:documentDictionary[UtilityModelManagerMesh]];
    //
    self.modelsDictionary = [self modelsFromPlistRepresentation:documentDictionary[UtilityModelManagerModels] mesh:self.consolidatedMesh];
    return YES;
}

- (NSDictionary *)modelsFromPlistRepresentation:(NSDictionary *)plist mesh:(UtilityMesh *)aMesh
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    for(NSDictionary *modelDictionary in plist.allValues)
    {
        UtilityModel *newModel = [[UtilityModel alloc] initWithPlistRepresentation:modelDictionary mesh:aMesh];
        [result setObject:newModel forKey:newModel.name];
    }
    
    return result;
}

- (UtilityModel *)modelNamed:(NSString *)aName
{
    return self.modelsDictionary[aName];
}

- (void)prepareToDraw
{
    [self.consolidatedMesh prepareToDraw];
}

NSString *const UtilityModelManagerTextureImageInfo = @"textureImageInfo";
NSString *const UtilityModelManagerMesh = @"mesh";
NSString *const UtilityModelManagerModels = @"models";

@end
