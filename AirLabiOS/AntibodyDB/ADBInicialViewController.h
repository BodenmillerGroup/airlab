//
//  ADBInicialViewController.h
// AirLab
//
//  Created by Raul Catena on 5/21/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBAdminGroupViewController.h"
#import "ADBAddGroupViewController.h"
#import "ADBAddCommentViewController.h"

@interface ADBInicialViewController : ADBMasterViewController <AddGroupDelegate, AddToWall>

@property (nonatomic, weak) IBOutlet UILabel *nombre;
@property (nonatomic, weak) IBOutlet UILabel *lab;
@property (weak, nonatomic) IBOutlet UIImageView *phdComics;
@property (weak, nonatomic) IBOutlet UISegmentedControl *updateType;
@property (weak, nonatomic) IBOutlet UIButton *groupAdminButton;

@property (nonatomic, strong) NSArray *finishedAbs;
@property (nonatomic, strong) NSArray *orders;
@property (nonatomic, strong) NSArray *low;
@property (nonatomic, strong) NSArray *lastArrived;
@property (nonatomic, strong) NSArray *comments;

-(IBAction)facebook:(id)sender;
-(IBAction)twitter:(id)sender;
-(IBAction)instagram:(id)sender;
- (IBAction)adminGroup:(id)sender;
-(IBAction)changedType:(UISegmentedControl *)sender;

-(IBAction)addComment:(UIButton *)sender;

@end
