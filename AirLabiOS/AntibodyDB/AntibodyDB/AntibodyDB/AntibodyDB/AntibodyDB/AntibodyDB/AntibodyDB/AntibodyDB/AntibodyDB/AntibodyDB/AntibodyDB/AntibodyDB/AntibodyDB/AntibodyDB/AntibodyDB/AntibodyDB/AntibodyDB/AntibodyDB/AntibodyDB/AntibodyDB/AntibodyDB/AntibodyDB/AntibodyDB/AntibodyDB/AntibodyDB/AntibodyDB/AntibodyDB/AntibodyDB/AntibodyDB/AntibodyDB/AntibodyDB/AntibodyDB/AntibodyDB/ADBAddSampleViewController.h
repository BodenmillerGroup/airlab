//
//  ADBAddSampleViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 6/16/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"


@protocol SampleTypeChosen <NSObject>

-(void)willCreateSample:(NSString *)type;

@end

@interface ADBAddSampleViewController : ADBMasterViewController

@property (nonatomic, assign) id<SampleTypeChosen>delegate;

@end
