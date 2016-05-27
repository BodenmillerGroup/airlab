//
//  ADBAddPurchaseViewController.h
// AirLab
//
//  Created by Raul Catena on 5/11/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol AddInstanceOfReagent <NSObject>

-(void)didAddInstancesOfReagent:(NSArray *)instances;

@end

@interface ADBAddPurchaseViewController : ADBMasterViewController

@property (nonatomic, assign) id<AddInstanceOfReagent>delegate;
@property (nonatomic, weak) IBOutlet UISegmentedControl *optionControl;

@end
