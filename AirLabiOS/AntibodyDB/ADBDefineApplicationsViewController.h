//
//  ADBDefineApplicationsViewController.h
//  AirLab
//
//  Created by Raul Catena on 2/10/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBApplicationType.h"

@protocol ApplicationDefinition<NSObject>

-(void)doneDefiningApplicationsForClone:(Clone *)clone;
-(void)doneDefiningApplicationsPreClone:(NSString *)appsJson;

@end

@interface ADBDefineApplicationsViewController : ADBMasterViewController

@property (nonatomic, assign) id<ApplicationDefinition>delegate;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andClone:(Clone *)clone;

@end
