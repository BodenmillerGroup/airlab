//
//  ADBTargetViewController.h
// AirLab
//
//  Created by Raul Catena on 4/1/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"


@protocol TargetSelection;
@class Protein;

@interface ADBTargetViewController : ADBMasterViewController


@property (nonatomic, weak) id<TargetSelection>delegate;
@property (nonatomic, assign) BOOL multiselector;

@end

@protocol TargetSelection <NSObject>

-(void)didSelectTarget:(Protein *)target;

@end