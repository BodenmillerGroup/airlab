//
//  ADBLoginViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/20/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBChooseGroupViewController.h"
#import "ADBAskGroupViewController.h"
#import "ADBAddGroupViewController.h"

@interface ADBLoginViewController : ADBMasterViewController <ChooseGroup, AddGroupDelegate>

@property (nonatomic, weak) IBOutlet UITextField *email;
@property (nonatomic, weak) IBOutlet UITextField *password;
@property (nonatomic, weak) IBOutlet UITextField *confirmPassword;
@property (nonatomic, weak) IBOutlet UIButton *buttonLogin;
@property (nonatomic, weak) IBOutlet UIButton *buttonChoose;
@property (nonatomic, weak) IBOutlet UIButton *brainEmail;
@property (nonatomic, weak) IBOutlet UIButton *brainPassword;

-(IBAction)changedAction:(UIButton *)sender;
-(IBAction)toogleBrain:(id)sender;

@end
