//
//  ADBLeftMenuViewController.m
// AirLab
//
//  Created by Raul Catena on 5/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBLeftMenuViewController.h"
#import "ADBRightControllerViewController.h"

@interface ADBLeftMenuViewController ()

@end

@implementation ADBLeftMenuViewController

@synthesize options;
@synthesize icons;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)changeRightController:(UIViewController *)controller{
    self.navigationController.splitViewController.delegate = (ADBRightControllerViewController *)controller;
    self.navigationController.splitViewController.viewControllers = @[
                                                                      [self.navigationController.splitViewController.viewControllers objectAtIndex:0],
                                                                        controller,
                                                                      ];
}

-(ADBMasterViewController *)rightController{
    id controller;
    controller = [[(UINavigationController *)[self.navigationController.splitViewController.viewControllers lastObject]viewControllers]lastObject];
    NSLog(@"%@",NSStringFromClass([controller class]));
    return controller;
}


@end
