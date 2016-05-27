//
//  ADBDilutorCalculator.m
//  AirLab
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBDilutorViewController.h"

@implementation ADBDilutorCalculator


-(id)init{
    self = [self initWithNibName:@"ADBDilutorViewController" bundle:nil];
    if(self){
    
    }
    return self;
}

-(double)volumeAdjust:(double)volume withSegmentedControl:(UISegmentedControl *)sc{
	double result = volume;
    if (sc == self.volumeFinalUnit || sc == self.volumeInitialUnit || sc == self.volumeToPrepareUnit) {

        if (sc.selectedSegmentIndex == 0) {
            result = volume / 1000000;
        }
        if (sc.selectedSegmentIndex == 1) {
            result = volume / 1000;
        }
    }
    return result;
}

-(double)massAdjust:(double)mass withSegmentedControl:(UISegmentedControl *)sc{
	double result = mass;
    if (sc == self.massFinalUnit || sc == self.massInitialUnit) {
        if (sc.selectedSegmentIndex == 0) {
            result = mass / 1000000000;
        }
        if (sc.selectedSegmentIndex == 1) {
            result = mass / 1000000;
        }
        if (sc.selectedSegmentIndex == 2) {
            result = mass / 1000;
        }
    }
    return result;	
}

-(void)calculate{
	if ([self.initial.text length]>0 && [self.final.text length]>0 && [self.volumeToPrepare.text length]>0) {
		double finalConc = (double)[self massAdjust:[self.final.text floatValue] withSegmentedControl:self.massFinalUnit]/(double)[self volumeAdjust:1.0 withSegmentedControl:self.volumeFinalUnit];
		double initialConc = (double)[self massAdjust:[self.initial.text floatValue] withSegmentedControl:self.massInitialUnit]/(double)[self volumeAdjust:1.0 withSegmentedControl:self.volumeInitialUnit];

		double ratio = initialConc/finalConc;
        if (ratio>1) {
            float volumeToTake = (double)[self.volumeToPrepare.text floatValue]/ratio;
            float volumeToAdjust = (double)[self.volumeToPrepare.text floatValue] - volumeToTake;
            NSString *unit;
            if (self.volumeFinalUnit.selectedSegmentIndex == 0) {
                unit = @"uL";
            }else if (self.volumeFinalUnit.selectedSegmentIndex == 1){
                unit = @"mL";
            }else{
                unit = @"L";
            }
            NSString *string = [NSString stringWithFormat:@"%.2f %@ of the stock solution + %.2f %@ of diluent", volumeToTake, unit, volumeToAdjust, unit];
            self.result.text = string;
        }else{
            NSString *string = [NSString stringWithFormat:@"Check the input values, the final concentration must be lesser than the concentration of the stock"];
            self.result.text = string;
        }
	}
}

-(void)clear{
	self.initial.text = nil;
	self.final.text = nil;
	self.volumeToPrepare.text = nil;
}

-(void)calculateFromSwitches{
    [self calculate];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _volumeToPrepare.text = nil;
	
	self.title = @"Dilution Calculator";
    self.preferredContentSize = self.view.bounds.size;
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
    BOOL valid = [General textField:textField onlyNumbersInRange:range replacementString:string];
    if(valid)[self calculate];
    return valid;
}

-(void)log{
    
}


@end
