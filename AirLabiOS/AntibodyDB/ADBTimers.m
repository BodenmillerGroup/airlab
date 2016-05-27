    //
//  Timers.m
//  LabPad
//
//  Created by admin on 4/10/12.
//  Copyright 2014 RaulCatena. All rights reserved.
//

#import "ADBTimers.h"


@implementation ADBTimers

-(id)initWithTimer:(int)number{
    self = [self init];
    if (self) {
        _numberOfTimer = number;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [General addBorderToButton:self.killButton withColor:[UIColor redColor]];
    [General addBorderToButton:self.initiateButton withColor:[UIColor darkGrayColor]];
    _tagOfTimer.layer.borderColor = [UIColor orangeColor].CGColor;
    _tagOfTimer.layer.borderWidth = 1.0f;
    _tagOfTimer.layer.cornerRadius = 5.0f;
    self.tagOfTimer.text = [NSString stringWithFormat:@"Name this timer %i", _numberOfTimer];
}

-(void)transformTime{
    int hoursInt = floor(((float)_numberOfTimer/3600));
    int minutesInt = floor(((float)_numberOfTimer/60)) - (hoursInt*60);
    int secondsInt = _numberOfTimer - (hoursInt*3600) - (minutesInt*60);
    
    if (secondsInt >9) {
        self.secsLabel.text = [NSString stringWithFormat:@"%i", secondsInt];
    }else{
        self.secsLabel.text = [NSString stringWithFormat:@"0%i", secondsInt];
    }
    
    if (minutesInt >9) {
        self.minslabel.text = [NSString stringWithFormat:@"%i:", minutesInt];
    }else{
        self.minslabel.text = [NSString stringWithFormat:@"0%i:", minutesInt];
    }
    
    if (hoursInt >9) {
        self.hoursLabel.text = [NSString stringWithFormat:@"%i:", hoursInt];
    }else{
        self.hoursLabel.text = [NSString stringWithFormat:@"0%i:", hoursInt];
    }
}

-(IBAction)setNumberOfTimerWithHandle:(UIStepper *)stepper{

    if (self.setTheSecs.value == 60) {
        self.setTheSecs.value = 0;
    }
    if (self.setTheMins.value == 60) {
        self.setTheMins.value = 0;
    }
    if (self.setTheHours.value == 99) {
        self.setTheHours.value = 0;
    }
    if (self.setTheSecs.value == 100) {
        self.setTheSecs.value = 59;
    }
    if (self.setTheMins.value == 100) {
        self.setTheMins.value = 59;
    }
    if (self.setTheHours.value == 100) {
        self.setTheHours.value = 99;
    }    
    _numberOfTimer = self.setTheHours.value * 3600 + self.setTheMins.value * 60 + self.setTheSecs.value;
    [self transformTime];
}

-(void)blockMode{
    self.setTheMins.userInteractionEnabled = NO;
    self.setTheSecs.userInteractionEnabled = NO;
    self.setTheHours.userInteractionEnabled = NO;
    self.killButton.userInteractionEnabled = NO;
}

-(void)freeMode{
    self.setTheMins.userInteractionEnabled = YES;
    self.setTheSecs.userInteractionEnabled = YES;
    self.setTheHours.userInteractionEnabled = YES;
    self.initiateButton.userInteractionEnabled = YES;
}

- (void)autoIncrement
{
    int hoursInt = floor((double)(_numberOfTimer/3600));
    int minutesInt = floor((double)(_numberOfTimer/60));
    minutesInt = minutesInt - (hoursInt * 60);
    int secondsInt = _numberOfTimer - (hoursInt * 3600) - (minutesInt *60);
    if (_numberOfTimer == 0) {
        NSString *stringi = [NSString stringWithFormat:@"%@ ", self.tagOfTimer.text];
        [General showOKAlertWithTitle:stringi andMessage:nil delegate:nil];
        [self kill:nil];
    }
    NSString *minutesString;
    if (minutesInt <10) minutesString = [NSString stringWithFormat:@"0%i:", minutesInt];
    else minutesString = [NSString stringWithFormat:@"%i:", minutesInt];
    
    NSString *secondsString;
    if (secondsInt <10) secondsString = [NSString stringWithFormat:@"0%i", secondsInt];
    else secondsString = [NSString stringWithFormat:@"%i", secondsInt];
    
    NSString *hoursString;
    if (hoursInt <10) hoursString = [NSString stringWithFormat:@"0%i:", hoursInt];
    else hoursString = [NSString stringWithFormat:@"%i:", hoursInt];
    
    _minslabel.text = minutesString;
    _secsLabel.text = secondsString;
    _hoursLabel.text = hoursString;
    
    _numberOfTimer--;
}

-(IBAction)initiate:(id)sender
{
    self.counter = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(autoIncrement) userInfo:nil repeats:YES];
    [self.counter fire];
    [self blockMode];
    
}

- (IBAction)kill:(id)sender;
{
    [self.counter invalidate];
    [self freeMode];
}


@end
