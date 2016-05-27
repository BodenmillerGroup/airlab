//
//  ADBAddPanelToExpViewController.m
// AirLab
//
//  Created by Raul Catena on 10/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddPanelToExpViewController.h"

@interface ADBAddPanelToExpViewController ()

@property (nonatomic, strong) Panel *panel;

@end

@implementation ADBAddPanelToExpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [General addBorderToButton:_doneBut withColor:[UIColor orangeColor]];
    self.preferredContentSize = self.view.bounds.size;
}

-(id)initWithPanel:(Panel *)panel{
    self = [self init];
    if (self) {
        self.panel = panel;
    }
    return self;
}

-(void)done{
    [self.delegate didAddDetailsForPanel:_panel expType:[_typeOfExp selectedSegmentIndex] andTissue:_tissueType.text isValidation:_validation.on];
}

@end
