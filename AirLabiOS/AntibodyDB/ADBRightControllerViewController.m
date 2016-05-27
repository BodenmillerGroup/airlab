//
//  ADBRightControllerViewController.m
// AirLab
//
//  Created by Raul Catena on 5/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBRightControllerViewController.h"

@interface ADBRightControllerViewController ()

@end

@implementation ADBRightControllerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark SplitViewControllerDelegate

#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = [[[(UINavigationController *)aViewController viewControllers]objectAtIndex:0]title];
	self.navigationItem.leftBarButtonItem = barButtonItem;
    //NSMutableArray *items = [[toolbar items] mutableCopy];
	// [items insertObject:barButtonItem atIndex:0];
    //[toolbar setItems:items animated:YES];
    //[items release];
    self.popover = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    //NSMutableArray *items = [[toolbar items] mutableCopy];
    //[items removeObjectAtIndex:0];
    //[toolbar setItems:items animated:YES];
    //[items release];
	self.navigationItem.leftBarButtonItem = nil;
    self.popover = nil;
}

-(void)pushNavController:(id<UISplitViewControllerDelegate>)controller{
    self.navigationController.splitViewController.delegate = controller;
    [self.navigationController pushViewController:(UIViewController *)controller animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

@end
