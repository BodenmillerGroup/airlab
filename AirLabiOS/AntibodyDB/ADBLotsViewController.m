//
//  ADBLotsViewController.m
// AirLab
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
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"reiReagentInstanceId" ascending:YES selector:@selector(localizedStandardCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"reiStatus != %@", @"rejected"];
        if(_clone)request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                    request.predicate,
                                                    [NSPredicate predicateWithFormat:@"clone == %@", _clone]
                                                                                           ]];
        
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"lots"];
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.clone.cloName?[NSString stringWithFormat:@"Lots for %@", self.clone.cloName]:@"All Lots";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fetchedResultsController.fetchedObjects.count;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:_fetchedResultsController.sections.count];
    for (Lot *lot in _fetchedResultsController.fetchedObjects) {
        if (![array containsObject:lot.reiReagentInstanceId] && lot.reiReagentInstanceId) {
            [array addObject:lot.reiReagentInstanceId];
        }
    }
    return array;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    for (Lot *lot in _fetchedResultsController.fetchedObjects) {
        if ([lot.reiReagentInstanceId isEqualToString:title]) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_fetchedResultsController.fetchedObjects indexOfObject:lot] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    return 1;
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
    NSArray *speciesReactive  =  [lot.clone.cloReactivity componentsSeparatedByString:@","];
    NSString *reactive = @"";
    for(NSString *spcProt in speciesReactive){
        NSArray *array = [General searchDataBaseForClass:SPECIES_DB_CLASS withTerm:spcProt inField:@"spcSpeciesId" sortBy:@"spcSpeciesId" ascending:YES inMOC:self.managedObjectContext];
        if (array.count > 0) {
            reactive = [reactive stringByAppendingString:[NSString stringWithFormat:@" %@ |", [(Species *)array.lastObject spcAcronym]]];
        }
    }
    if(reactive.length == 0)reactive = @"Unknown";
    else{
        NSString *string = [reactive substringWithRange:NSMakeRange(0, reactive.length - 1)];
        reactive = string;
    }
    
    cell.textLabel.text = [General showFullLotInfo:lot];
    cell.detailTextLabel.text = [General showFullLotSubInfo:lot withSpecies:reactive];
    
    if (lot.tubFinishedBy.intValue !=0) {
        cell.textLabel.alpha = 0.2f;
        cell.detailTextLabel.alpha = 0.2f;
    }else{
        cell.textLabel.alpha = 1.0f;
        cell.detailTextLabel.alpha = 1.0f;
    }
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    [self setGrayColorInTableText:cell];
    
    if (lot.tubIsLow.intValue == 1) {
        if (lot.tubFinishedBy.intValue == 0)
            cell.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:.3];
    }else{
        cell.backgroundColor = [UIColor clearColor];
    }
    
    if(lot.zetConfirmed.boolValue)cell.textLabel.textColor = [UIColor purpleColor];
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    __block Lot *lot = [_fetchedResultsController objectAtIndexPath:indexPath];
    NSMutableArray *array = [NSMutableArray array];
    UITableViewRowAction *finishAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Finished" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure" message:@"This action is not reversible" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            [General finishedTube:lot withBlock:^{
                [self.tableView reloadData];
            }];
            [General finishedTube:lot withBlock:nil];//Important, to finish also the REI

        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    
    UITableViewRowAction *lowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Mark as low" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [General lowlevelsofTube:lot withBlock:nil];
    }];
    
    UITableViewRowAction *reorderAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Reorder" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reorder" message:@"Would you like to place an order request" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            
            [General reorder:lot withAmount:1 andPurpose:@"Keep stock" withBlock:^{
                [self.tableView reloadData];
            }];
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        [self.tableView reloadData];
    }];
    reorderAction.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
    
    UITableViewRowAction *renameLotAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Rename lot" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Rename lot" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField){
            textField.text = lot.lotNumber;
        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            lot.lotNumber = [(UITextField *)[alert.textFields lastObject]text];
            [[IPExporter getInstance]updateInfoForObject:lot withBlock:nil];
            [self.tableView reloadData];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    renameLotAction.backgroundColor = [UIColor orangeColor];
    
    UITableViewRowAction *confirmExists = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Confirm Stock" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        lot.zetConfirmed = [NSNumber numberWithBool:!lot.zetConfirmed.boolValue];
        [self.tableView reloadData];
    }];
    confirmExists.backgroundColor = [UIColor purpleColor];
    
    if (lot.tubFinishedAt.intValue == 0)
        [array addObject:finishAction];
    
    if (lot.tubIsLow.intValue == 0 && lot.tubFinishedAt.intValue == 0)
        [array addObject:lowAction];
    
    [array addObject:reorderAction];
    [array addObject:renameLotAction];
    
    if ([[ADBAccountManager sharedInstance]currentGroupPerson].gpeErase.boolValue) {
        [array addObject:confirmExists];
    }
    
    return [NSArray arrayWithArray:array];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ADBConjugatesViewController *conjs = [[ADBConjugatesViewController alloc]initWithNibName:nil bundle:nil andLot:[_fetchedResultsController objectAtIndexPath:indexPath]];
    [self.navigationController pushViewController:conjs animated:YES];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    ADBAllInfoForAbViewController *info = [[ADBAllInfoForAbViewController alloc]initWithNibName:nil bundle:nil andLot:[_fetchedResultsController objectAtIndexPath:indexPath]];
    [self.navigationController pushViewController:info animated:YES];
}

//This needs Subclass
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [super filterContentForSearchText:searchText scope:scope];
    
    if (searchText != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clone.cloName contains [cd] %@", searchText];
        NSPredicate *other = [NSPredicate predicateWithFormat:@"clone.protein.proName contains [cd] %@", searchText];
        NSPredicate *or = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate, other]];
        
        [self.fetchedResultsController.fetchRequest setPredicate:or];
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
