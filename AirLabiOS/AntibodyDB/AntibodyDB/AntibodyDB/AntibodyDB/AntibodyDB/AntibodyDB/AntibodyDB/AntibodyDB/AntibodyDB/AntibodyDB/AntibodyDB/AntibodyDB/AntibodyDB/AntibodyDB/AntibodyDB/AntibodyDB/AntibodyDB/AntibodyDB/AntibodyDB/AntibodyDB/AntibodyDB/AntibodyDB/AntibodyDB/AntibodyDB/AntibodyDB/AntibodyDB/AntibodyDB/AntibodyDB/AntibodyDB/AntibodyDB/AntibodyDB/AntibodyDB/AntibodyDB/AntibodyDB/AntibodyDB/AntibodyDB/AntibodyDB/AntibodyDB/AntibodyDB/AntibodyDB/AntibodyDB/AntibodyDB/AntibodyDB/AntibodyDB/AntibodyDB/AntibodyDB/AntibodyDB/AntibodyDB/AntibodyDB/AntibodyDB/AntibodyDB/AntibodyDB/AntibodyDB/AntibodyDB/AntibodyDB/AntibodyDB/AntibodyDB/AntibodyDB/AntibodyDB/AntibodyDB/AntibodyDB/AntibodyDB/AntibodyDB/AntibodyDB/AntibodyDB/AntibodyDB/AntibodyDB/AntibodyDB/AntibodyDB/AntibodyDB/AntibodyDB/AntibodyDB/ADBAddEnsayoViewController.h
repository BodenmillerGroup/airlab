//
//  ADBAddEnsayoViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 6/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol EnsayoProtocol <NSObject>

-(void)didAddEnsayo:(Ensayo *)ensayo;

@end

@interface ADBAddEnsayoViewController : ADBMasterViewController

@property (nonatomic, assign) id<EnsayoProtocol>delegate;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *purpose;
@property (weak, nonatomic) IBOutlet UITextView *hypothesis;
@property (weak, nonatomic) IBOutlet UITextView *conclusions;
@property (weak, nonatomic) IBOutlet UILabel *conclusionsLabel;

@end
