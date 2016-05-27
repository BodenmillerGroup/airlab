//
//  ADBClonesByProtViewController.h
// AirLab
//
//  Created by Raul Catena on 5/15/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBAddAntibodyViewController.h"

@interface ADBClonesByProtViewController : ADBMasterViewController <AddAntibodyProtocol>

@property (nonatomic, strong) Protein *protein;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andProtein:(Protein *)prot;

@end
