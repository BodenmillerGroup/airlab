//
//  DilutionCalculatorViewController.h
//  AirLab
//
//  Created by Raul Catena on 5/10/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADBMasterViewController.h"


@interface ADBDilutorCalculator : ADBMasterViewController <UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UITextField *initial;
@property (nonatomic, retain) IBOutlet UITextField *final;
@property (nonatomic, retain) IBOutlet UITextField *volumeToPrepare;
@property (nonatomic, retain) IBOutlet UITextView *result;
@property (nonatomic, retain) IBOutlet UISegmentedControl *massInitialUnit;
@property (nonatomic, retain) IBOutlet UISegmentedControl *massFinalUnit;
@property (nonatomic, retain) IBOutlet UISegmentedControl *volumeInitialUnit;
@property (nonatomic, retain) IBOutlet UISegmentedControl *volumeFinalUnit;
@property (nonatomic, retain) IBOutlet UISegmentedControl *volumeToPrepareUnit;

-(IBAction)calculateFromSwitches;
-(IBAction)calculate;
-(IBAction)clear;

@end
