//
//  ADBManualComertialReagentViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 6/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBProviderSelectorViewController.h"

@protocol ComertialReagentAddProtocol <NSObject>

-(void)didAddReagentManually:(ComertialReagent *)reagent;

@end

@interface ADBManualComertialReagentViewController : ADBMasterViewController <ProviderSelection>

@property (nonatomic, assign) id<ComertialReagentAddProtocol>delegate;
@property (weak, nonatomic) IBOutlet UITextField *nameOfReagent;
@property (weak, nonatomic) IBOutlet UITextField *reference;
@property (weak, nonatomic) IBOutlet UIButton *providerButton;
@property (weak, nonatomic) IBOutlet UITextField *aNewProvider;
@property (weak, nonatomic) IBOutlet UITextField *price;
@property (weak, nonatomic) IBOutlet UIButton *addTagButton;

-(IBAction)selectProvider:(UIButton *)sender;

@end
