//
//  ADBAddRecipeViewController.m
// AirLab
//
//  Created by Raul Catena on 5/10/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddRecipeViewController.h"
#import "ADBPasoCellTableViewCell.h"

@interface ADBAddRecipeViewController (){
    int selectedStep;
}

@property (nonatomic, strong) NSMutableArray *steps;

@end

@implementation ADBAddRecipeViewController

@synthesize recipe = _recipe;
@synthesize recipePurpose = _recipePurpose;
@synthesize tableView3 = _tableView3;
@synthesize delegate;
@synthesize isModeEdition;
@synthesize recipeName = _recipeName;
@synthesize addFile = _addFile;
@synthesize addFilePlus = _addFilePlus;
@synthesize addReagent = _addReagent;
@synthesize addReagentPlus = _addReagentPlus;
@synthesize addStep= _addStep;
@synthesize steps = _steps;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andRecipe:(Recipe *)recipe
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (!recipe) {
            isModeEdition = NO;
        }else{
            self.recipe = recipe;
            isModeEdition = YES;
        }
        selectedStep = -1;
    }
    return self;
}

-(void)populate{
    self.tableView3.tag = -1;
    self.recipeName.text = self.recipe.rcpTitle;
    self.title = self.recipeName.text;
    
    if (_recipe.catchedInfo && [[NSJSONSerialization JSONObjectWithData:[_recipe.catchedInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil]isKindOfClass:[NSMutableArray class]]) {
        NSArray *array = [NSJSONSerialization JSONObjectWithData:[_recipe.catchedInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        
        NSArray *theSortedStrings = [array sortedArrayUsingComparator:^(NSDictionary * obj1, NSDictionary * obj2) {
            return [(NSString *)[obj1 valueForKey:@"stpPosition"] compare:(NSString *)[obj2 valueForKey:@"stpPosition"] options:NSNumericSearch];
        }];
        
        //NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"stpPosition" ascending:YES];
        NSArray *sorted = theSortedStrings;//[self.recipe.steps sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
        self.steps = [NSMutableArray arrayWithArray:sorted];
        self.recipePurpose.text = self.recipe.rcpPurpose;
    }else{
        self.steps = [NSMutableArray array];
    }
    
}

-(void)archive{
    NSError *error;
    _recipe.catchedInfo = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:_steps options:NSJSONWritingPrettyPrinted error:&error] encoding:NSUTF8StringEncoding];
    if (error)[General logError:error];
    [General saveContextAndRoll];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    
    [self populate];
    [General addBorderToButton:_addStep withColor:_addStep.titleLabel.textColor];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark textfielddelegate

-(void)textFieldDidEndEditing:(UITextField *)textField{
    self.title = textField.text;
}

-(void)done{
    if (!_recipe) {
        self.recipe = (Recipe *)[General newObjectOfType:RECIPE_DB_CLASS saveContext:NO];
    }
    self.recipe.rcpTitle = self.recipeName.text;
    self.recipe.rcpPurpose = self.recipePurpose.text;
    
    [self archive];
    [self.delegate didAddRecipe:self.recipe];
}

-(IBAction)newFile{
    
}

-(IBAction)newReagent:(UIButton *)sender{
    ADBComertialReagentPickerViewController *reagent = [[ADBComertialReagentPickerViewController alloc]init];
    reagent.delegate = self;
    self.popover = [[UIPopoverController alloc]initWithContentViewController:reagent];
    [self.popover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)didPickComertialReagent:(ComertialReagent *)reagent{
    if (!_recipe) {
        self.recipe = (Recipe *)[General newObjectOfType:RECIPE_DB_CLASS saveContext:YES];
        _recipe.rcpTitle = self.recipeName.text;
        _recipe.rcpPurpose = self.recipePurpose.text;
    }
    RecipeObject *linker = (RecipeObject *)[General newObjectOfType:RECIPEOBJECT_DB_CLASS saveContext:YES];
    linker.object = reagent;
    linker.recipe = _recipe;
    linker.rcmObjectType = NSStringFromClass([reagent class]);
    //[General doLinkForProperty:@"object" inObject:linker withReceiverKey:@"rcmObjectId" fromDonor:reagent withPK:@"comComertialReagentId"];
    [General doLinkForProperty:@"recipe" inObject:linker withReceiverKey:@"rcmRecipeId" fromDonor:_recipe withPK:@"rcpRecipeId"];
    
    [self refreshTable];
    [self.tableView2 reloadData];
}

-(IBAction)newStep{
    NSDictionary *dict = nil;
    if (selectedStep > -1) {
        dict = [_steps objectAtIndex:selectedStep];
    }
    ADBAddPasoViewController *addPaso = [[ADBAddPasoViewController alloc]initWithNibName:nil bundle:nil withStep:dict andRecipe:_recipe];
    addPaso.delegate = self;
    [self showModalOrPopoverWithViewController:addPaso withFrame:self.addStep.frame];
}

-(IBAction)newStepInBetween{
    
}
-(IBAction)modifyStep{
    
}

-(IBAction)addElement:(id)sender{
    
}
-(IBAction)addTimer:(id)sender{
    
}

#pragma mark UITableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int count = 0;
    if (tableView == self.tableView || tableView == self.tableView2) {
        /*int a = 0;
        int b = 0;
        for (Object *object in self.recipe.objects) {
            if ([object isMemberOfClass:[File class]]) {
                a++;
            }
            if ([object isMemberOfClass:[ComertialReagent class]]) {
                b++;
            }
        }*/
        if (tableView == self.tableView) {
            //count = a;
            count = (int)_recipe.recipeObjects.allObjects.count;
        }
        if (tableView == self.tableView2) {
            //count = b;
        }
    }else if(tableView == self.tableView3){
        count = (int)self.steps.count;
    }
    return count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"RecipeCell";
    static NSString *cellId2 = @"RecipeCell2";
    
    UITableViewCell *cell;
    
    if (tableView == self.tableView) {
        
        cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        }
        
        RecipeObject *com = (RecipeObject *)[self.recipe.recipeObjects.allObjects objectAtIndex:indexPath.row];
        if (!com.object)
            cell.textLabel.text = @"Something";
        else
            cell.textLabel.text = [(ComertialReagent *)com.object comName];
    }
    
    if (tableView == self.tableView3) {
        
        ADBPasoCellTableViewCell * cellSp = (ADBPasoCellTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId2];
        if (!cellSp) {
            NSArray *topElements = [[NSBundle mainBundle]loadNibNamed:@"ADBPasoCellTableViewCell" owner:self options:nil];
            cellSp = [topElements objectAtIndex:0];
        }
        NSDictionary *step = [self.steps objectAtIndex:indexPath.row];
        cellSp.paso = step;
        cell = cellSp;
    }
    
    [self setGrayColorInTableText:cell];
    return cell;
}

-(void)setButtonToNew{
    [self.addStep setTitle:@"+ step" forState:UIControlStateNormal];
    selectedStep = -1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.tableView3){
        if (selectedStep == indexPath.row) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self setButtonToNew];
        }else{
            selectedStep = indexPath.row;
            [self.addStep setTitle:@"Modify step" forState:UIControlStateNormal];
        }
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.tableView3){
        [self setButtonToNew];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)reorderSubroutine{
    int x = 1;
    NSMutableArray *new = [NSMutableArray arrayWithCapacity:_steps.count];
    for (NSDictionary *anStep in _steps) {
        NSMutableDictionary *mut = anStep.mutableCopy;
        [mut setValue:[NSString stringWithFormat:@"%i", x] forKey:@"stpPosition"];
        [new addObject:[NSDictionary dictionaryWithDictionary:mut]];
        x++;
    }
    self.steps = new;
    [self refreshSubroutine];
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Delete?"
                                              message:@"Are you sure? This action can not be undone"
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *deleteActionInAlert = [UIAlertAction
                                      actionWithTitle:@"Delete?"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action)
                                      {
                                          [_steps removeObjectAtIndex:indexPath.row];
                                          [self reorderSubroutine];
                                      }];
        [alertController addAction:deleteActionInAlert];
        [self presentViewController:alertController animated:YES completion:nil];

    }];
    
    return @[deleteAction];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableView3) {
        NSDictionary *step = [self.steps objectAtIndex:indexPath.row];
        return [General calculateHeightedLabelForLabelWithText:[step valueForKey:@"stpText"] andWidth:self.view.bounds.size.width - 20 andFontSize:14] + 50;
    }
    return 50;
}

#pragma mark AddPasoProtocol

-(void)refreshSubroutine{
    [self dismissModalOrPopover];
    [self.tableView3 reloadData];
    [General saveContextAndRoll];
}

-(void)didAddPaso:(NSMutableDictionary *)paso{
    [paso setValue:[NSString stringWithFormat:@"%i", _steps.count + 1] forKey:@"stpPosition"];
    [paso setValue:[[paso valueForKey:@"stpText"]stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n" ] forKey:@"stpText"];
    [self.steps addObject:paso];
    [self reorderSubroutine];
}

-(void)didChangePaso:(NSMutableDictionary *)paso{
    int index = [[paso valueForKey:@"stpPosition"]intValue] - 1;
    [paso setValue:[[paso valueForKey:@"stpText"]stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n" ] forKey:@"stpText"];
    [_steps removeObjectAtIndex:index];
    [_steps addObject:paso];
    [self reorderSubroutine];
}

-(void)insertChangePaso:(NSDictionary *)paso{
    [paso setValue:[[paso valueForKey:@"stpText"]stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n" ] forKey:@"stpText"];
    [_steps insertObject:paso atIndex:selectedStep];
    [self reorderSubroutine];
    [self reorderSubroutine];
}

@end