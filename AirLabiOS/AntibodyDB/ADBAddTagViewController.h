//
//  ADBAddTagViewController.h
// AirLab
//
//  Created by Raul Catena on 3/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol AddTagProtocol;

@interface ADBAddTagViewController : ADBMasterViewController

@property (nonatomic,weak) id<AddTagProtocol>delegate;

@end

@protocol AddTagProtocol <NSObject>

-(void)addTagProtocol:(ADBAddTagViewController *)controller;

@end
