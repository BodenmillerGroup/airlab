//
//  ADBFlexiCloneViewController.h
//  AirLab
//
//  Created by Raul Catena on 1/21/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol FlexiClone <NSObject>

-(void)didSelectFlexiClone:(Clone *)clone from:(ADBMasterViewController *)controller;

@end

@interface ADBFlexiCloneViewController : ADBMasterViewController

@property (nonatomic, weak) id<FlexiClone>delegate;

@end
