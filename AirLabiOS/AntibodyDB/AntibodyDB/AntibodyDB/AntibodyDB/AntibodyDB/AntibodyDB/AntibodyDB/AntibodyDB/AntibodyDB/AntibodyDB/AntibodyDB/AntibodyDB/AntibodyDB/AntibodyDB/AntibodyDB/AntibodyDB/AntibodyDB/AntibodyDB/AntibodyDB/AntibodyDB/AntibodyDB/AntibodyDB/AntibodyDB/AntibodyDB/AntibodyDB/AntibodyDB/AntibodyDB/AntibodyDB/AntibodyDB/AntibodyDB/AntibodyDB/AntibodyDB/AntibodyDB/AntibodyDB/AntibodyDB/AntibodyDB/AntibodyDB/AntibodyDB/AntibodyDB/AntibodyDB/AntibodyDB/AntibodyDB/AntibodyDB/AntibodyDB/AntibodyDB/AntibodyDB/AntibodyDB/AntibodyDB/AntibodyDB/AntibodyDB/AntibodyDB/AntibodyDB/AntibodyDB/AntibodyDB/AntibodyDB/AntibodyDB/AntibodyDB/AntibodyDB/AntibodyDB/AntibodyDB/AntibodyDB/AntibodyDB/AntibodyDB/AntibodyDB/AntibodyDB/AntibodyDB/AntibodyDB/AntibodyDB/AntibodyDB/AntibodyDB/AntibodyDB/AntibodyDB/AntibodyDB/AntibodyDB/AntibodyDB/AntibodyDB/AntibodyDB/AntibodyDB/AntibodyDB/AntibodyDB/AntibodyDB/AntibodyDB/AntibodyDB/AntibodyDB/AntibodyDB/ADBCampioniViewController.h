//
//  ADBCampioniViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 6/16/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBAddSampleViewController.h"
#import "ADBNewCampioniViewController.h"

@interface ADBCampioniViewController : ADBMasterViewController<SampleTypeChosen, SampleNewProtocol>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andParent:(Sample *)parent;

@end
