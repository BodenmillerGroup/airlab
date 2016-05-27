//
//  ADBKeyBoardViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 7/8/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBKeyBoardViewController.h"

@interface ADBKeyBoardViewController (){
    BOOL hasComma;
}

@property (nonatomic, assign) float value;
@property (nonatomic, assign) float decimals;

@end

@implementation ADBKeyBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _value = 0.0f;
        _decimals = 0.0f;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        _value = 0.0f;
        _decimals = 0.0f;
    }
    return self;
}

-(void)keyPressed:(UIButton *)sender{
    if (hasComma == YES && sender.tag == -1) {
        return;
    }
    if (sender.tag == -1) {
        hasComma = YES;
        return;
    }
    if (sender.tag == -2) {
        hasComma = NO;
        _value = 0.0f;
        _decimals = 0.0f;
        [_currentValueLabel setText:[NSString stringWithFormat:@"%.0f.%.0f", _value, _decimals]];
        return;
    }
    
    if (hasComma == YES) {
        _decimals = _decimals * 10 + sender.tag;
    }else{
        _value = _value * 10 + sender.tag;
    }
    [_currentValueLabel setText:[NSString stringWithFormat:@"%.0f.%.0f", _value, _decimals]];
}

-(void)ok:(id)sender{
    if (_zdelegate) {
        NSString *numberToSend = [NSString stringWithFormat:@"%.0f.%.0f", _value, _decimals];
        NSLog(@"number %@", numberToSend);
        NSLog(@"number %@ to %@", numberToSend, NSStringFromClass([_zdelegate class]));
        [_zdelegate sendNumber:numberToSend];
    }else{
        [General showOKAlertWithTitle:@"Nod el" andMessage:nil];
    }
}


@end
