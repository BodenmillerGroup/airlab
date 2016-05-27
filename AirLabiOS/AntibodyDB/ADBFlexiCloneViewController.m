//
//  ADBFlexiCloneViewController.m
//  AirLab
//
//  Created by Raul Catena on 1/21/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import "ADBFlexiCloneViewController.h"

@interface ADBFlexiCloneViewController ()

@end

@implementation ADBFlexiCloneViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CLASS_CLONE];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:[[IPImporter getInstance]keyOfObject:CLASS_CLONE] ascending:YES]];
        [NSFetchedResultsController deleteCacheWithName:@"antibodies"];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"antibodies"];//TODO add section name keypath with protein or epitope
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
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    for(UIView *aView in cell.contentView.subviews){
        if([aView isMemberOfClass:[UIButton class]]){
            [aView removeFromSuperview];
        }
    }
    Clone *clone = [_fetchedResultsController objectAtIndexPath:indexPath];
    NSArray *speciesReactive  = [clone.cloReactivity componentsSeparatedByString:@","];
    NSString *reactive = @"";
    for(NSString *spcProt in speciesReactive){
        NSArray *results = [General searchDataBaseForClass:SPECIES_DB_CLASS withTerm:spcProt inField:@"spcSpeciesId" sortBy:@"spcSpeciesId" ascending:YES inMOC:self.managedObjectContext];
        if (results.count > 0) {
            Species *spc = results.lastObject;
            reactive = [reactive stringByAppendingString:[NSString stringWithFormat:@" %@ |", spc.spcAcronym]];
        }
    }
    if(reactive.length == 0)reactive = @"Unknown";
    else{
        if (reactive.length > 1){
            NSString *string = [reactive substringWithRange:NSMakeRange(0, reactive.length - 1)];
            reactive = string;
        }
    }

    cell.textLabel.text = [General showFullAntibodyName:clone withSpecies:YES];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ Reactive with: %@", clone.cloBindingRegion, reactive];
    [self setGrayColorInTableText:cell];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.delegate didSelectFlexiClone:[_fetchedResultsController objectAtIndexPath:indexPath] from:self];
}

//This needs Subclass
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [super filterContentForSearchText:searchText scope:scope];
    
    if (searchText != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cloName contains [cd] %@", searchText];
        NSPredicate *other = [NSPredicate predicateWithFormat:@"protein.proName contains [cd] %@", searchText];
        
        [self.fetchedResultsController.fetchRequest setPredicate:[NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, other, nil]]];
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
