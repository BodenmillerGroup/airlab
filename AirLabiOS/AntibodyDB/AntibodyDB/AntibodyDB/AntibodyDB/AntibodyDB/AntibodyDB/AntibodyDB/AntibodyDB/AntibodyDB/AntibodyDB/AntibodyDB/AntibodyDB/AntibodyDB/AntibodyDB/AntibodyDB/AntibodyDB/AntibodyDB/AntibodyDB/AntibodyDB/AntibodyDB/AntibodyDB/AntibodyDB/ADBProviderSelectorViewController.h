//
//  ADBProviderSelectorViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/7/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol ProviderSelection;
@class Provider;

@interface ADBProviderSelectorViewController : ADBMasterViewController

@property (weak, nonatomic) id<ProviderSelection>delegate;

@end

@protocol ProviderSelection <NSObject>

-(void)didSelectProvider:(Provider *)provider;

@end
