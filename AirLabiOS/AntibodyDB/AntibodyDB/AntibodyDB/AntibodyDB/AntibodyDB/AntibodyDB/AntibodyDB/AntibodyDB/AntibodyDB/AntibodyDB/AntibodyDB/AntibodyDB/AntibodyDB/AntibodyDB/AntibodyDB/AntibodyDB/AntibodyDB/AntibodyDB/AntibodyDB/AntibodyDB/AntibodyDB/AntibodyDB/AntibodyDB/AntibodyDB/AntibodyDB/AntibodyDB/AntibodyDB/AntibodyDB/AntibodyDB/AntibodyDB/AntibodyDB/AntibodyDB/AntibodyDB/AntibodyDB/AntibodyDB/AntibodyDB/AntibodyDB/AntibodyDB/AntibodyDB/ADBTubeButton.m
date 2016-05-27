//
//  ADBTubeButton.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/20/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBTubeButton.h"

@implementation ADBTubeButton

@synthesize tube = _tube;

-(void)setLabel:(NSString *)title ofButton:(UIButton *)button{
    
    button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    button.titleLabel.numberOfLines = 3;
    button.titleLabel.frame = CGRectMake(8, 0, button.bounds.size.width - 8, button.bounds.size.height);
    button.titleLabel.font = [UIFont systemFontOfSize:10];
    [button setTitle:title forState:UIControlStateNormal];
}

- (id)initWithFrame:(CGRect)frame andTube:(id)tube
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tube = tube;
        [self setLabel:[General titleForTube:self.tube] ofButton:self];
        [self setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
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
