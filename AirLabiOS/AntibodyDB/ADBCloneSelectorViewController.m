//
//  ADBCloneSelectorViewController.m
// AirLab
//
//  Created by Raul Catena on 4/1/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBCloneSelectorViewController.h"

@interface ADBCloneSelectorViewController ()

@end

@implementation ADBCloneSelectorViewController

@synthesize delegate = _delegate;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize clone = _clone;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil clone:(Clone *)clone
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.clone = clone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        
        if(self.clone){
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:LOT_DB_CLASS];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"reiReagentInstanceId" ascending:YES]];
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"clone == %@", self.clone];
            //NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"tubFinishedBy == 0"];
            request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate]];
            NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];//TODO add section name keypath with protein or epitope
            self.fetchedResultsController = controller;
        }else{
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CLASS_CLONE];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"protein.proName" ascending:YES]];
            NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];//TODO add section name keypath with protein or epitope
            self.fetchedResultsController = controller;
        }
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
    cell.textLabel.textColor = [UIColor blackColor];
    if(self.clone){
        Lot *lot = [_fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = lot.lotNumber;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Ordered: %@", lot.reiRequestedAt];
        if(lot.tubFinishedBy.intValue != 0)cell.textLabel.textColor = [UIColor lightGrayColor];
    }else{
        Clone *clone = [_fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [General showFullAntibodyName:clone withSpecies:NO], clone.speciesHost.spcAcronym];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.clone){
        [self.delegate didSelectLot:[_fetchedResultsController objectAtIndexPath:indexPath]];
        return;
    }
    Clone *clone = [_fetchedResultsController objectAtIndexPath:indexPath];
    ADBCloneSelectorViewController *lotSelector = [[ADBCloneSelectorViewController alloc]initWithNibName:nil bundle:nil clone:clone];
    lotSelector.delegate = self.delegate;
    [self.navigationController pushViewController:lotSelector animated:YES];
}

//This needs Subclass
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[super filterContentForSearchText:searchText scope:scope];
    
	if (searchText != nil) {
        NSPredicate *predicate;
        if(self.clone){
            NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"clone == %@", self.clone];
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate2,[NSPredicate predicateWithFormat:@"lotName contains [cd] %@", searchText]]];
        }else{
            predicate = [NSPredicate predicateWithFormat:@"protein.proName contains [cd] %@", searchText];
        }
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
