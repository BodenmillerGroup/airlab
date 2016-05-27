//
//  ADBOrderedCell.m
// AirLab
//
//  Created by Raul Catena on 5/11/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBOrderedCell.h"

@implementation ADBOrderedCell

@synthesize nameLabel;
@synthesize providerLabel;
@synthesize referenceLabel;
@synthesize stockLabel;
@synthesize stockNum;
@synthesize requestedLabel;
@synthesize requestedNum;
@synthesize orderedLabel;
@synthesize orderedNum;
@synthesize arrivedButton;

@synthesize reagent;

- (void)awakeFromNib
{
    [super awakeFromNib];
    float dim = 0.2;
    self.stockNum.alpha = dim;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
