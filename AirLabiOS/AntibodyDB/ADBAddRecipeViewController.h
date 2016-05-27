//
//  ADBAddRecipeViewController.h
// AirLab
//
//  Created by Raul Catena on 5/10/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBAddPasoViewController.h"
#import "ADBComertialReagentPickerViewController.h"


@protocol AddRecipeDelegate;

@interface ADBAddRecipeViewController : ADBMasterViewController <AddPasoProtocol, ComReagentPicker>

@property (nonatomic,strong) Recipe *recipe;
@property (nonatomic, assign) id <AddRecipeDelegate> delegate;
@property (nonatomic, assign) BOOL isModeEdition;
@property (nonatomic, weak) IBOutlet UITextField *recipeName;
@property (nonatomic, weak) IBOutlet UITextView *recipePurpose;

@property (nonatomic, weak) IBOutlet UITableView *tableView3;


@property (nonatomic, weak) IBOutlet UIButton *addFile;
@property (nonatomic, weak) IBOutlet UILabel *addFilePlus;
@property (nonatomic, weak) IBOutlet UIButton *addReagent;
@property (nonatomic, weak) IBOutlet UILabel *addReagentPlus;
@property (nonatomic, weak) IBOutlet UIButton *addStep;


-(IBAction)newFile;
-(IBAction)newReagent:(UIButton *)sender;
-(IBAction)newStep;
-(IBAction)newStepInBetween;
-(IBAction)modifyStep;
-(IBAction)addElement:(id)sender;
-(IBAction)addTimer:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andRecipe:(Recipe *)recipe;

@end

@protocol AddRecipeDelegate <NSObject>
- (void)didAddRecipe:(Recipe *)recipe;
@end
