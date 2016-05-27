//
//  ADBRecetasViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/10/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBRecetasViewController.h"
#import "ADBPasoCellTableViewCell.h"
#import "ADBRunRecetaViewController.h"
#import "ADBUtilitiesViewController.h"

@interface ADBRecetasViewController ()

@end

@implementation ADBRecetasViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Protocols";
    
    if ([[ADBAccountManager sharedInstance]currentGroupPerson]) {
        
        [[IPFetchObjects getInstance]addRecetasFromServerWithBlock:^{
            [_fetchedResultsController performFetch:nil];
            [self.tableView reloadData];}];
        [[IPFetchObjects getInstance]addStepsFromServerWithBlock:^{[self.tableView reloadData];}];
    }
    [self setTheTableviewWithStyle:UITableViewStylePlain];
    
    UIButton *butt = [UIButton buttonWithType:UIButtonTypeCustom];
    [butt setImage:[UIImage imageNamed:@"swiss-knife.png"] forState:UIControlStateNormal];
    butt.frame = CGRectMake(0, 0, 40, 40);
    [butt addTarget:self action:@selector(utilities:) forControlEvents:UIControlEventTouchUpInside];
    [General iPhoneBlock:nil iPadBlock:^{
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:butt];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem)];
    }];
    
}

-(void)utilities:(UIButton *)sender{
    ADBUtilitiesViewController *utils = [[ADBUtilitiesViewController alloc]init];
    UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:utils];
    [self showModalOrPopoverWithViewController:navCon withFrame:sender.frame];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self refreshTable];
}


-(void)addItem{
    ADBAddRecipeViewController *add = [[ADBAddRecipeViewController alloc]initWithNibName:nil bundle:nil andRecipe:nil];
    add.delegate = self;
    [self showModalWithCancelButton:add fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:RECIPE_DB_CLASS];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"rcpRecipeId" ascending:YES]];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];//TODO add section name keypath with protein or epitope
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fetchedResultsController.fetchedObjects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"RecipeCell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    Recipe *recipe = [_fetchedResultsController objectAtIndexPath:indexPath];
    if (recipe.zetAnchor) {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = recipe.rcpTitle;
    [self setGrayColorInTableText:cell];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    Recipe *recipe = (Recipe *)[_fetchedResultsController objectAtIndexPath:indexPath];
    ADBRunRecetaViewController *view = [[ADBRunRecetaViewController alloc]initWithNibName:nil bundle:nil andRecipe:recipe];
    //view.delegate = self;
    [self showModalWithCancelButton:view fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}


#pragma mark AddRecipeProtocol

-(void)didAddRecipe:(Recipe *)recipe{
    [self dismissModalOrPopover];
    [self refreshTable];
    [General saveContextAndRoll];
    [[IPExporter getInstance]updateInfoForObject:recipe withBlock:nil];
}

@end
