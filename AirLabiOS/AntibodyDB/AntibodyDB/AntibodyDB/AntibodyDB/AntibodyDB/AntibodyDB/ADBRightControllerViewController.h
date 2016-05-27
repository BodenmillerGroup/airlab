//
//  ADBRightControllerViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@interface ADBRightControllerViewController : ADBMasterViewController <UISplitViewControllerDelegate>

-(void)pushNavController:(id<UISplitViewControllerDelegate>)controller;

@end
