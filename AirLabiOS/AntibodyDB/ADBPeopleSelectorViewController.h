//
//  ADBPeopleSelectorViewController.h
//  AirLab
//
//  Created by Raul Catena on 6/30/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol PeopleSelected <NSObject>

-(void)didSelectPeople:(NSArray *)people;

@end

@interface ADBPeopleSelectorViewController : ADBMasterViewController

@property (nonatomic, assign) id<PeopleSelected>delegate;
@property (nonatomic, assign) BOOL unique;

@end
