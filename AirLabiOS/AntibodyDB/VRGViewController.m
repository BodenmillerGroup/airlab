//
//  VRGViewController.m
//  Vurig Calendar
//
//  Created by in 't Veen Tjeerd on 5/29/12.
//  Copyright (c) 2012 Vurig. All rights reserved.
//

#import "VRGViewController.h"



@interface VRGViewController ()

@end

@implementation VRGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Calendar";
	// Do any additional setup after loading the view, typically from a nib.
    
    VRGCalendarView *calendar = [[VRGCalendarView alloc] init];
    calendar.center = CGPointMake(self.view.center.x, calendar.bounds.size.height/2);
    calendar.delegate=self;
    [self.view addSubview:calendar];
    
    
    
}

-(void)calendarView:(VRGCalendarView *)calendarView switchedToMonth:(int)month targetHeight:(float)targetHeight animated:(BOOL)animated {
    NSCalendar *cal = [[NSCalendar alloc]initWithCalendarIdentifier:@"Gregorian"];
    NSDateComponents *comps = [cal components:(NSCalendarUnitMonth) fromDate:[NSDate date]];
    if (month==[comps month]) {
        NSArray *dates = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:5], nil];
        [calendarView markDates:dates];
    }
}

-(void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date {
    NSLog(@"Selected date = %@",date);
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
