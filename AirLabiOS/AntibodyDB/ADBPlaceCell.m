//
//  ADBPlaceCell.m
// AirLab
//
//  Created by Raul Catena on 5/15/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBPlaceCell.h"

@implementation ADBPlaceCell

@synthesize imageView = _imageView;
@synthesize label1 = _label1;
@synthesize label2 = _label2;
@synthesize place;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
