//
//  UtilityModel.m
//  OpenGLES-12-使用模型
//
//  Created by 黄强强 on 17/4/17.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "UtilityModel.h"

@interface UtilityModel()

@end

@implementation UtilityModel

- (id)initWithName:(NSString *)aName mesh:(UtilityMesh *)aMesh indexOfFirstCommand:(NSUInteger)aFirstIndex numberOfCommands:(NSUInteger)count axisAlignedBoundingBox:(AGLKAxisAllignedBoundingBox)aBoundingBox
{
    if(nil != (self=[super init]))
    {
        self.mesh = aMesh;
        self.name = aName;
        self.indexOfFirstCommand = aFirstIndex;
        self.numberOfCommands = count;
        self.axisAlignedBoundingBox = aBoundingBox;
    }
    
    return self;
}

- (instancetype)initWithPlistRepresentation:(NSDictionary *)aDictionary mesh:(UtilityMesh *)aMesh
{
    NSString *aName = [aDictionary objectForKey:UtilityModelName];
    NSUInteger aFirstIndex = [[aDictionary objectForKey:UtilityModelIndexOfFirstCommand] unsignedIntegerValue];
    NSUInteger aNumberOfCommands = [[aDictionary objectForKey:UtilityModelNumberOfCommands] unsignedIntegerValue];
    NSString *anAxisAlignedBoundingBoxString = [aDictionary objectForKey:UtilityModelAxisAlignedBoundingBox];
    AGLKAxisAllignedBoundingBox box = UtilityBoundingBoxFromString(anAxisAlignedBoundingBoxString);
    
    return [self initWithName:aName mesh:aMesh indexOfFirstCommand:aFirstIndex numberOfCommands:aNumberOfCommands axisAlignedBoundingBox:box];
}


static AGLKAxisAllignedBoundingBox UtilityBoundingBoxFromString(NSString *aString)
{
    NSCParameterAssert(nil != aString);
    aString = [aString stringByReplacingOccurrencesOfString:@"{" withString:@""];
    aString = [aString stringByReplacingOccurrencesOfString:@"}" withString:@""];
    
    NSArray *coordsArray = [aString componentsSeparatedByString:@","];
    
    NSCAssert(6 == [coordsArray count], @"invalid AGLKAxisAllignedBoundingBox");
    
    AGLKAxisAllignedBoundingBox result;
    result.min.x = [[coordsArray objectAtIndex:0] floatValue];
    result.min.y = [[coordsArray objectAtIndex:1] floatValue];
    result.min.z = [[coordsArray objectAtIndex:2] floatValue];
    result.max.x = [[coordsArray objectAtIndex:3] floatValue];
    result.max.y = [[coordsArray objectAtIndex:4] floatValue];
    result.max.z = [[coordsArray objectAtIndex:5] floatValue];
    
    return result;
}


NSString *const UtilityModelName = @"name";
NSString *const UtilityModelIndexOfFirstCommand = @"indexOfFirstCommand";
NSString *const UtilityModelNumberOfCommands = @"numberOfCommands";
NSString *const UtilityModelAxisAlignedBoundingBox = @"axisAlignedBoundingBox";
NSString *const UtilityModelDrawingCommand = @"command";

@end
