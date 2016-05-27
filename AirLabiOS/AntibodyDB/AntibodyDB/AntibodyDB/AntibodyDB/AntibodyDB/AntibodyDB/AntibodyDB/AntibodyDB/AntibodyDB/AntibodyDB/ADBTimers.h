//
//  Timers.h
//  LabPad
//
//  Created by admin on 4/10/12.
//  Copyright 2014 RaulCatena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADBMasterViewController.h"


@interface ADBTimers : ADBMasterViewController <UIPopoverControllerDelegate>

@property (nonatomic,retain) NSTimer *counter;
@property (nonatomic,assign) int seconds;
@property (nonatomic, assign) int numberOfTimer;
//Outlets
@property (nonatomic, weak) IBOutlet UIButton *initiateButton;
@property (nonatomic, weak) IBOutlet UIButton *killButton;
@property (nonatomic, weak) IBOutlet UIStepper *setTheSecs;
@property (nonatomic, weak) IBOutlet UIStepper *setTheMins;
@property (nonatomic, weak) IBOutlet UIStepper *setTheHours;
@property (nonatomic, weak) IBOutlet UILabel *secsLabel;
@property (nonatomic, weak) IBOutlet UILabel *minslabel;
@property (nonatomic, weak) IBOutlet UILabel *hoursLabel;
@property (nonatomic, weak) IBOutlet UITextField *tagOfTimer;



-(IBAction)initiate:(id)sender;
-(IBAction)kill:(id)sender;
-(IBAction)setNumberOfTimerWithHandle:(UIStepper *)stepper;
-(id)initWithTimer:(int)number;

@end
