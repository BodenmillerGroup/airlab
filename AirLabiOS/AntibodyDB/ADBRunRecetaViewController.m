//
//  ADBRunRecetaViewController.m
// AirLab
//
//  Created by Raul Catena on 6/14/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBRunRecetaViewController.h"
#import "ADBTimersSingleton.h"

@interface ADBRunRecetaViewController ()

@property (nonatomic, strong) Recipe *recipe;
@property (nonatomic, strong) NSArray *steps;

@end

@implementation ADBRunRecetaViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andRecipe:(Recipe *)aRecipe
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.recipe = aRecipe;
        self.noAutorefresh = YES;
    }
    return self;
}

-(void)populate{
    if (_recipe.catchedInfo){// && [[NSJSONSerialization JSONObjectWithData:[_recipe.catchedInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil]isKindOfClass:[NSMutableArray class]]) {
        NSError *error;
        NSArray *array = [NSJSONSerialization JSONObjectWithData:[_recipe.catchedInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
        [General logError:error];
        NSArray *theSortedStrings = [array sortedArrayUsingComparator:^(NSDictionary * obj1, NSDictionary * obj2) {
            return [(NSString *)[obj1 valueForKey:@"stpPosition"] compare:(NSString *)[obj2 valueForKey:@"stpPosition"] options:NSNumericSearch];
        }];
        
        //NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"stpPosition" ascending:YES];
        NSArray *sorted = theSortedStrings;//[self.recipe.steps sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
        self.steps = [NSMutableArray arrayWithArray:sorted];
        self.purpose.text = self.recipe.rcpPurpose;
    }else{
        self.steps = [NSMutableArray array];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.titleOfRecipe.text = _recipe.rcpTitle;
    self.purpose.text = _recipe.rcpPurpose;
    
    [self populate];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *array = [[NSUserDefaults standardUserDefaults]valueForKey:@"CurrentProtocols"];
    for (NSNumber *number in array) {
        if (number.intValue == _recipe.rcpRecipeId.intValue) {
            
        }
    }
    NSMutableArray *arrayButtons = [NSMutableArray arrayWithObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reset)]];
    [General iPhoneBlock:nil iPadBlock:^{
        [arrayButtons addObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)]];
        [arrayButtons addObject:[[UIBarButtonItem alloc]initWithTitle:@"Duplicate" style:UIBarButtonItemStyleDone target:self action:@selector(duplicate)]];
    }];
    self.navigationItem.rightBarButtonItems = arrayButtons;
    
}

-(void)duplicate{
    Recipe *receta = (Recipe *)[IPCloner clone:_recipe inContext:self.managedObjectContext];
    receta.rcpTitle = [NSString stringWithFormat:@"Duplicated %@", _recipe.rcpTitle];
    [General showOKAlertWithTitle:@"Recipe duplicated successfully" andMessage:nil delegate:self];
}

-(void)reset{
    self.recipe.zetAnchor = nil;
    self.recipe.zetSecondsLeft = nil;
    [General saveContextAndRoll];
    [self.tableView reloadData];
    
    [[ADBTimersSingleton sharedInstance]removeTimeForTask:[NSString stringWithFormat:@"Recipe%@", _recipe.rcpRecipeId]];
}

