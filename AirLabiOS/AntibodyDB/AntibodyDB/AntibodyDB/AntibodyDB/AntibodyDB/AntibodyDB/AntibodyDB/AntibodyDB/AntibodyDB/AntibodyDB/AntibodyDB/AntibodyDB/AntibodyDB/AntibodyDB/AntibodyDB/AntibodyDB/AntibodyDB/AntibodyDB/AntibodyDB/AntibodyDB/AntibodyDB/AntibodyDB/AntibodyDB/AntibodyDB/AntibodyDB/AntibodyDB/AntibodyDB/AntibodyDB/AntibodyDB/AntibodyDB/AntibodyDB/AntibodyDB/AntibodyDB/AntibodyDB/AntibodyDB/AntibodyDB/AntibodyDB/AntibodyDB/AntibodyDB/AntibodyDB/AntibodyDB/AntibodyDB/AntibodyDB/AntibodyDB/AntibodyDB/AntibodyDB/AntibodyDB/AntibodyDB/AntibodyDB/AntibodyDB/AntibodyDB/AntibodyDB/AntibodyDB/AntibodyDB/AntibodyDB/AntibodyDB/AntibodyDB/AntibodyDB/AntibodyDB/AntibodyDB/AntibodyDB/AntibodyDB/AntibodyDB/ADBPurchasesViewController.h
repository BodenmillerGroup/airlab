//
//  ADBPurchasesViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/11/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBRightControllerViewController.h"
#import "ADBRequestedCell.h"
#import "ADBOrderedCell.h"
#import "ADBApprovedCellTableViewCell.h"
#import "ADBManualComertialReagentViewController.h"

@interface ADBPurchasesViewController : ADBRightControllerViewController<RequestedCellProtocol, OrderedCellProtocol, ApprovedCellProtocol, ComertialReagentAddProtocol>

@property (nonatomic, weak) IBOutlet UISegmentedControl *segment;

-(IBAction)segementChanged:(UISegmentedControl *)sender;

@end
