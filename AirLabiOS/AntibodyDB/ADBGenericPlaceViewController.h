//
//  ADBGenericPlaceViewController.h
// AirLab
//
//  Created by Raul Catena on 5/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBAddPlaceViewController.h"
#import "ADBRackView.h"
#import "ADBScatolaView.h"
#import "ADBTubePopViewController.h"
#import "ADBReagentPickerViewController.h"


@interface ADBGenericPlaceViewController : ADBMasterViewController <AddPlaceProtocol, RackViewDelegate, ScatolaViewDelegate, TubePicker, TubePopDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPlace:(Place *)place;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPlace:(Place *)place andScope:(NSArray *)scopePlaces;

@end
