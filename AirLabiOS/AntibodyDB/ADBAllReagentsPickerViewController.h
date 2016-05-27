//
//  ADBAllReagentsPickerViewController.h
// AirLab
//
//  Created by Raul Catena on 10/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol SelectedReagentInstance <NSObject>

-(void)didSelectReagentInstance:(ReagentInstance *)aReagentInstance;

@end

@interface ADBAllReagentsPickerViewController : ADBMasterViewController

@property (nonatomic, weak) id<SelectedReagentInstance>delegate;

@end
