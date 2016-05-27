//
//  ADBPurchaseBoxViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/11/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBPurchaseBoxViewController.h"

@interface ADBPurchaseBoxViewController ()

@property (nonatomic, strong) ComertialReagent *reagent;

@end

@implementation ADBPurchaseBoxViewController

@synthesize stepper = _stepper;
@synthesize label = _label;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andReagent:(ComertialReagent *)reagent
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.reagent = reagent;
    }
    return self;
}

-(void)didTapStepper:(UIStepper *)sender{
    self.label.text = [NSString stringWithFormat:@"Request %i unit", (int)sender.value];
    if (sender.value > 1) {
        self.label.text = [self.label.text stringByAppendingString:@"s"];
    }
}

-(void)execute:(id)sender{
    if(_reagent){
        [self.delegate didExecuteOrderOfReagent:_reagent WithAmoung:(int)_stepper.value];
        return;
    }
    [self.delegate didExecuteOrderWithAmoung:(int)_stepper.value];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //TODO deprecated
    [General addBorderToButton:self.button withColor:[UIColor orangeColor]];
    self.preferredContentSize = CGSizeMake(268, 165);
}

@end
