//
//  ADBSelectMemorizedViewController.h
//  AirLab
//
//  Created by Raul Catena on 11/19/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol MemorizedLogin<NSObject>

-(void)selectedLogin:(NSDictionary *)loginDict;

@end

@interface ADBSelectMemorizedViewController : ADBMasterViewController

@property (nonatomic, weak) id<MemorizedLogin>delegate;

@end
