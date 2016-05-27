//
//  ADBChemistryViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBChemistryViewController.h"


@implementation ADBChemistryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	_pm.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _pm.layer.borderWidth = 1.0f;
	self.title = @"Chemistry Calculator";
    self.preferredContentSize = self.view.frame.size;
    [self selecteType];

}

-(void)selecteType{
    NSArray *array = @[_molarity, _weight, _volume];
    for(int x = 0; x<array.count; x++){
        UITextField *field  = [array objectAtIndex:x];
        if(x == _choice.selectedSegmentIndex)field.userInteractionEnabled = NO;
        else field.userInteractionEnabled = YES;
    }
    
    for(UITextField *field in array){
        if(!field.userInteractionEnabled){
            field.layer.borderColor = [UIColor redColor].CGColor;
            field.layer.borderWidth = 3.0f;
        }else{
            field.layer.borderColor = [UIColor lightGrayColor].CGColor;
            field.layer.borderWidth = 1.0f;
        }
    }
    
	[self removeValues];
}

-(float)molarityUnitAdjust:(float)molarity{
    molarity = molarity /pow(10.0f, (double)(18-self.unitsMolarity.selectedSegmentIndex*3));
	return molarity;
}

-(float)weightUnitAdjust:(float)weight{
	weight = weight /pow(10.0f, (double)(9-self.unitsWeight.selectedSegmentIndex*3));
	return weight;
}

-(float)volumeUnitAdjust:(float)volume{
    volume = volume /pow(10.0f, (double)(12-self.unitsVolume.selectedSegmentIndex*3));
	return volume;
}

-(float)molarityResultAdjust:(float)molarity{
    molarity = molarity /pow(10.0f, (double)(18-self.unitsMolarity.selectedSegmentIndex*3));
	return molarity;
}

-(float)weightResultAdjust:(float)weight{
	weight = weight /pow(10.0f, (double)(9-self.unitsWeight.selectedSegmentIndex*3));
	return weight;
}

-(float)volumeResultAdjust:(float)volume{
	volume = volume /pow(10.0f, (double)(12-self.unitsVolume.selectedSegmentIndex*3));
	return volume;
}

-(void)executeOne{
	if (self.choice.selectedSegmentIndex == 0 && [_weight.text length]>0 && [_volume.text length]>0) {
		float pm = [self.pm.text floatValue];
		float molarity = ([self weightUnitAdjust:[self.weight.text floatValue]]/pm)/[self volumeUnitAdjust:[self.volume.text floatValue]];
		molarity = [self molarityResultAdjust:molarity];
		self.molarity.text = [NSString stringWithFormat:@"%.4g", molarity];
	}else if (self.choice.selectedSegmentIndex == 1 && [_molarity.text length]>0 && [_volume.text length]>0) {
		float pm = [self.pm.text floatValue];
		float weight = [self molarityUnitAdjust:[self.molarity.text floatValue]] * [self volumeUnitAdjust:[self.volume.text floatValue]] * pm;
		weight = [self weightResultAdjust:weight];
		self.weight.text = [NSString stringWithFormat:@"%.4g", weight];
	}else {
		if ([_weight.text length]>0 && [_molarity.text length]>0) {
			float pm = [self.pm.text floatValue];
			float volume = [self weightUnitAdjust:[self.weight.text floatValue]]/(pm*[self molarityUnitAdjust:[self.molarity.text floatValue]]);
			volume = [self volumeResultAdjust:volume];
			self.volume.text = [NSString stringWithFormat:@"%.4g", volume];
		}
	}
}

-(void)executeTwo{
    [self executeOne];return;
	if (self.choice.selectedSegmentIndex == 0) {
		if ([self.pm.text length]>0 && [self.weight.text length]>0 && [self.volume.text length]>0) {
			[self executeOne];
		}
	}else if (self.choice.selectedSegmentIndex == 1) {
		if ([self.pm.text length]>0 && [self.molarity.text length]>0 && [self.volume.text length]>0) {
			[self executeOne];
		}
	}else {
		if ([self.pm.text length]>0 && [self.weight.text length]>0 && [self.molarity.text length]>0) {
			[self executeOne];
		}
	}
}

-(void)removeValues{
	_molarity.text = nil;
	_weight.text = nil;
	_volume.text = nil;
	_pm.text = nil;
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
    BOOL valid = [General textField:textField onlyNumbersInRange:range replacementString:string];
    if(valid)[self executeOne];
    return valid;
}


@end
