//
//  ADBKeyBoardViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 7/8/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol KeyboardProtocol <NSObject>

-(void)sendNumber:(NSString *)number;

@end

@interface ADBKeyBoardViewController : ADBMasterViewController

@property (nonatomic, assign) id<KeyboardProtocol>zdelegate;
@property (nonatomic, weak) IBOutlet UILabel *currentValueLabel;

-(IBAction)keyPressed:(UIButton *)sender;
-(IBAction)ok:(id)sender;

@end
