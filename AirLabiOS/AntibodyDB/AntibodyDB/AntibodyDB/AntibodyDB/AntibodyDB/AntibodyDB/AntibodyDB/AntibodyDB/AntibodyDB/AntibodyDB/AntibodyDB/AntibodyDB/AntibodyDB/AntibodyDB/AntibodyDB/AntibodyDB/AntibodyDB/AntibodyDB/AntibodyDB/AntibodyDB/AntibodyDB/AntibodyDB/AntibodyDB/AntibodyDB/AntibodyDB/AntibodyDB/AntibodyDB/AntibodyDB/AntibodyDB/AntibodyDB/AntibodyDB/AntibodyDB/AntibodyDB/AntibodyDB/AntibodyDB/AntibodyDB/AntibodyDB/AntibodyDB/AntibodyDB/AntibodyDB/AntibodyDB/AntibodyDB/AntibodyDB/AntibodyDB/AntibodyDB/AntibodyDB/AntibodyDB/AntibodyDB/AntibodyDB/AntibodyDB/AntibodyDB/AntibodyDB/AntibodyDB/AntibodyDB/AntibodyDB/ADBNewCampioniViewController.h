//
//  ADBNewCampioniViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 6/16/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol SampleNewProtocol <NSObject>

-(void)didAddSample:(Sample *)sample;

@end

@interface ADBNewCampioniViewController : ADBMasterViewController

@property (nonatomic, assign) id<SampleNewProtocol>delegate;
@property (weak, nonatomic) IBOutlet UIButton *qrImage;
@property (nonatomic, weak) IBOutlet UITextField *conc;
@property (nonatomic, weak) IBOutlet UITextField *quantity;
@property (strong, nonatomic) IBOutlet UITextField *nameOfSample;
@property (nonatomic, weak) IBOutlet UISegmentedControl *molar;
@property (nonatomic, weak) IBOutlet UISegmentedControl *gramsLiter;
@property (weak, nonatomic) IBOutlet UISegmentedControl *volume;
@property (weak, nonatomic) IBOutlet UISegmentedControl *amount;
@property (weak, nonatomic) IBOutlet UILabel *parentLabel;
@property (weak, nonatomic) IBOutlet UILabel *aliquotLabel;
@property (weak, nonatomic) IBOutlet UITextField *aliquots;
@property (weak, nonatomic) IBOutlet UIButton *addNewPropButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andType:(NSString *)type orSample:(Sample *)sample;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andType:(NSString *)type orParent:(Sample *)parent;
- (IBAction)addNewProperty:(id)sender;
- (IBAction)touchedSegmented:(UISegmentedControl *)sender;

@end
