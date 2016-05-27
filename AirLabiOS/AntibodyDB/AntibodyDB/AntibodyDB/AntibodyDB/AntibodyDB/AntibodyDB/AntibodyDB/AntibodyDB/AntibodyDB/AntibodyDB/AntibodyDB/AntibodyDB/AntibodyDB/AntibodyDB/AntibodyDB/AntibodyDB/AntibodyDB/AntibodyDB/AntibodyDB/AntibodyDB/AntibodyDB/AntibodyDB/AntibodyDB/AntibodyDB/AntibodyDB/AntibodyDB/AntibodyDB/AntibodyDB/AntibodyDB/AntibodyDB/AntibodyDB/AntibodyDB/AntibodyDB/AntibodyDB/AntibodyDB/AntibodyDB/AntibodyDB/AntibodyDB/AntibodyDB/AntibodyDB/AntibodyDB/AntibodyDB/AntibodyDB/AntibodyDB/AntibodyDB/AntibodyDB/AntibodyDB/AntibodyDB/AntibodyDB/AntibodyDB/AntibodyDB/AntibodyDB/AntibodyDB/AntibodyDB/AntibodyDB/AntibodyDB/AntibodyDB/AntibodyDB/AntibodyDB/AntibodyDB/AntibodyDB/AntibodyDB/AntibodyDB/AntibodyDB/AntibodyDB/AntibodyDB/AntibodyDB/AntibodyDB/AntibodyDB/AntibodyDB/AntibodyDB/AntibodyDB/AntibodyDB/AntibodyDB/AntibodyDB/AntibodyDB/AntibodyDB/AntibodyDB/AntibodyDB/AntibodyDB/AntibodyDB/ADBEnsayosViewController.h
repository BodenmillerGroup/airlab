//
//  ADBPartsViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 6/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBAddEnsayoViewController.h"

@interface ADBEnsayosViewController : ADBMasterViewController<EnsayoProtocol>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPlan:(Plan *)plan;

@end
