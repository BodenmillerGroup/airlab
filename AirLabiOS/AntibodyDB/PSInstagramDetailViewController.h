//
//  PSInstagramDetailViewController.h
//  ERA-EDTA2013
//
//  Created by Raul Catena on 10/8/13.
//  Copyright (c) 2013 Raul Catena. All rights reserved.
//

#import "ADBMasterViewController.h"

@interface PSInstagramDetailViewController : ADBMasterViewController<UIAlertViewDelegate>

@property (nonatomic, retain) IBOutlet UIButton *imageViewButton;
@property (nonatomic, retain) NSDictionary *dataDictionary;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) IBOutlet UILabel *likes;
@property (nonatomic, retain) IBOutlet UIButton *likeButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil image:(UIImage *)image andDataDictionary:(NSDictionary *)dataDict;
-(IBAction)savePicture:(id)sender;
-(IBAction)addComment:(id)sender;
-(IBAction)likePicture:(UIButton *)sender;

@end
