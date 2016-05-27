//
//  ADBPanelsViewController.m
// AirLab
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

@property (nonatomic, retain) NSArray *allConjugates;

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
    self.title = @"Metal Antibody Panels";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem)];
    [self reorderedPanels];
}

//-(void)viewDidAppear:(BOOL)animated{
//    NSArray *array = [General searchDataBaseForClass:PANEL_DB_CLASS sortBy:@"panPanelId" ascending:YES inMOC:self.managedObjectContext];
//    for (Panel *pan in array) {
//        if ([pan.panDetails containsString:@"\r"] || [pan.panDetails containsString:@"\n"]) {
//            pan.panDetails = [General jsonObjectToString:[General jsonStringToObject:pan.panDetails]];
//        }
//        [[IPExporter getInstance]updateInfoForObject:pan withBlock:nil];
//    }
//}

-(void)addItem{
    ADBMetalsViewController *add = [[ADBMetalsViewController alloc]init];
    add.delegate = self;
    [self showModalWithCancelButton:add fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
}

-(void)cancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didAddPanel:(Panel *)panel{
    [panel isOwn];
    [self refreshTable];
}

-(void)reorderedPanels{
    for (Panel *pan in _fetchedResultsController.fetchedObjects) {
        [pan isOwn];
    }
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:PANEL_DB_CLASS];
        request.sortDescriptors = [NSArray arrayWithObjects:
                                   [NSSortDescriptor sortDescriptorWithKey:@"zetIsOwn" ascending:NO],
                                   [NSSortDescriptor sortDescriptorWithKey:@"panPanelId" ascending:NO selector:@selector(localizedStandardCompare:)],
        nil];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"zetIsOwn" cacheName:nil];
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _fetchedResultsController.sections.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int rows = 0;
    
    if ([[self.fetchedResultsController sections] count] > 0) {
        if ([[self.fetchedResultsController sections] count] == 1) {
            rows = (int)self.fetchedResultsController.fetchedObjects.count;
        }else{
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
            rows = (int)[sectionInfo numberOfObjects];
        }
        
    }
    return rows;
}

-(float)panelQuality:(Panel *)panel{
    float sum = 0.0f;
    NSArray *linkers = [General jsonStringToObject:panel.panDetails];
    if (!_allConjugates) {
        _allConjugates = [General searchDataBaseForClass:@"LabeledAntibody" sortBy:@"labLabeledAntibodyId" ascending:YES inMOC:self.managedObjectContext];
    }
    for (NSDictionary *link in linkers) {
        for (LabeledAntibody *lab in _allConjugates) {
            if ([[link valueForKey:@"plaLabeledAntibodyId"]intValue] == lab.labLabeledAntibodyId.intValue) {
                if (lab.tubFinishedBy.intValue == 0) {
                    sum += 1.0f;
                    break;
                }else if(lab.tubIsLow.intValue){
                    sum += 0.5f;
                    break;
                }else{
                
                }
            }
        }
    }
    return sum/(float)linkers.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"PanelCell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    for (UIView *aV in cell.contentView.subviews) {
        if ([aV isMemberOfClass:[UIProgressView class]]) {
            [aV removeFromSuperview];
        }
    }
    Panel *panel = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = panel.panName;
    cell.detailTextLabel.text = panel.groupPerson.person.perName;
    [self setGrayColorInTableText:cell];
    
    UIProgressView *progress = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
    [progress setFrame:CGRectMake(self.view.bounds.size.width - 120, 30, 100, 10)];
    progress.progress = [self panelQuality:panel];
    progress.progressTintColor = [UIColor colorWithRed:1-progress.progress green:progress.progress blue:0 alpha:1];
    [cell.contentView addSubview:progress];
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return section == 0?@"My panels":@"Other group member's panels";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Panel *panel = [_fetchedResultsController objectAtIndexPath:indexPath];
    if (_delegate) {
        [self.delegate didSelectPanel:panel];
    }else{
        ADBMetalPanelViewController *panelVC = [[ADBMetalPanelViewController alloc]initWithNibName:nil bundle:nil andPanel:panel];
        
        [self showModalWithCancelButton:panelVC fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    Panel *panel = [_fetchedResultsController objectAtIndexPath:indexPath];
    if (panel.createdBy.intValue == [[ADBAccountManager sharedInstance]currentGroupPerson].gpeGroupPersonId.intValue) {
        return YES;
    }
    return NO;
    //Override when yes
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    Panel *panel = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure" message:@"This action is not reversible" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            [[IPExporter getInstance]deleteObject:panel withBlock:nil];
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    
    
    UITableViewRowAction *renameAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Rename" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Rename panel" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField){
            textField.text = panel.panName;
        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            panel.panName = [(UITextField *)[alert.textFields lastObject]text];
            [[IPExporter getInstance]updateInfoForObject:panel withBlock:nil];
            [self.tableView reloadData];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
    renameAction.backgroundColor = [UIColor orangeColor];
    
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    [array addObject:deleteAction];
    [array addObject:renameAction];
    
    return [NSArray arrayWithArray:array];
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

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [super filterContentForSearchText:searchText scope:scope];
    self.fetchedResultsController = nil;
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
