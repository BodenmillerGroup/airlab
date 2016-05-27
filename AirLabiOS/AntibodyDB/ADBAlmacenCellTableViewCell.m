//
//  ADBAlmacenCellTableViewCell.m
// AirLab
//
//  Created by Raul Catena on 5/11/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAlmacenCellTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ADBAlmacenCellTableViewCell

@synthesize nameLabel;
@synthesize providerLabel;
@synthesize referenceLabel;
@synthesize stockLabel;
@synthesize stockNum;
@synthesize requestedLabel;
@synthesize requestedNum;
@synthesize orderedLabel;
@synthesize orderedNum;
@synthesize instance;

- (void)awakeFromNib
{
    self.nameLabel.text = nil;
    self.providerLabel.text = nil;
    self.referenceLabel.text = nil;
    //self.stockLabel.text = nil;
    self.stockNum.text = nil;
    self.stockNum.textColor = [UIColor whiteColor];
    //self.requestedLabel.text = nil;
    self.requestedNum.text = nil;
    self.requestedNum.textColor = [UIColor whiteColor];
    //self.orderedLabel.text = nil;
    self.orderedNum.text = nil;
    self.orderedNum.textColor = [UIColor whiteColor];
    //self.arrivedLabel.text = nil;
    
    NSArray *labels = @[self.stockNum, self.requestedNum, self.orderedNum];
    NSArray *colors = @[
                        [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1],
                        [UIColor redColor],
                        [UIColor orangeColor],
                        ];
    for (int x = 0; x<3; x++) {
        UILabel *label = [labels objectAtIndex:x];
        label.layer.cornerRadius = label.frame.size.width/2;
        label.textColor = [colors objectAtIndex:x];
        label.layer.borderColor = [(UIColor *)[colors objectAtIndex:x]CGColor];
        label.layer.borderWidth = 1.0f;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
