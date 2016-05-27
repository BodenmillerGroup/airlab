//
//  ADBAddRoomViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/16/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol AddHabitacionProtocol <NSObject>

-(void)didAddHabitacion:(Place *)place;

@end

@interface ADBAddRoomViewController : ADBMasterViewController

@property (nonatomic, assign) id<AddHabitacionProtocol>delegate;
@property (nonatomic, weak) IBOutlet UITextField *nameHab;
@property (nonatomic, weak) IBOutlet UIButton *create;
@property (nonatomic, weak) Place *place;

@end
