//
//  ADBAllReagentsPickerViewController.m
// AirLab
//
//  Created by Raul Catena on 10/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAllReagentsPickerViewController.h"

@interface ADBAllReagentsPickerViewController ()

@end

@implementation ADBAllReagentsPickerViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Select a reagent...";
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:REAGENTINSTANCE_DB_CLASS];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"comertialReagent.comName" ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"reiStatus == %@", @"stock"];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fetchedResultsController.fetchedObjects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"TagCell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    ReagentInstance *rei = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = rei.comertialReagent.comName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Ordered the %@", [General getDateFromDescription:rei.reiOrderedAt]];;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ReagentInstance *rei = [_fetchedResultsController objectAtIndexPath:indexPath];
    [self.delegate didSelectReagentInstance:rei];
}

//This needs Subclass
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [super filterContentForSearchText:searchText scope:scope];
    
    if (searchText != nil) {
        NSPredicate *predicate;
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"reiStatus == %@", @"stock"];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate2,[NSPredicate predicateWithFormat:@"comertialReagent.comName contains [cd] %@", searchText]]];
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
