//
//  ADBAddPasoViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/12/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBAddTimeViewController.h"
#import "ADBComertialReagentPickerViewController.h"

@protocol AddPasoProtocol <NSObject>

-(void)didAddPaso:(NSDictionary *)paso;
-(void)didChangePaso:(NSDictionary *)paso;
-(void)insertChangePaso:(NSDictionary *)paso;

@end

@interface ADBAddPasoViewController : ADBMasterViewController<UITextViewDelegate, AddTimeDelegate, ComReagentPicker>

@property (nonatomic, weak) IBOutlet UITextView *recipeText;
@property (nonatomic, weak) IBOutlet UIButton *editBut;
@property (nonatomic, weak) IBOutlet UIButton *addAntes;
@property (nonatomic, weak) IBOutlet UIButton *addTimeButton;
@property (nonatomic, assign) int timeToAddToStep;
@property (nonatomic, weak) IBOutlet UILabel *addedTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *actionLabel;

@property (nonatomic, weak) id<AddPasoProtocol>delegate;


-(IBAction)eraseInstructions;
-(IBAction)addStep:(UIButton *)sender;
-(IBAction)addTimer:(int)time;
-(IBAction)addReagent:(UIButton *)sender;
-(IBAction)modifiedStep:(Step *)step;
-(IBAction)insert;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withStep:(NSDictionary *)stepDictionary andRecipe:(Recipe *)recipe;

@end
