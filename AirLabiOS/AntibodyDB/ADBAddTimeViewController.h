//
//  ADBAddTimeViewController.h
// AirLab
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol AddTimeDelegate <NSObject>
- (void)didAddTime:(int)time;
@end

@interface ADBAddTimeViewController : ADBMasterViewController

@property (nonatomic, assign) id<AddTimeDelegate> delegate;
@property (nonatomic, assign) int timerCount;
@property (nonatomic, weak) IBOutlet UIStepper *stepperSeconds;
@property (nonatomic, weak) IBOutlet UIStepper *stepperMinutes;
@property (nonatomic, weak) IBOutlet UIStepper *stepperHours;
@property (nonatomic, weak) IBOutlet UILabel *seconds;
@property (nonatomic, weak) IBOutlet UILabel *minutes;
@property (nonatomic, weak) IBOutlet UILabel *hours;

-(IBAction)setTimeToCount:(UIStepper *)stepper;
-(IBAction)done:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTime:(int)time;

@end


