//
//  ADBProteinsViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/7/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBProteinsViewController.h"
#import "ADBClonesByProtViewController.h"
#import "ADBAntibodiesViewController.h"

@interface ADBProteinsViewController ()

@end

@implementation ADBProteinsViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Proteins";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem)];
}

-(void)showAdd{
    ADBAddTargetViewController *add = [[ADBAddTargetViewController alloc]init];
    add.delegate = self;
    [self showModalWithCancelButton:add fromVC:self withPresentationStyle:UIModalPresentationFormSheet];
}

-(void)addItem{
    [self showAdd];
}


#pragma mark openbis delegate

-(void)didGetData:(NSData *)data{
    [self dismissModalOrPopover];
}

-(void)didFailedToGetData{
    [General showOKAlertWithTitle:@"Error" andMessage:@"Could not connect to OpenBis, try to synchronise again later"];
    [self dismissModalOrPopover];
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:PROTEIN_DB_CLASS];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"proProteinId" ascending:YES]];
        [NSFetchedResultsController deleteCacheWithName:@"proteins"];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"proteins"];//TODO add section name keypath with protein or epitope
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fetchedResultsController.fetchedObjects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"CloneCell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    Protein *protein = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = protein.proName;
    int cloneNumber = protein.clones.count;
    NSString *clonesString = [NSString stringWithFormat:@"%i clone", cloneNumber];
    if(cloneNumber != 1)clonesString = [clonesString stringByAppendingString:@"s"];
    cell.detailTextLabel.text = clonesString;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    Protein *protein  = [_fetchedResultsController objectAtIndexPath:indexPath];
    ADBAntibodiesViewController *clones = [[ADBAntibodiesViewController alloc]initWithNibName:nil bundle:nil andProtein:protein];
    clones.title = [NSString stringWithFormat:@"%@ | Clones", protein.proName];
    [self.navigationController pushViewController:clones animated:YES];
}

#pragma mark -
#pragma mark Content Filtering

//This needs Subclass
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[super filterContentForSearchText:searchText scope:scope];
	if (!self.previousPredicate) {
        self.previousPredicate = self.fetchedResultsController.fetchRequest.predicate;
    }
    
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


#pragma mark AddTargetDelegate

-(void)didAddTarget:(Protein *)protein{
    
    [self refreshTable];
}


@end
