//
//  ADBTargetViewController.m
// AirLab
//
//  Created by Raul Catena on 4/1/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBTargetViewController.h"

@interface ADBTargetViewController ()

@end

@implementation ADBTargetViewController

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
    //[self setTheTableviewWithStyle:UITableViewStylePlain];
    self.title = @"Select target";
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:PROTEIN_DB_CLASS];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"proProteinId" ascending:YES]];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];//TODO add section name keypath with protein or epitope
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
    Protein *protein = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", protein.proName];// - %@", protein.proName, protein.proNcbiGeneID];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate didSelectTarget:[_fetchedResultsController objectAtIndexPath:indexPath]];
}

//This needs Subclass
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[super filterContentForSearchText:searchText scope:scope];
    
	if (searchText != nil) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"proName contains [cd] %@", searchText];
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
