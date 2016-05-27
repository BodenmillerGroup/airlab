//
//  ADBCloneSelectorViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 4/1/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol CloneSelected;

@interface ADBCloneSelectorViewController : ADBMasterViewController

@property (nonatomic, weak) id<CloneSelected>delegate;
@property (nonatomic, strong) Clone *clone;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil clone:(Clone *)clone;

@end

@protocol CloneSelected <NSObject>

-(void)didSelectClone:(Clone *)clone;
-(void)didSelectLot:(Lot *)lot;

@end
