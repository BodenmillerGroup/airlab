//
//  ADBPlaceView.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/19/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBPlaceView.h"

@interface ADBPlaceView()



@end

@implementation ADBPlaceView

@synthesize place = _place;

- (id)initWithFrame:(CGRect)frame andPlace:(Place *)aPlace
{
    self = [super initWithFrame:frame];
    if (self) {
        self.place = aPlace;
    }
    return self;
}

-(void)setPlace:(Place *)place{
    _place = place;
    [self setUpLayout];
}

-(void)setUpLayout{
    NSString *sub;
    if([_place.plaType isEqualToString:@"rack"])sub = @"rack.jpg";
    if([_place.plaType isEqualToString:@"box"]){
        if([_place.parent.plaType isEqualToString:@"rack"]){
        
        }else{
            sub = @"box.jpg";
        }
        
    }
    if([_place.plaType isEqualToString:@"other"])sub = @"other.jpg";
    [self.button setBackgroundImage:[UIImage imageNamed:sub] forState:UIControlStateNormal];
    
    if([_place.parent.plaType isEqualToString:@"rack"]){
        //[self.button setTitle:_place.plaName forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        self.label.text = _place.plaName;
    }else{
        self.label.text = _place.plaName;
    }
    
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
