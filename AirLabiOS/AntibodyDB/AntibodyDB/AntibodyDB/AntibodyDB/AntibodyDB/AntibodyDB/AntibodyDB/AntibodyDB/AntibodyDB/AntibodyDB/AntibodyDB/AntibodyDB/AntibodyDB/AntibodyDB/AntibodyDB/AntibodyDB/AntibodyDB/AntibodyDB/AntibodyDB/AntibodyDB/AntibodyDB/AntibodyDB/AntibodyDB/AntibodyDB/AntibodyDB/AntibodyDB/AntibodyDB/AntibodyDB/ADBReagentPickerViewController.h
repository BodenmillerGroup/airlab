//
//  ADBReagentPickerViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/20/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol TubePicker <NSObject>

-(void)didPickTube:(id)tube withTag:(int)tag;

@end

@interface ADBReagentPickerViewController : ADBMasterViewController

@property (nonatomic, assign) id<TubePicker>delegate;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tubeTypeSelector;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTag:(int)tag;
- (IBAction)typeChanged:(UISegmentedControl *)sender;

@end
