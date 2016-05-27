//
//  ADBValidationBoxViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 8/13/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol ValidationNote <NSObject>

-(void)didAddValidationNote:(NSDictionary *)jsonDic;
-(void)didModifyValidationNote:(NSDictionary *)jsonDic;

@end

@interface ADBValidationBoxViewController : ADBMasterViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *application;
@property (weak, nonatomic) IBOutlet UISegmentedControl *valoration;
@property (weak, nonatomic) IBOutlet UITextField *cellLine;
@property (weak, nonatomic) IBOutlet UITextView *notes;
@property (weak, nonatomic) IBOutlet UISwitch *validation;
@property (nonatomic, weak) id<ValidationNote>delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andJson:(NSDictionary *)json;

@end
