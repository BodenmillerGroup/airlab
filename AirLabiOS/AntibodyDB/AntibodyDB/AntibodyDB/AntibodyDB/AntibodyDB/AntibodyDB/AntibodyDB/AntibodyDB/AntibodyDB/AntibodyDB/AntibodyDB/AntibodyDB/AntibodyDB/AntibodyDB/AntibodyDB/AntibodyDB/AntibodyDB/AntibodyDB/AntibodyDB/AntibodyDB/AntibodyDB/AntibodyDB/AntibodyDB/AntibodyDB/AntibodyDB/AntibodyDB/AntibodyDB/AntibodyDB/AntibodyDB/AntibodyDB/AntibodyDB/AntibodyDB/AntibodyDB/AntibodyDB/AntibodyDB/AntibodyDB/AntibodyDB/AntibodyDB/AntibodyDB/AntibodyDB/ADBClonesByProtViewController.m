//
//  ADBClonesByProtViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/15/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBClonesByProtViewController.h"
#import "ADBLotsViewController.h"

@interface ADBClonesByProtViewController ()

@end

@implementation ADBClonesByProtViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize protein = _protein;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andProtein:(Protein *)prot
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.protein = prot;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTheTableviewWithStyle:UITableViewStylePlain];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem)];
}

-(void)showAdd{
    ADBAddAntibodyViewController *add = [[ADBAddAntibodyViewController alloc]initWithNibName:nil bundle:nil andProtein:_protein];
    add.delegate = self;
    [self showModalWithCancelButton:add fromVC:self withPresentationStyle:UIModalPresentationFormSheet];
}

-(void)addItem{
    [self showAdd];
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CLASS_CLONE];
        request.predicate = [NSPredicate predicateWithFormat:@"protein == %@", self.protein];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cloCloneId" ascending:YES]];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];//TODO add section name keypath with protein or epitope
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
    Clone *clone = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = clone.cloName;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ADBLotsViewController *lots = [[ADBLotsViewController alloc]initWithNibName:nil bundle:nil andClone:[_fetchedResultsController objectAtIndexPath:indexPath]];
    [self.navigationController pushViewController:lots animated:YES];
}


@end
