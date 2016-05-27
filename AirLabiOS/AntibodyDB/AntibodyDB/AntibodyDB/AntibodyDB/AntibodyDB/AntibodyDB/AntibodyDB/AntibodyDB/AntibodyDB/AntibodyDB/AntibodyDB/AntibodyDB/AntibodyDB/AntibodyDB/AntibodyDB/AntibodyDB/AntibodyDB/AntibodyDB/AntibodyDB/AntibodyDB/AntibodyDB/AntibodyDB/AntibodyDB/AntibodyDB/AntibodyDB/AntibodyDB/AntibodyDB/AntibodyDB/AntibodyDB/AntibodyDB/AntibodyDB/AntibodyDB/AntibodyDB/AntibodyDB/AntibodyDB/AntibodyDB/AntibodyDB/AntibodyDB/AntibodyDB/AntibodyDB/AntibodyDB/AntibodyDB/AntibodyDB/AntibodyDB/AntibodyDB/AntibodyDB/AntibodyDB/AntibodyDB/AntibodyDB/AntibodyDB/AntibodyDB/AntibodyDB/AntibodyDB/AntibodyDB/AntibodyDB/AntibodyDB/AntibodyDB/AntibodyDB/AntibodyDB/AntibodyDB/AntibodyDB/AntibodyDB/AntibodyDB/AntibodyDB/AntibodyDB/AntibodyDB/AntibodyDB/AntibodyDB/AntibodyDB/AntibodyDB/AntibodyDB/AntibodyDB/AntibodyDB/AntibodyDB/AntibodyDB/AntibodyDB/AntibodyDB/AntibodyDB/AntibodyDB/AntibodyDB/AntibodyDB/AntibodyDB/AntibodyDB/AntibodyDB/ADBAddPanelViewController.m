//
//  ADBAddPanelViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/7/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddPanelViewController.h"
#import "ADBMetalsViewController.h"

@interface ADBAddPanelViewController ()

@end

@implementation ADBAddPanelViewController

@synthesize delegate;
@synthesize segmented = _segmented;

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(next)];
}

-(void)next{
    if (_segmented.selectedSegmentIndex == 0) {
        
    }else if (_segmented.selectedSegmentIndex == 1){
        ADBMetalsViewController *metals = [[ADBMetalsViewController alloc]init];
        metals.delegate = self.delegate;
        [self.navigationController pushViewController:metals animated:YES];
    }else if (_segmented.selectedSegmentIndex == 2){
    
    }
}


@end
