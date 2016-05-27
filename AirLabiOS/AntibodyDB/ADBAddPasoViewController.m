//
//  ADBAddPasoViewController.m
// AirLab
//
//  Created by Raul Catena on 5/12/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddPasoViewController.h"

@interface ADBAddPasoViewController ()

@property (nonatomic, assign) BOOL isModeEdition;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSMutableDictionary *stepDictionary;
@property (nonatomic, strong) Recipe *recipe;

@end

@implementation ADBAddPasoViewController

@synthesize recipeText = _recipeText;

@synthesize addedTimeLabel = _addedTimeLabel;
@synthesize addTimeButton = _addTimeButton;
@synthesize isModeEdition;
@synthesize actionLabel = _actionLabel;
@synthesize stepDictionary = _stepDictionary;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withStep:(NSDictionary *)stepDictionary andRecipe:(Recipe *)recipe
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.stepDictionary = stepDictionary.mutableCopy;
        self.recipe = recipe;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.preferredContentSize = self.view.bounds.size;
    if(_stepDictionary){

        self.addedTimeLabel.text = [General secondsToTime:[[_stepDictionary valueForKey:@"stpTime"]intValue]];
        self.recipeText.text = [_stepDictionary valueForKey:@"stpText"];
        isModeEdition = YES;
        self.actionLabel.text = nil;
    }else{
        self.stepDictionary = [NSMutableDictionary dictionaryWithCapacity:4];
    }
}

#pragma UITextViewDelegate

-(void)textViewDidChange:(UITextView *)textView{
    [General saveContextAndRoll];
}

-(IBAction)eraseInstructions{
    self.recipeText.text = nil;
}

-(void)prepareValues{
    [_stepDictionary setValue:_recipeText.text forKey:@"stpText"];
    if(!_time)_time = @"";
    [_stepDictionary setValue:_time forKey:@"stpTime"];
}

-(IBAction)addStep:(UIButton *)step{

    [self prepareValues];
    [self.delegate didAddPaso:_stepDictionary];
}

-(IBAction)modifiedStep:(Step *)step{
    [self prepareValues];
    [self.delegate didChangePaso:_stepDictionary];
}

-(IBAction)insert{
    [self prepareValues];
    [self.delegate insertChangePaso:_stepDictionary];
}

-(IBAction)addTimer:(int)time{
    ADBAddTimeViewController *timerVC = [[ADBAddTimeViewController alloc]initWithNibName:nil bundle:nil andTime:(int)[General secondsToTime:[[_stepDictionary valueForKey:@"stpTime"]intValue]]];
    timerVC.delegate = self;
    [self showModalOrPopoverWithViewController:timerVC withFrame:self.addTimeButton.frame];
}
-(IBAction)addReagent:(UIButton *)sender{
    
    ADBComertialReagentPickerViewController *reagent = [[ADBComertialReagentPickerViewController alloc]init];
    reagent.delegate = self;
    self.popover = [[UIPopoverController alloc]initWithContentViewController:reagent];
    [self.popover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)didPickComertialReagent:(ComertialReagent *)reagent{
    RecipeObject *linker = (RecipeObject *)[General newObjectOfType:RECIPEOBJECT_DB_CLASS saveContext:YES];
    linker.object = reagent;
    linker.recipe = _recipe;
    linker.rcmObjectType = NSStringFromClass([reagent class]);
    
    [General doLinkForProperty:@"object" inObject:linker withReceiverKey:@"rcmObjectId" fromDonor:reagent withPK:@"comComertialReagentId"];
    [General doLinkForProperty:@"recipe" inObject:linker withReceiverKey:@"rcmRecipeId" fromDonor:_recipe withPK:@"comComertialReagentId"];
    
    self.recipeText.text = [self.recipeText.text stringByAppendingString:[NSString stringWithFormat:@" %@", reagent.comName]];
    [self refreshTable];
    [self.tableView2 reloadData];
}

#pragma mark AddTimeDelegate

-(void)didAddTime:(int)time{
    _time = [NSString stringWithFormat:@"%i", time];
    self.addedTimeLabel.text = [General secondsToTime:time];
}

@end
