//
//  ViewController.h
//  OpenGLES-18-地形
//
//  Created by 黄强强 on 17/5/3.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "TETerrain.h"
#import "UtilityModelManager.h"

@protocol ViewControllerDataSource <NSObject>

- (TETerrain *)terrain;
- (UtilityModelManager *)modelManager;
- (NSManagedObjectContext *)managedObjectContext;

@end

@interface ViewController : GLKViewController


@end

