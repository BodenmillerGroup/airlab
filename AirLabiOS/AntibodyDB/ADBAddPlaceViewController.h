//
//  ADBAddPlaceViewController.h
// AirLab
//
//  Created by Raul Catena on 5/16/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol AddPlaceProtocol <NSObject>

-(void)didAddPlace:(Place *)place;

@end

@interface ADBAddPlaceViewController : ADBMasterViewController

@property (nonatomic, assign) id<AddPlaceProtocol>delegate;
@property (nonatomic, weak) IBOutlet UISegmentedControl *typePlace;
@property (nonatomic, weak) IBOutlet UISegmentedControl *temperature;
@property (nonatomic, weak) IBOutlet UITextField *name;

@property (nonatomic, weak) IBOutlet UIView *shelvesPanel;
@property (nonatomic, weak) IBOutlet UIView *racksPanel;
@property (nonatomic, weak) IBOutlet UIView *boxesPanel;
@property (nonatomic, weak) IBOutlet UIView *layoutPanel;

@property (nonatomic, weak) IBOutlet UIStepper *shelvesSwitch;
@property (nonatomic, weak) IBOutlet UIStepper *racksSwitch;
@property (nonatomic, weak) IBOutlet UIStepper *boxesSwitch;
@property (nonatomic, weak) IBOutlet UIStepper *layoutSwitch;
@property (nonatomic, weak) IBOutlet UIStepper *layout2Switch;

@property (nonatomic, weak) IBOutlet UILabel *shelvesLabel;
@property (nonatomic, weak) IBOutlet UILabel *racksLabel;
@property (nonatomic, weak) IBOutlet UILabel *boxesLabel;
@property (nonatomic, weak) IBOutlet UILabel *layoutLabel;
@property (nonatomic, weak) IBOutlet UILabel *layout2Label;

@property (nonatomic, weak) IBOutlet UISwitch *racksYes;
@property (nonatomic, weak) IBOutlet UISwitch *boxesYes;

@property (nonatomic, weak) IBOutlet UIButton *createButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withParent:(Place *)parentPlace withX:(NSString *)x andY:(NSString *)y;
-(IBAction)typeChanged:(UISegmentedControl *)sender;

-(IBAction)stepperChanged:(UIStepper *)sender;
-(IBAction)switchChanged:(UISwitch *)sender;

-(IBAction)addPlace;

@end
