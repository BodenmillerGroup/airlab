//
//  ADBInfoCommertialViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/11/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBPurchaseBoxViewController.h"

@interface ADBInfoCommertialViewController : ADBMasterViewController<PurchaseBoxProtocol>

@property (nonatomic, strong) ComertialReagent *reagent;
@property (weak, nonatomic) IBOutlet UIButton *imageQR;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andReagent:(ComertialReagent *)reagent;


@end
