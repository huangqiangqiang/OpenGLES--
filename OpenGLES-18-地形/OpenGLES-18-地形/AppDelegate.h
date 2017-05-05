//
//  AppDelegate.h
//  OpenGLES-18-地形
//
//  Created by 黄强强 on 17/5/3.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, ViewControllerDataSource>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) TETerrain *terrain;
@property (nonatomic, strong) UtilityModelManager *modelManager;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end
