//
//  ADBRequestedCell.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/11/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBRequestedCell.h"
#import <QuartzCore/QuartzCore.h>

@interface ADBRequestedCell(){
    int units;
}

@end

@implementation ADBRequestedCell

@synthesize nameLabel;
@synthesize providerLabel;
@synthesize referenceLabel;
@synthesize stockLabel;
@synthesize stockNum;
@synthesize requestedLabel;
@synthesize requestedNum;
@synthesize orderedLabel;
@synthesize orderedNum;
@synthesize orderBut;
@synthesize rejectBut;
@synthesize stepper;

@synthesize reagent = _reagent;

@synthesize delegate;

-(int)unitsApproved{
    return units;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    float dim = 0.2;
    self.stockNum.alpha = dim;
    self.orderedNum.alpha = dim;
}

-(void)setUnits:(int)aunits{
    units = aunits;
    NSString *string = [NSString stringWithFormat:@"Requested %i Unit", aunits];
    if (aunits > 1) {
        string = [string stringByAppendingString:@"s"];
    }
    [self.orderBut setTitle:string forState:UIControlStateNormal];
}

-(void)stepperChanged:(UIStepper *)sender{
    [self setUnits:(int)sender.value];
}

-(void)setReagent:(ComertialReagent *)reagent{
    _reagent = reagent;
    int x = 0;
    for (ReagentInstance *instance in reagent.reagentInstances) {
        if ([instance.reiStatus isEqualToString:@"requested"]) {
            x++;
        }
    }
    self.stepper.value = (float)x;
    [self setUnits:(int)x];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
