//
//  ADBAddTargetViewController.h
// AirLab
//
//  Created by Raul Catena on 5/22/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol AddTargetProtocol <NSObject>

-(void)didAddTarget:(Protein *)protein;

@end

@interface ADBAddTargetViewController : ADBMasterViewController

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *protDescription;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (nonatomic, assign) id<AddTargetProtocol>delegate;
- (IBAction)create:(UIButton *)sender;

@end
