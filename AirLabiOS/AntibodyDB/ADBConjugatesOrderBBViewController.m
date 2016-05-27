//
//  ADBConjugatesOrderBBViewController.m
// AirLab
//
//  Created by Raul Catena on 8/11/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBConjugatesOrderBBViewController.h"
#import "ADBGenericPlaceViewController.h"
#import "ADBAllInfoForAbViewController.h"

@interface ADBConjugatesOrderBBViewController ()
@property (nonatomic, strong) Lot *lot;
@property (nonatomic, strong) LabeledAntibody *deletable;
@end

@implementation ADBConjugatesOrderBBViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andLot:(Lot *)lot
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.lot = lot;
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Antibody conjugates, by tube number";
    [self setTheTableviewWithStyle:UITableViewStylePlain];
    self.tableView.tintColor = [UIColor orangeColor];

}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:LABELEDANTIBODY_DB_CLASS];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"labBBTubeNumber" ascending:YES selector:@selector(localizedStandardCompare:)]];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)setColorAndFontToCell:(UITableViewCell *)cell{
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fetchedResultsController.fetchedObjects.count;
}


//Overriding from super
-(LabeledAntibody *)conjugateForIndexPath:(NSIndexPath *)indexPath{
    return [_fetchedResultsController objectAtIndexPath:indexPath];
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (!_lot) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:_fetchedResultsController.sections.count];
        for (LabeledAntibody *lab in _fetchedResultsController.fetchedObjects) {
            if (![array containsObject:lab.labBBTubeNumber] && lab.labBBTubeNumber) {
                [array addObject:lab.labBBTubeNumber];
            }
        }
        return [NSArray arrayWithArray:array];
    }
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    for (LabeledAntibody *lab in _fetchedResultsController.fetchedObjects) {
        if ([lab.labBBTubeNumber isEqualToString:title]) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_fetchedResultsController.fetchedObjects indexOfObject:lab] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


//This needs Subclass
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[super filterContentForSearchText:searchText scope:scope];
    
	if (searchText != nil) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lot.clone.cloName contains [cd] %@", searchText];
        NSPredicate *other = [NSPredicate predicateWithFormat:@"ANY lot.lotNumber contains [cd] %@", searchText];
        NSPredicate *last = [NSPredicate predicateWithFormat:@"lot.clone.protein.proName contains [cd] %@", searchText];
        
		[self.fetchedResultsController.fetchRequest setPredicate:[NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, other, last, nil]]];
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
