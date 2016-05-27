//
//  ADBComertialReagentPickerViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 6/4/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "adBMasterViewController.h"

@protocol ComReagentPicker <NSObject>

-(void)didPickComertialReagent:(ComertialReagent *)reagent;

@end

@interface ADBComertialReagentPickerViewController : ADBMasterViewController

@property (nonatomic, assign) id<ComReagentPicker>delegate;

@end
