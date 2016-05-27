//
//  ADBPurchaseBoxViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/11/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol PurchaseBoxProtocol <NSObject>

@optional

-(void)didExecuteOrderWithAmoung:(int)amount;
-(void)didExecuteOrderOfReagent:(ComertialReagent *)reagent WithAmoung:(int)amount;

@end

@interface ADBPurchaseBoxViewController : ADBMasterViewController

@property (nonatomic, weak) IBOutlet UIStepper *stepper;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIButton *button;;
@property (nonatomic, assign) id<PurchaseBoxProtocol>delegate;

-(IBAction)didTapStepper:(UIStepper *)sender;
-(IBAction)execute:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andReagent:(ComertialReagent *)reagent;

@end
