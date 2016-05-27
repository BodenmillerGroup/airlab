//
//  ADBSavedPlatesViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 6/15/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@class Plate;

@protocol SelectedPlate <NSObject>

-(void)didSelectPlate:(Plate *)plate;

@end

@interface ADBSavedPlatesViewController : ADBMasterViewController

@property (nonatomic, assign) id<SelectedPlate>delegate;

@end
