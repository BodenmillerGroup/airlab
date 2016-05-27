//
//  ADBAddKitViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/7/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBProviderSelectorViewController.h"

@class Lot;
@protocol AddLotProtocol;

@interface ADBAddKitViewController : ADBMasterViewController <ProviderSelection>

@property (nonatomic, strong) Lot *lot;

@property (weak, nonatomic) IBOutlet UITextField *lotNumber;
@property (weak, nonatomic) IBOutlet UIDatePicker *lotOrderDate;
@property (weak, nonatomic) IBOutlet UIDatePicker *lotExpirationDate;
@property (weak, nonatomic) IBOutlet UIButton *providerButton;
@property (weak, nonatomic) IBOutlet UILabel *providerLabel;
@property (weak, nonatomic) IBOutlet UITextField *providerTextField;
@property (weak, nonatomic) IBOutlet UISwitch *carrierSwitch;
@property (weak, nonatomic) IBOutlet UILabel *carrierLabel;
@property (weak, nonatomic) IBOutlet UITextField *dataSheetLink;
@property (weak, nonatomic) IBOutlet UITextField *orderNumber;
@property (weak, nonatomic) IBOutlet UISlider *amount;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@property (weak, nonatomic) id<AddLotProtocol>delegate;

-(IBAction)selectProvider:(UIButton *)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andClone:(Clone *)aClone;
-(IBAction)concentrationChanged:(UISlider *)sender;

@end

@protocol AddLotProtocol <NSObject>

-(void)didAddLot:(Lot *)lot;

@end
