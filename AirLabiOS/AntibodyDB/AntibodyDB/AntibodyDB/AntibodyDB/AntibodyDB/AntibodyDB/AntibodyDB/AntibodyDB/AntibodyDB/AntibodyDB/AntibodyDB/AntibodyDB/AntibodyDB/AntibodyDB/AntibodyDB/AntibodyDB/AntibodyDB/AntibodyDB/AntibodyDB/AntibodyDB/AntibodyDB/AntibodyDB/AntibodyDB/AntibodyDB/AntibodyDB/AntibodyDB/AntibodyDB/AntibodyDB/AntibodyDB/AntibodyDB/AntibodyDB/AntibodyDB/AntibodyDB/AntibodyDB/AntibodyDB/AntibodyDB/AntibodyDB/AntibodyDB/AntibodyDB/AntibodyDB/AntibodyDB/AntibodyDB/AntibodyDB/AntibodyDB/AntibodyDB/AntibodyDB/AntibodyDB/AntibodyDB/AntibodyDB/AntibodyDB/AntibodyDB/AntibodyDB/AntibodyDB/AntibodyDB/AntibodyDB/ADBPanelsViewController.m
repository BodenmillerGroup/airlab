//
//  ADBPanelsViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/7/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBPanelsViewController.h"
#import "ADBMetalPanelViewController.h"
#import "Panel.h"
#import "Tag.h"
#import "LabeledAntibody.h"

@interface ADBPanelsViewController ()

@end

@implementation ADBPanelsViewController

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
    self.title = @"Antibody Panels";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem)];
    [[IPFetchObjects getInstance]addPanelLabeledAntibodiesFromServerWithBlock:nil];
}

-(void)addItem{
    ADBAddPanelViewController *add = [[ADBAddPanelViewController alloc]init];
    add.delegate = self;
    [self showModalWithCancelButton:add fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
}

-(void)cancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didAddPanel:(Panel *)panel{
    [self refreshTable];
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:PANEL_DB_CLASS];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"panPanelId" ascending:YES]];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];//TODO add section name keypath with protein or epitope
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fetchedResultsController.fetchedObjects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"PanelCell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    Panel *panel = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = panel.panName;
    [self setGrayColorInTableText:cell];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Panel *panel = [_fetchedResultsController objectAtIndexPath:indexPath];
    if ([[[(ZPanelLabeledAntibody *)panel.panelLabeledAntibodies.anyObject labeledAntibody]  tag]tagIsMetal].intValue == 1) {
        if (self.navigationController.splitViewController || [[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            ADBMetalPanelViewController *panelVC = [[ADBMetalPanelViewController alloc]initWithNibName:nil bundle:nil andPanel:panel];
            
            //UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:panelVC];
            
            //panelVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancel)];
            [self showModalWithCancelButton:panelVC fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
        }else{
            [self.delegate didSelectPanel:panel];
        }
        
    }else{
        
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Delete";//[[LanguageController getInstance]getIdiomForKey:DELETE_ROW];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    Panel *panel = [_fetchedResultsController objectAtIndexPath:indexPath];
    if (panel.createdBy.intValue == [[ADBAccountManager sharedInstance]currentGroupPerson].gpeGroupPersonId.intValue) {
        return YES;
    }
    return NO;
    //Override when yes
}

//Override if necesary
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.managedObjectContext deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
         
         // Save the context.
         NSError *error;
         if (![self.managedObjectContext save:&error]) {
         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
         }
        //[self.tableView reloadData];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [super filterContentForSearchText:searchText scope:scope];
    if (!self.previousPredicate) {
        self.previousPredicate = self.fetchedResultsController.fetchRequest.predicate;
    }
    
    if (searchText != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"panName contains [cd] %@", searchText];
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
        [NSFetchedResultsController deleteCacheWithName:@"allCache"];
        
    }else {
        [self.fetchedResultsController.fetchRequest setPredicate:self.previousPredicate];
        [NSFetchedResultsController deleteCacheWithName:@"allCache"];
    }
    [self refreshTable];
    NSLog(@"results: %lu", (unsigned long)[[self.fetchedResultsController fetchedObjects]count]);
    self.searchDisplayController.searchBar.showsCancelButton = YES;
}


@end
