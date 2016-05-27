//
//  ADBAppDelegate.m
// AirLab
//
//  Created by Raul Catena on 3/27/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAppDelegate.h"
#import "ADBAntibodiesViewController.h"
#import "ADBConjugatesViewController.h"
#import "ADBShopViewController.h"
#import "ADBPanelsViewController.h"
#import "PSNatureViewController.h"
#import "ADBPlansViewController.h"
#import "ADBLeftInventarioViewController.h"
#import "ADBInicialViewController.h"
#import "ADBRecetasViewController.h"
#import "ADBSciArtViewController.h"
#import "ADBPubmedSearchViewController.h"
#import "VRGViewController.h"
#import "Tag.h"
#import "Provider.h"
#import "Species.h"
#import "Instagram.h"
#import "ADBLoginViewController.h"
#import "ADBInitialIphoneViewController.h"

@interface ADBAppDelegate()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ADBAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize workerManagedObjectContext = _workerManagedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;




-(void)initiateDropBox{
    // Set these variables before launching the app
    
	DBSession* dbSession = [[DBSession alloc]
      initWithAppKey:@""//Erased for publication in Genome Biology. Please generate your own Dropbox developer account to input credentials here
      appSecret:@""
      root:kDBRootAppFolder]; // either kDBRootAppFolder or kDBRootDropbox
     
    [DBSession setSharedSession:dbSession];
    
    //[[DBSession sharedSession]linkFromController:_window.rootViewController];
}

-(void)setColors{
    //[[UIView appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setTintColor:[UIColor orangeColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance]setTintColor:[UIColor orangeColor]];
}

-(void)addiPadControllers{
    
    ADBInicialViewController *portada = [[ADBInicialViewController alloc]init];
    UINavigationController *portadaNC = [[UINavigationController alloc]initWithRootViewController:portada];
    portadaNC.tabBarItem.title = @"Home";
    portada.title = portadaNC.tabBarItem.title;
    portada.tabBarItem.image = [UIImage imageNamed:@"direction-path.png"];
    
    ADBShopViewController *shop = [[ADBShopViewController alloc]init];
    UINavigationController *shopNC = [[UINavigationController alloc]initWithRootViewController:shop];
    shopNC.tabBarItem.title = @"Shop Reagents";
    shop.title = shopNC.tabBarItem.title;
    shop.tabBarItem.image = [UIImage imageNamed:@"share.png"];
    UISplitViewController *splitViewInventario = [[UISplitViewController alloc]init];
    ADBLeftInventarioViewController *leftInventario = [[ADBLeftInventarioViewController alloc]init];
    UINavigationController *navConLeftInventario = [[UINavigationController alloc]initWithRootViewController:leftInventario];
    splitViewInventario.title = @"Inventory";
    splitViewInventario.delegate = shop;
    splitViewInventario.tabBarItem.image = [UIImage imageNamed:@"share.png"];
    splitViewInventario.viewControllers = @[navConLeftInventario, shopNC];
    
    ADBRecetasViewController *recetas = [[ADBRecetasViewController alloc]init];
    UINavigationController *recetasNC = [[UINavigationController alloc]initWithRootViewController:recetas];
    recetasNC.tabBarItem.title = @"Protocols";
    recetas.title = recetasNC.tabBarItem.title;
    recetas.tabBarItem.image = [UIImage imageNamed:@"file.png"];
    
    ADBPlansViewController *experiments = [[ADBPlansViewController alloc]init];
    UINavigationController *experimentsNC = [[UINavigationController alloc]initWithRootViewController:experiments];
    experimentsNC.tabBarItem.title = @"Experiments";
    experiments.title = experimentsNC.tabBarItem.title;
    experiments.tabBarItem.image = [UIImage imageNamed:@"cylinder.png"];
    
    UIViewController *articulos = [[ADBSciArtViewController alloc]init];
    articulos.title = @"Saved articles";
    UINavigationController *articulosNC = [[UINavigationController alloc]initWithRootViewController:articulos];
    articulos.title = articulosNC.tabBarItem.title;
    ADBPubmedSearchViewController *buscar = [[ADBPubmedSearchViewController alloc]init];
    buscar.title = @"Search";
    UINavigationController *buscarNC = [[UINavigationController alloc]initWithRootViewController:buscar];
    buscar.title = shopNC.tabBarItem.title;
    UISplitViewController *splitViewArticulos = [[UISplitViewController alloc]init];
    splitViewArticulos.tabBarItem.title = @"Bibliography";
    splitViewArticulos.delegate = shop;
    splitViewArticulos.tabBarItem.image = [UIImage imageNamed:@"document.png"];
    splitViewArticulos.viewControllers = @[articulosNC, buscarNC];
    
    VRGViewController *calendar = [[VRGViewController alloc]init];
    UINavigationController *calendarNC = [[UINavigationController alloc]initWithRootViewController:calendar];
    calendarNC.tabBarItem.title = @"Calendar";
    calendar.title = calendarNC.tabBarItem.title;
    calendar.tabBarItem.image = [UIImage imageNamed:@"calendar.png"];
    
    
    PSNatureViewController *news = [[PSNatureViewController alloc]init];
    UINavigationController *newsNC = [[UINavigationController alloc]initWithRootViewController:news];
    newsNC.tabBarItem.title = @"Science Digest";
    news.title = newsNC.tabBarItem.title;
    news.tabBarItem.image = [UIImage imageNamed:@"newspaper.png"];
    
    UITabBarController *tabBarController = [[UITabBarController alloc]init];
    tabBarController.delegate = self;
    tabBarController.viewControllers = @[portadaNC, splitViewInventario, recetasNC, experimentsNC, splitViewArticulos, newsNC, calendarNC];
    [self.window setRootViewController:tabBarController];
}

