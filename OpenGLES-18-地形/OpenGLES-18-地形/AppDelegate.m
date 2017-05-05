//
//  AppDelegate.m
//  OpenGLES-18-地形
//
//  Created by 黄强强 on 17/5/3.
//  Copyright © 2017年 黄强强. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self loadTerrain];
    
    return YES;
}

- (void)loadTerrain
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Terrain" inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:entity];
    
    NSArray *terrainArray = nil;
    NSError *error = nil;
    
    terrainArray = [[self managedObjectContext] executeFetchRequest:request error:&error];
    self.terrain = [terrainArray lastObject];
}

#pragma mark - Core Data stack

/////////////////////////////////////////////////////////////////
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound
// to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}


/////////////////////////////////////////////////////////////////
// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the
// application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel)
    {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"OpenGLES_Ch10_1" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}


/////////////////////////////////////////////////////////////////
// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and
// the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    
    if (!_persistentStoreCoordinator)
    {
        NSURL *storeURL = [[NSBundle mainBundle] URLForResource:@"trail" withExtension:@"binary"];
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSReadOnlyPersistentStoreOption];
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSBinaryStoreType configuration:nil URL:storeURL options:options error:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Model Manager

//////////////////////////////////////////////////////////////////
//
- (UtilityModelManager *)modelManager
{
    if(!_modelManager && self.terrain.modelsData != nil)
    {
        _modelManager = [[UtilityModelManager alloc] init];
        [_modelManager readFromData:self.terrain.modelsData ofType:nil error:NULL];
    }
    
    return _modelManager;
}


@end
