//
//  ADBLoginViewController.h
// AirLab
//
//  Created by Raul Catena on 5/20/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBChooseGroupViewController.h"
#import "ADBAskGroupViewController.h"
#import "ADBAddGroupViewController.h"
#import "ADBSelectMemorizedViewController.h"

@interface ADBLoginViewController : ADBMasterViewController <ChooseGroup, AddGroupDelegate, MemorizedLogin>

@property (nonatomic, weak) IBOutlet UITextField *email;
@property (nonatomic, weak) IBOutlet UITextField *password;
@property (nonatomic, weak) IBOutlet UITextField *confirmPassword;
@property (nonatomic, weak) IBOutlet UIButton *buttonLogin;
@property (nonatomic, weak) IBOutlet UIButton *forgotBut;
@property (nonatomic, weak) IBOutlet UIButton *buttonChoose;
@property (nonatomic, weak) IBOutlet UIButton *brainEmail;
@property (nonatomic, weak) IBOutlet UIButton *brainPassword;
@property (nonatomic, weak) IBOutlet UIButton *play;

-(IBAction)changedAction:(UIButton *)sender;
-(IBAction)toogleBrain:(id)sender;
-(IBAction)memorized:(id)sender;
-(IBAction)forgot;

@end
