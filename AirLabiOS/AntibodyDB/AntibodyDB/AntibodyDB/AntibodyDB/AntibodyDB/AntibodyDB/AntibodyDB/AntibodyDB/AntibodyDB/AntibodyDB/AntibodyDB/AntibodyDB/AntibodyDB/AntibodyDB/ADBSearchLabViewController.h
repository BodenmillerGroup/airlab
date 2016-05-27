//
//  ADBSearchLabViewController.h
//  AirLab
//
//  Created by Raul Catena on 10/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@interface ADBSearchLabViewController : ADBMasterViewController

@property (nonatomic, weak) IBOutlet UITextField *search;
-(IBAction)update;

@end
