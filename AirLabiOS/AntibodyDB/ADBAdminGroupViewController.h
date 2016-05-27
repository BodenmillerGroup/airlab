//
//  ADBAdminGroupViewController.h
// AirLab
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import <MapKit/MapKit.h>

@interface ADBAdminGroupViewController : ADBMasterViewController

@property (nonatomic, weak) IBOutlet UITextField *invitee;
@property (weak, nonatomic) IBOutlet UITextField *groupName;
@property (weak, nonatomic) IBOutlet UITextField *institution;
@property (weak, nonatomic) IBOutlet UITextField *url;
@property (weak, nonatomic) IBOutlet UILabel *selectedName;
@property (weak, nonatomic) IBOutlet UILabel *selectedLastName;
@property (weak, nonatomic) IBOutlet UILabel *selectedEmail;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectedRole;
@property (weak, nonatomic) IBOutlet UISwitch *selectedCanPlaceOrders;
@property (weak, nonatomic) IBOutlet UISwitch *selectedCanEraseRecords;
@property (weak, nonatomic) IBOutlet UISwitch *selectedCanSeeFinances;
@property (weak, nonatomic) IBOutlet UISwitch *selectedCanSeeAllPanels;
@property (weak, nonatomic) IBOutlet UISwitch *activeInGroup;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *saveInfoGroupButton;
@property (weak, nonatomic) IBOutlet UISwitch *acceptRequests;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

-(IBAction)invite:(id)sender;
-(IBAction)anyChanged:(id)sender;
-(IBAction)saved:(id)sender;
-(IBAction)savedInfoGroup:(id)sender;

@end
