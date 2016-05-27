//
//  ADBAddTimeViewController.m
// AirLab
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddTimeViewController.h"

@implementation ADBAddTimeViewController

@synthesize delegate;
@synthesize timerCount;
@synthesize stepperSeconds, stepperMinutes, stepperHours;
@synthesize minutes, hours, seconds;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTime:(int)time
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        timerCount = time;
        [self formatDate];
    }
    return self;
}

-(void)formatDate{
    int hoursInt = floor(((float)timerCount/3600));
    int minutesInt = floor(((float)timerCount/60)) - (hoursInt*60);
    int secondsInt = timerCount - (hoursInt*3600) - (minutesInt*60);
    NSLog(@"Timer count %i", timerCount);
    
    if (secondsInt >9) {
        self.seconds.text = [NSString stringWithFormat:@"%i", secondsInt];
    }else{
        self.seconds.text = [NSString stringWithFormat:@"0%i", secondsInt];
    }
    
    if (minutesInt >9) {
        self.minutes.text = [NSString stringWithFormat:@"%i:", minutesInt];
    }else{
        self.minutes.text = [NSString stringWithFormat:@"0%i:", minutesInt];
    }
    
    if (hoursInt >9) {
        self.hours.text = [NSString stringWithFormat:@"%i:", hoursInt];
    }else{
        self.hours.text = [NSString stringWithFormat:@"0%i:", hoursInt];
    }
}

-(IBAction)setTimeToCount:(UIStepper *)stepper{
    if (self.stepperSeconds.value == 60) {
        self.stepperSeconds.value = 0;
    }
    if (self.stepperMinutes.value == 60) {
        self.stepperMinutes.value = 0;
    }
    if (self.stepperHours.value == 99) {
        self.stepperHours.value = 0;
    }
    if (self.stepperSeconds.value == 100) {
        self.stepperSeconds.value = 59;
    }
    if (self.stepperMinutes.value == 100) {
        self.stepperMinutes.value = 59;
    }
    if (self.stepperHours.value == 100) {
        self.stepperHours.value = 99;
    }    
    timerCount = self.stepperHours.value * 3600 + self.stepperMinutes.value * 60 + self.stepperSeconds.value;    
    [self formatDate];
    [self.delegate didAddTime:timerCount];
}

-(IBAction)done:(id)sender{
    [self.delegate didAddTime:timerCount];

}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.preferredContentSize = self.view.bounds.size;
    [self formatDate];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.delegate = nil;
    self.stepperHours = nil;
    self.stepperMinutes = nil;
    self.stepperSeconds = nil;
    self.minutes = nil;
    self.seconds = nil;
    self.hours = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
