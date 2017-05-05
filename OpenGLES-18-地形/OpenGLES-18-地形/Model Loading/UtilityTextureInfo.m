//
//  UtilityTextureInfo.m
//  OpenGLES-12-使用模型
//
//  Created by 黄强强 on 17/4/17.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "UtilityTextureInfo.h"


@interface UtilityTextureInfo()
@property (strong, nonatomic) NSDictionary *plist;
@end

@implementation UtilityTextureInfo

/////////////////////////////////////////////////////////////////
//
- (void)discardPlist;
{
    self.plist = nil;
}


#pragma mark - NSCoding

/////////////////////////////////////////////////////////////////
// This class exists to support unarchiving only. Instances
// should never be encoded.
- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    NSAssert(0, @"Invalid method");
}


/////////////////////////////////////////////////////////////////
// Returns a dictionary caontaining a plist storing unarchives
// attribues.
- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self.plist = [aDecoder decodeObjectForKey:@"plist"];
    
    return self;
}

@end
