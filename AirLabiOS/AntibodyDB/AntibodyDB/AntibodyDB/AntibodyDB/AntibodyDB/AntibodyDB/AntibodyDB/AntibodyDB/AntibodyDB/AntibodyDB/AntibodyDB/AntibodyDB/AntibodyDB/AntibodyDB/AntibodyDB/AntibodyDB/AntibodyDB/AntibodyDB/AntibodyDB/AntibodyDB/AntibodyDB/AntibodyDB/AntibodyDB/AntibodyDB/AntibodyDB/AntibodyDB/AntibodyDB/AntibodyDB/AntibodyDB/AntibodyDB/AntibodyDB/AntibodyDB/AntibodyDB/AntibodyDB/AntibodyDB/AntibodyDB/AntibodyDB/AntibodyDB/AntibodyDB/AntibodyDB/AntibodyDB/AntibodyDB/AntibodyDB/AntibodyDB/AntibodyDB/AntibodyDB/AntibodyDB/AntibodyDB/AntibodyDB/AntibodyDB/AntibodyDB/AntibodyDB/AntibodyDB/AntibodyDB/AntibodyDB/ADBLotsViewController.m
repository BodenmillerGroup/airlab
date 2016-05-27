//
//  ADBLotsViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 6/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBLotsViewController.h"
#import "ADBConjugatesViewController.h"
#import "ADBAllInfoForAbViewController.h"

@interface ADBLotsViewController ()

@property (nonatomic, strong) Clone *clone;

@end

@implementation ADBLotsViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andClone:(Clone *)clone
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.clone = clone;
    }
    return self;
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:LOT_DB_CLASS];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lotLotId" ascending:YES]];
        
        request.predicate = [NSPredicate predicateWithFormat:@"clone == %@", _clone];
        [NSFetchedResultsController deleteCacheWithName:@"lost"];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"lots"];//TODO add section name keypath with protein or epitope
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTheTableviewWithStyle:UITableViewStylePlain];
    self.title = [NSString stringWithFormat:@"Lots for %@", self.clone.cloName];
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
    Lot *lot = [_fetchedResultsController objectAtIndexPath:indexPath];
    NSSet *speciesReactive  = lot.clone.cloneSpeciesProteins;
    NSString *reactive = @"";
    for(ZCloneSpeciesProtein *spcProt in speciesReactive){
        reactive = [reactive stringByAppendingString:[NSString stringWithFormat:@" %@ |", spcProt.speciesProtein.species.spcAcronym]];
    }
    if(reactive.length == 0)reactive = @"Unknown";
    else{
        NSString *string = [reactive substringWithRange:NSMakeRange(0, reactive.length - 1)];
        reactive = string;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ - (raised in %@)", lot.clone.protein.proName, lot.clone.cloName, lot.clone.speciesHost.spcName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Lot %@ | Reactive with: %@", lot.lotNumber, reactive];
    
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    [self setGrayColorInTableText:cell];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ADBConjugatesViewController *conjs = [[ADBConjugatesViewController alloc]initWithNibName:nil bundle:nil andLot:[_fetchedResultsController objectAtIndexPath:indexPath]];
    [self.navigationController pushViewController:conjs animated:YES];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    ADBAllInfoForAbViewController *info = [[ADBAllInfoForAbViewController alloc]initWithNibName:nil bundle:nil andLot:[_fetchedResultsController objectAtIndexPath:indexPath]];
    [self.navigationController pushViewController:info animated:YES];
}

@end
