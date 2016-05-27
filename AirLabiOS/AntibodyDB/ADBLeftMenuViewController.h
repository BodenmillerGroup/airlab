//
//  ADBLeftMenuViewController.h
// AirLab
//
//  Created by Raul Catena on 5/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@interface ADBLeftMenuViewController : ADBMasterViewController

@property (nonatomic, strong) NSArray *options;
@property (nonatomic, strong) NSArray *icons;

-(void)changeRightController:(UIViewController *)controller;
-(ADBMasterViewController *)rightController;

@end
