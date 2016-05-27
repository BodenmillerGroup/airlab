//
//  ADBAllSamplesViewController.h
// AirLab
//
//  Created by Raul Catena on 10/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol SelectedSample <NSObject>

-(void)didSelectSample:(Sample *)aSample;

@end

@interface ADBAllSamplesViewController : ADBMasterViewController

@property (nonatomic, weak) id<SelectedSample>delegate;

@end
