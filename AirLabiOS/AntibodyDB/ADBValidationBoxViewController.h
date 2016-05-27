//
//  ADBValidationBoxViewController.h
// AirLab
//
//  Created by Raul Catena on 8/13/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBSelectFileViewController.h"


@protocol ValidationNote <NSObject>

-(void)didAddValidationNote:(NSDictionary *)jsonDic;
-(void)didModifyValidationNote:(NSDictionary *)jsonDic;

@end

@interface ADBValidationBoxViewController : ADBMasterViewController <AddFileToPart>
@property (weak, nonatomic) IBOutlet UISegmentedControl *application;
@property (weak, nonatomic) IBOutlet UISegmentedControl *valoration;
@property (weak, nonatomic) IBOutlet UISegmentedControl *surface;
@property (weak, nonatomic) IBOutlet UISegmentedControl *saponin;
@property (weak, nonatomic) IBOutlet UISegmentedControl *metoh;
@property (weak, nonatomic) IBOutlet UIButton *fileArea;
@property (weak, nonatomic) IBOutlet UITextField *cellLine;
@property (weak, nonatomic) IBOutlet UITextField *negCellLine;
@property (weak, nonatomic) IBOutlet UITextView *notes;
@property (weak, nonatomic) IBOutlet UISwitch *validation;
@property (weak, nonatomic) IBOutlet UIButton *addFile;
@property (nonatomic, weak) id<ValidationNote>delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andJson:(NSDictionary *)json;
-(IBAction)addFile:(id)sender;

@end
