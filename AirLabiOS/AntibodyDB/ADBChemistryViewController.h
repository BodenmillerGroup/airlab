//
//  ADBChemistryViewController.h
// AirLab
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADBMasterViewController.h"



@interface ADBChemistryViewController : ADBMasterViewController <UISplitViewControllerDelegate, UIPopoverControllerDelegate, UITextFieldDelegate>


@property (nonatomic, weak) IBOutlet UISegmentedControl *choice;
@property (nonatomic, weak) IBOutlet UITextField *pm;
@property (nonatomic, weak) IBOutlet UITextField *volume;
@property (nonatomic, weak) IBOutlet UITextField *weight;
@property (nonatomic, weak) IBOutlet UITextField *molarity;
@property (nonatomic, weak) IBOutlet UISegmentedControl *unitsVolume;
@property (nonatomic, weak) IBOutlet UISegmentedControl *unitsWeight;
@property (nonatomic, weak) IBOutlet UISegmentedControl *unitsMolarity;

-(IBAction)removeValues;
-(IBAction)selecteType;
-(IBAction)executeOne;
-(IBAction)executeTwo;
-(IBAction)changed;


@end
