//
//  ADBAppDelegate.h
//  AntibodyDB
//
//  Created by Raul Catena on 3/27/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Instagram;

@interface ADBAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) Instagram *instagram;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)resetMOC;

@end
