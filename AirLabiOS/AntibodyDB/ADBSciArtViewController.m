//
//  ADBSciArtViewController.m
//  LabPad
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBSciArtViewController.h"
#import "ADBSeePaperViewController.h"
#import "ADBArticleCellViewController.h"
#import "ADBPubmedSearchViewController.h"
#import "ADBPubmedSession.h"
#import "ScientificArticle.h"


@implementation ADBSciArtViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My Articles";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[IPFetchObjects getInstance]addScientificArticlesForGroupFromServerWithBlock:^{
        [_fetchedResultsController performFetch:nil];
        [self.tableView reloadData];
    }];
    
    [[IPFetchObjects getInstance]addScientificArticlesForPersonFromServerWithBlock:^{
        [_fetchedResultsController performFetch:nil];
        [self.tableView reloadData];
    }];
    
    [General iPhoneBlock:^{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchGo)];
    } iPadBlock:nil];
    
    [[ADBPubmedSession sharedInstance]reloadSession];
    
    [self choiceDone:_choice];
}

-(void)searchGo{
    ADBPubmedSearchViewController *search = [[ADBPubmedSearchViewController alloc]init];
    [self.navigationController pushViewController:search animated:YES];
}

-(void)choiceDone:(UISegmentedControl *)sender{
    _fetchedResultsController = nil;
    [self refreshTable];
}

#pragma mark tableView


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fetchedResultsController.fetchedObjects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 111;
}

- (ADBArticleCellViewController *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Dequeue or if necessary create a RecipeTableViewCell, then set its recipe to the recipe for the current row.
    static NSString *ReagentCellIdentifier = @"PaperCellIdentifier";
    
	//Here put custom cells
	ADBArticleCellViewController *papercell = (ADBArticleCellViewController *)[self.tableView dequeueReusableCellWithIdentifier:ReagentCellIdentifier];
    if (papercell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ADBArticleCellViewController" owner:self options:nil];
        papercell = [topLevelObjects objectAtIndex:0];
    }

	ScientificArticle *paper = (ScientificArticle *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	papercell.titlePaperLabel.text = paper.sciTitle;
	papercell.authors.text = paper.sciAuthors;
	papercell.journal.text = paper.sciSource;
	papercell.date.text = paper.sciPubDate;
    
    return papercell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
	ADBSeePaperViewController *advc = [[ADBSeePaperViewController alloc]initWithNibName:nil bundle:nil andArticle:[_fetchedResultsController objectAtIndexPath:indexPath]];
    [General iPhoneBlock:^{
        [self.navigationController pushViewController:advc animated:YES];
    } iPadBlock:^{
        [[[self.navigationController.splitViewController viewControllers] objectAtIndex:1] setViewControllers:[NSArray arrayWithObject:advc]];
    }];
}


#pragma mark fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController == nil) {
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:SCIENTIFICARTICLE_DB_CLASS];
        fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"sciTitle" ascending:YES]];
        if (_choice.selectedSegmentIndex == 0) {
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"createdBy == %@", [[ADBAccountManager sharedInstance]currentGroupPerson].gpeGroupPersonId];
        }else{
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"sciLabShared == %@", @"1"];
        }
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate = self;
		
        self.fetchedResultsController = aFetchedResultsController;
    }
	
	return _fetchedResultsController;
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
	
	self.searchDisplayController.searchBar.showsCancelButton = NO;
	
	if (searchText != nil) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sciTitle contains [cd] %@", searchText];
        NSPredicate *predicatePerson = [NSPredicate predicateWithFormat:@"sciAuthors contains [cd] %@", searchText];
        NSPredicate *compound = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, predicatePerson, nil]];
		[_fetchedResultsController.fetchRequest setPredicate:compound];
		[NSFetchedResultsController deleteCacheWithName:SCIENTIFICARTICLE_DB_CLASS];
	}else {
		[_fetchedResultsController.fetchRequest setPredicate:nil];
		[NSFetchedResultsController deleteCacheWithName:SCIENTIFICARTICLE_DB_CLASS];
	}

    
	[self refreshTable];
    
	self.searchDisplayController.searchBar.showsCancelButton = YES;
}



@end
