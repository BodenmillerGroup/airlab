//
//  ADBChooseGroupViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/21/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol ChooseGroup <NSObject>
-(void)didChooseGroupPerson:(ZGroupPerson *)groupPerson;
@end

@interface ADBChooseGroupViewController : ADBMasterViewController

@property (nonatomic, assign) id<ChooseGroup>delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGroups:(NSSet *)groups;

@end
