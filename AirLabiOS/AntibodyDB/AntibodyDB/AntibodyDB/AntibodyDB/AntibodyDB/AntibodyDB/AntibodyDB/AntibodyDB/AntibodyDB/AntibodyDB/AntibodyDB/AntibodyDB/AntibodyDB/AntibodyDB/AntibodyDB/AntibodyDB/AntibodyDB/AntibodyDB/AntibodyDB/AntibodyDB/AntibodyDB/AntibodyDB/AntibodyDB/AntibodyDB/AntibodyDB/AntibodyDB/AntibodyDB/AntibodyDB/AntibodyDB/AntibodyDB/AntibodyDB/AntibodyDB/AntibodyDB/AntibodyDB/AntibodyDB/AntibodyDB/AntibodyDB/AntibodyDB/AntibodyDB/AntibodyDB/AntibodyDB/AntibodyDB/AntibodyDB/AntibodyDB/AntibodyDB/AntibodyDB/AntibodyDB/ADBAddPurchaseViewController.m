//
//  ADBAddPurchaseViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/11/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddPurchaseViewController.h"
#import "ADBShopViewController.h"
#import "ADBManualComertialReagentViewController.h"

@interface ADBAddPurchaseViewController ()

@end

@implementation ADBAddPurchaseViewController

@synthesize delegate;
@synthesize optionControl = _optionControl;

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(next)];
}

-(void)next{
    int option = _optionControl.selectedSegmentIndex;
    UIViewController *controller;
    switch (option) {
        case 0:
            controller = [[ADBManualComertialReagentViewController alloc]init];
            break;
        case 1:
            controller = [[ADBShopViewController alloc]init];
            break;
        case 2:
            
            break;
            
        default:
            break;
    }
    [self.navigationController pushViewController:controller animated:YES];
}

@end
