//
//  PSInstagramPhotoTaken.h
//  ERA-EDTA2013
//
//  Created by Raul Catena on 10/10/13.
//  Copyright (c) 2013 Raul Catena. All rights reserved.
//

#import "ADBMasterViewController.h"

@interface PSInstagramPhotoTaken : ADBMasterViewController

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UISwitch *saveToCameraRoll;
@property (nonatomic, retain) IBOutlet UISwitch *uploadToInstagram;
@property (nonatomic, retain) IBOutlet UISwitch *emailAFriend;

@property (nonatomic, retain) IBOutlet UILabel *saveToCameraRollLabel;
@property (nonatomic, retain) IBOutlet UILabel *uploadToInstagramLabel;
@property (nonatomic, retain) IBOutlet UILabel *emailAFriendLabel;

@property (nonatomic, retain) IBOutlet UIButton *doneButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andImage:(UIImage *)image;
- (IBAction)doneButton:(id)sender;

@end
