//
//  ADBRecetasViewController.m
// AirLab
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
    if ([[ADBAccountManager sharedInstance]currentGroupPerson]) {
        
        [[IPFetchObjects getInstance]addRecetasFromServerWithBlock:^{
            [_fetchedResultsController performFetch:nil];
            [self.tableView reloadData];}];
    }
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

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Are you sure"
                                      message:@"This action is irreversible"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 Recipe *recipe = [_fetchedResultsController objectAtIndexPath:indexPath];
                                 [[IPExporter getInstance]deleteObject:recipe withBlock:nil];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
    return [NSArray arrayWithObject:deleteAction];
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
    cell.detailTextLabel.text = recipe.rcpPurpose;
    cell.tintColor = [UIColor orangeColor];
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
