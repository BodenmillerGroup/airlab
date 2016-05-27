//
//  ADBInicialViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/21/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBAdminGroupViewController.h"
#import "ADBAddGroupViewController.h"

@interface ADBInicialViewController : ADBMasterViewController <AddGroupDelegate>

@property (nonatomic, weak) IBOutlet UILabel *nombre;
@property (nonatomic, weak) IBOutlet UILabel *lab;
@property (weak, nonatomic) IBOutlet UIImageView *phdComics;
@property (weak, nonatomic) IBOutlet UISegmentedControl *updateType;
@property (weak, nonatomic) IBOutlet UIButton *groupAdminButton;

-(IBAction)facebook:(id)sender;
-(IBAction)twitter:(id)sender;
-(IBAction)instagram:(id)sender;
- (IBAction)adminGroup:(id)sender;
-(IBAction)changedType:(id)sender;

@end
