//
//  ADBNewPlanViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 6/5/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol PlanAdd <NSObject>

-(void)didAddPlan:(Plan *)plan;

@end

@interface ADBNewPlanViewController : ADBMasterViewController

@property (nonatomic, assign) id<PlanAdd>delegate;
@property (nonatomic, weak) IBOutlet UITextField *namePlan;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPlan:(Plan *)plan;
-(IBAction)add;
@end
