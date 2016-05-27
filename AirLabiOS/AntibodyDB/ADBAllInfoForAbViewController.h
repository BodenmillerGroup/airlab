//
//  ADBAllInfoForAbViewController.h
// AirLab
//
//  Created by Raul Catena on 7/7/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBValidationBoxViewController.h"
#import "ADBDefineApplicationsViewController.h"
#import "ADBAddKitViewController.h"
#import "ADBAddAntibodyViewController.h"

@interface ADBAllInfoForAbViewController : ADBMasterViewController <ValidationNote, ApplicationDefinition, AddAntibodyProtocol, AddLotProtocol>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andConjugate:(LabeledAntibody *)conjugate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andLot:(Lot *)lot;

@end
