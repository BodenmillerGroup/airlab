//
//  ADBAntibodiesViewController.h
// AirLab
//
//  Created by Raul Catena on 3/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBRightControllerViewController.h"
#import "ADBAddAntibodyViewController.h"
#import "ADBAddKitViewController.h"
#import "ADBDefineApplicationsViewController.h"

@interface ADBAntibodiesViewController : ADBRightControllerViewController <AddAntibodyProtocol, AddLotProtocol, ApplicationDefinition>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andProtein:(Protein *)protein;

@end
