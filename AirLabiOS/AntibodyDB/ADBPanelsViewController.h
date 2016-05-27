//
//  ADBPanelsViewController.h
// AirLab
//
//  Created by Raul Catena on 5/7/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBRightControllerViewController.h"
#import "ADBMetalsViewController.h"


@protocol SelectedPanel <NSObject>

-(void)didSelectPanel:(Panel *)panel;

@end

@interface ADBPanelsViewController : ADBRightControllerViewController <AddPanelDelegate>

@property (nonatomic, weak) id<SelectedPanel>delegate;

@end
