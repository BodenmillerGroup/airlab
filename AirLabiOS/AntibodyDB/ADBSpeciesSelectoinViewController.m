//
//  ADBSpeciesSelectoinViewController.m
// AirLab
//
//  Created by Raul Catena on 4/1/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBSpeciesSelectoinViewController.h"
#import "Species.h"

@interface ADBSpeciesSelectoinViewController ()

@end

@implementation ADBSpeciesSelectoinViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize delegate = _delegate;
@synthesize multiselector = _multiselector;
@synthesize selection = _selection;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andMultiSelector:(BOOL)multisel
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.multiselector = multisel;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(_selection.count == 0)
    self.selection = [NSMutableArray array];
    [self setTheTableviewWithStyle:UITableViewStylePlain];
    if (self.multiselector) {
         self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    }
}

-(void)done{
    [self.delegate didSelectSpeciesArray:self.selection];
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:SPECIES_DB_CLASS];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"catchedInfo" ascending:YES]];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];//TODO add section name keypath with protein or epitope
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fetchedResultsController.fetchedObjects.count;
}

-(void)formatCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withSpecies:(Species *)species{
    if([_selection containsObject:species]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"TagCell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    Species *species = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = species.spcName;
    
    [self formatCell:cell atIndexPath:indexPath withSpecies:species];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (self.multiselector) {
        Species *species = [_fetchedResultsController objectAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self.selection removeObject:species];
        }else if (cell.accessoryType == UITableViewCellAccessoryNone){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self.selection addObject:species];
        }
        
    }else{
        Species *species = [_fetchedResultsController objectAtIndexPath:indexPath];
        [self.delegate didSelectSpecies:species];
    }
}


@end
