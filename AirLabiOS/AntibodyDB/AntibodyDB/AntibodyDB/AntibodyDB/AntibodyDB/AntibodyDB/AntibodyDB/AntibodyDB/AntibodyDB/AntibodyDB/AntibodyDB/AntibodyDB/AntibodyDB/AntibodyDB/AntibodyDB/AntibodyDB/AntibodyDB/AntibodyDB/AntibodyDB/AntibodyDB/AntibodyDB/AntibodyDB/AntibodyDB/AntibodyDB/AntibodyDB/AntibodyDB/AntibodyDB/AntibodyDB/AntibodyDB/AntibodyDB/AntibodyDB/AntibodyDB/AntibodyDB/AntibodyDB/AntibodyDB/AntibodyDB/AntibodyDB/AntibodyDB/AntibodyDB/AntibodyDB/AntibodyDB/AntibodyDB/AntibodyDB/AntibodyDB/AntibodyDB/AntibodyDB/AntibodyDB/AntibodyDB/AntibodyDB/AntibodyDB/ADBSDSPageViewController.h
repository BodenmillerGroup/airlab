//
//  GelCalculatorViewController.h
//  LabPad
//
//  Created by Raul Catena on 5/10/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADBMasterViewController.h"



@interface ADBSDSPageViewController : ADBMasterViewController <UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *reagentsSDS;
@property (nonatomic, strong) NSArray *reagentsSDSB;
@property (nonatomic, strong) NSArray *valuesResolving;
@property (nonatomic, strong) NSArray *valuesStacking;

@property (nonatomic, weak) IBOutlet UISlider *resolvingSlider;
@property (nonatomic, weak) IBOutlet UISlider *stackingSlider;
@property (nonatomic, weak) IBOutlet UISegmentedControl *resolvingVolume;
@property (nonatomic, weak) IBOutlet UISegmentedControl *stackingVolume;
@property (nonatomic, weak) IBOutlet UISwitch *thirtyForty;
@property (nonatomic, weak) IBOutlet UILabel *resolvingLabel;
@property (nonatomic, weak) IBOutlet UILabel *stackingLabel;

-(IBAction)sliderChangesGel:(id)sender;
-(IBAction)segmentsChanged:(id)sender;
-(IBAction)toggleSwitch:(id)sender;


@end