-(void)iPhoneControllers{
    ADBInitialIphoneViewController *initial = [[ADBInitialIphoneViewController alloc]init];
    UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:initial];
    [self.window setRootViewController:navCon];
}

#define APP_ID_INSTAGRAM @""//Erased app ID for publication in Genome Biology. You can use your own APP ID for instagram here
-(void)startInstagram{
    self.instagram = [[Instagram alloc] initWithClientId:APP_ID_INSTAGRAM
                                                delegate:nil];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    sleep(2);
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [General iPhoneBlock:^{[self iPhoneControllers];} iPadBlock:^{[self addiPadControllers];}];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[ADBAccountManager sharedInstance]showLoginIfNecessary];
    [self setColors];
    
    [self initiateDropBox];
    [self startInstagram];

    [[IPExporter getInstance]start];
    
    return YES;
}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    int index = (int)[tabBarController.viewControllers indexOfObject:viewController];
    UIColor *color;
    switch (index) {
        case 0:
            color = [UIColor orangeColor];
            break;
        case 1:
            color = [UIColor blueColor];
            break;
        case 2:
            color = [UIColor redColor];
            break;
        case 3:
            color = [UIColor yellowColor];
            break;
        case 4:
            color = [UIColor grayColor];
            break;
        case 5:
            color = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
            break;

        default:
            color = [UIColor orangeColor];
            break;
    }
    [[UITabBar appearance] setTintColor:color];
    //[[UITabBar appearance] setBarTintColor:color];
    //[[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor orangeColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"Url is %@", url.absoluteString);
    if([url.absoluteString hasPrefix:@"db-"]){//Erased key for publication in genome biology
        if ([[DBSession sharedSession] handleOpenURL:url]) {
            //Successfully Logged in to Dropbox
            return YES;
        }
        
        return NO;
    }
    if ([url.absoluteString hasPrefix:@"fb"]) {//Erased FB key for publication in Genome biology
        // attempt to extract a token from the url
        //return [FBAppCall handleOpenURL:url
        //sourceApplication:sourceApplication
        //withSession:[IPFacebook getInstance]];
    }
    return [self.instagram handleOpenURL:url];
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    //[_timer fire];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (![General isIphone]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1800 target:[ADBAccountManager sharedInstance] selector:@selector(logOff) userInfo:nil repeats:NO];
    }
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [_timer invalidate];
    self.timer = nil;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
        }
        return YES;
    }
    
    // Add whatever other url handling code your app requires here
    return NO;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];//NSPrivateQueueConcurrencyType];NSMainQueueConcurrencyType;NSConfinementConcurrencyType
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        [_managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectContext *)workerManagedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_workerManagedObjectContext != nil) {
        return _workerManagedObjectContext;
    }
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = [self managedObjectContext];//
    _workerManagedObjectContext = context;
    
    return _workerManagedObjectContext;
}

-(void)resetMOC{
    _managedObjectContext = nil;
    [self managedObjectContext];
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AntibodyDB" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (BOOL)hardResetContext:(NSManagedObjectContext *)context store:(NSPersistentStore *)store
{
    NSPersistentStoreCoordinator *storeCoordinator = [context persistentStoreCoordinator];
    if (![storeCoordinator removePersistentStore:store error:NULL])
    {
        return NO;
    }
    
    return [storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                          configuration:nil
                                                    URL:[store URL]
                                                options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
                                                  error:NULL];
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AntibodyDB.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        NSFileManager *manager = [NSFileManager defaultManager];
        NSError *error2;
        [manager removeItemAtURL:storeURL error:&error2];
        NSLog(@"Unresolved error2_____ %@, %@", error2, [error2 userInfo]);
        NSError *error3;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error]){
            NSLog(@"Unresolved error3_____======== %@, %@", error3, [error3 userInfo]);
            abort();
        }        
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