-(void)edit{
    ADBAddRecipeViewController *edit = [[ADBAddRecipeViewController alloc]initWithNibName:nil bundle:nil andRecipe:_recipe];
    edit.delegate = self;
    [self.navigationController pushViewController:edit animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _steps.count + 2;
}

-(CGFloat)widthOfVC{
    return self.view.bounds.size.width;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"RecipeCell";
    
    ADBPasoCellTableViewCell * cellSp = (ADBPasoCellTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cellSp) {
        NSArray *topElements = [[NSBundle mainBundle]loadNibNamed:@"ADBPasoCellTableViewCell" owner:self options:nil];
        cellSp = [topElements objectAtIndex:0];
    }
    cellSp.delegate = self;
    for(UIView *aView in cellSp.subviews){
        if(aView.tag == 1)[aView removeFromSuperview];
    }
    
    [self setGrayColorInTableText:cellSp];
    if(indexPath.row == 0){
        cellSp.textLabel.text = _recipe.rcpTitle;
        return cellSp;
    }

    if(indexPath.row == 1){
        cellSp.textLabel.text = nil;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, self.view.frame.size.width - 20, [General calculateHeightedLabelForLabelWithText:_recipe.rcpPurpose andWidth:self.view.frame.size.width andFontSize:17])];
        label.tag = 1;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        label.text = _recipe.rcpPurpose;
        label.textColor = [UIColor darkGrayColor];
        [cellSp addSubview:label];
        return cellSp;
    }
    
    NSDictionary *step = [_steps objectAtIndex:indexPath.row-2];
    cellSp.tag = indexPath.row;
    cellSp.recipe = self.recipe;
    cellSp.paso = step;
    
    if (_recipe.zetAnchor && indexPath.row <= self.recipe.zetAnchor.intValue) {
        cellSp.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cellSp.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cellSp;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        return 70;
    }
    if(indexPath.row == 1){
        return MAX([General calculateHeightedLabelForLabelWithText:_recipe.rcpPurpose andWidth:self.view.bounds.size.width - 64 andFontSize:17] + 68, 80);;
    }
    NSDictionary *step = [self.steps objectAtIndex:indexPath.row-2];
    return MAX([General calculateHeightedLabelForLabelWithText:[step valueForKey:@"stpText"] andWidth:self.view.bounds.size.width - 64 andFontSize:17] + 68, 80);
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row<2)return;
	NSInteger currentIndex = indexPath.row-2;
    
	if (currentIndex == 0) {
		NSIndexPath *theOtherIndexPath = [NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:indexPath.section];
		ADBPasoCellTableViewCell *nextCell = (ADBPasoCellTableViewCell *)[self.tableView cellForRowAtIndexPath:theOtherIndexPath];
		ADBPasoCellTableViewCell *cell = (ADBPasoCellTableViewCell *)[aTableView cellForRowAtIndexPath:indexPath];
		if (cell.accessoryType == UITableViewCellAccessoryNone) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
            if ([[cell.paso valueForKey:@"stpTime"]intValue]>0) {
                [cell resumeTimer:nil];
                cell.inprocess = YES;
            }
		}else if (cell.accessoryType == UITableViewCellAccessoryCheckmark && nextCell.accessoryType == UITableViewCellAccessoryNone) {
			cell.accessoryType = UITableViewCellAccessoryNone;
            [cell finish:nil];
            cell.inprocess = NO;
		}
		[aTableView deselectRowAtIndexPath:indexPath animated:YES];//
	}else {
		NSIndexPath *thePrevIndexPath = [NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:indexPath.section];
		NSIndexPath *thePostIndexPath = [NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:indexPath.section];
		ADBPasoCellTableViewCell *cell = (ADBPasoCellTableViewCell *)[aTableView cellForRowAtIndexPath:indexPath];
		ADBPasoCellTableViewCell *previousCell = (ADBPasoCellTableViewCell *)[aTableView cellForRowAtIndexPath:thePrevIndexPath];
		UITableViewCell *nextCell = [aTableView cellForRowAtIndexPath:thePostIndexPath];
		if (previousCell.accessoryType == UITableViewCellAccessoryCheckmark && cell.accessoryType == UITableViewCellAccessoryNone && !previousCell.inprocess) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
            if (cell.cuenta>0) {
                [cell resumeTimer:nil];
                cell.inprocess = YES;
            }
            self.recipe.zetAnchor = [NSNumber numberWithInt:currentIndex];
            [General saveContextAndRoll];
		}else if (previousCell.accessoryType == UITableViewCellAccessoryCheckmark && cell.accessoryType == UITableViewCellAccessoryCheckmark && nextCell.accessoryType == UITableViewCellAccessoryNone) {
			//if(nextCell.accessoryType == UITableViewCellAccessoryNone){
			cell.accessoryType = UITableViewCellAccessoryNone;
            [cell finish:nil];
            cell.inprocess = NO;
			//}
		}
		[aTableView deselectRowAtIndexPath:indexPath animated:YES];//
	}
}

-(void)didAddRecipe:(Recipe *)recipe{
    [[IPExporter getInstance]updateInfoForObject:recipe withBlock:nil];
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    ADBPasoCellTableViewCell *previousCell = (ADBPasoCellTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_recipe.zetAnchor.integerValue inSection:0]];
    _recipe.zetSecondsLeft = [NSNumber numberWithInt:previousCell.cuenta];
    [General saveContextAndRoll];
}


@end
