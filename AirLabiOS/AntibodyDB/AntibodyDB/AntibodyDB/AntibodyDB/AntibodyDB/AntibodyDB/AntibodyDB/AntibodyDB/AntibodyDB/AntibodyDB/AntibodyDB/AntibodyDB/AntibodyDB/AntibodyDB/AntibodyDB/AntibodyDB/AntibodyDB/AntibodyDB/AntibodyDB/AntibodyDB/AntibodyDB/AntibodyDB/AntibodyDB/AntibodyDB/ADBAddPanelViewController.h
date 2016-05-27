//
//  ADBAddPanelViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/7/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol AddPanelDelegate;
@class Panel;

@interface ADBAddPanelViewController : ADBMasterViewController

@property (nonatomic, weak) id<AddPanelDelegate>delegate;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmented;

@end

@protocol AddPanelDelegate <NSObject>

-(void)didAddPanel:(Panel *)panel;

@end
