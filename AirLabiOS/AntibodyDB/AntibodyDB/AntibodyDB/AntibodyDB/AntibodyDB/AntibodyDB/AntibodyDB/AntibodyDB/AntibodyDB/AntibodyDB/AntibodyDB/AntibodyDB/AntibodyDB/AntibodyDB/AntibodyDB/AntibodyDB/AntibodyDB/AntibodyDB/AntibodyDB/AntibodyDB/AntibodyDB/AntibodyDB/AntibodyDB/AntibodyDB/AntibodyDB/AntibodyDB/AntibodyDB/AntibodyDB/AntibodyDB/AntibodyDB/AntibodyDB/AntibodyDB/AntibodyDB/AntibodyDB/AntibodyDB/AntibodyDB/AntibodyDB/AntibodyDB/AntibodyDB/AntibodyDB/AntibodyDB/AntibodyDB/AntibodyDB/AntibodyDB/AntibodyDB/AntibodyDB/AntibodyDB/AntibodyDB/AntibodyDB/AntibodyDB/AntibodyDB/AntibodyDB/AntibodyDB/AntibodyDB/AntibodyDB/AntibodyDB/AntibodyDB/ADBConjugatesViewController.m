//
//  ADBConjugatesViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 3/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBConjugatesViewController.h"
#import "ADBGenericPlaceViewController.h"
#import "ADBAllInfoForAbViewController.h"

@interface ADBConjugatesViewController (){
    BOOL showArchived;
}

@property (nonatomic, strong) Lot *lot;
@property (nonatomic, strong) LabeledAntibody *deletable;

@end

@implementation ADBConjugatesViewController

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
    self.title = @"Antibody conjugates";
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem)], [[UIBarButtonItem alloc]initWithTitle:@"Show archived" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleArchived:)]];
}

-(void)toggleArchived:(UIBarButtonItem *)sender{
    showArchived = !(BOOL)sender.tag;
    if (sender.tag == 0) {
        sender.tag = 1;
        sender.title = @"Hide archived";
        [self.tableView reloadData];
        return;
    }
    sender.tag = 0;
    sender.title = @"Show archived";
    [self.tableView reloadData];
}

-(void)showAdd{
    ADBAddConjugateViewController *add = [[ADBAddConjugateViewController alloc]init];
    add.delegate = self;
    [self showModalWithCancelButton:add fromVC:self withPresentationStyle:UIModalPresentationFormSheet];
}

-(void)addItem{
    [self showAdd];
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request;
        if (_lot) {
            request = [NSFetchRequest fetchRequestWithEntityName:LABELEDANTIBODY_DB_CLASS];
            request.predicate = [NSPredicate predicateWithFormat:@"lot = %@", _lot];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"labBBTubeNumber" ascending:YES]];
        }else{
            request = [NSFetchRequest fetchRequestWithEntityName:PROTEIN_DB_CLASS];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"proName" ascending:YES]];
        }
        [NSFetchedResultsController deleteCacheWithName:@"conjugates"];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"conjugates"];//TODO add section name keypath with protein or epitope
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(NSArray *)conjugatesForProtein:(Protein *)protein{
    NSMutableArray *labs = [NSMutableArray array];
    for(Clone *clone in protein.clones){
        for(Lot *lot in clone.lots){
            for(LabeledAntibody *lab in lot.labeledAntibodies){
                if (!showArchived && lab.deleted.boolValue) {
                    continue;
                }
                [labs addObject:lab];
            }
        }
    }
    return labs;
}

-(LabeledAntibody *)conjugateForIndexPath:(NSIndexPath *)indexPath{
    Protein *prot = [_fetchedResultsController.fetchedObjects objectAtIndex:indexPath.section];
    NSArray *labs = [self conjugatesForProtein:prot];
    LabeledAntibody *conjugate = [labs objectAtIndex:indexPath.row];
    return conjugate;
}

#pragma mark UITableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_lot) {
        return 1;
    }
    NSInteger count = [_fetchedResultsController.fetchedObjects count];
    return count;
}

-(void)setColorAndFontToCell:(UITableViewCell *)cell{
    //cell.textLabel.font = [UIFont fontWithName:GENERAL_FONT size:20];//cell.textLabel.font.pointSize];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    //cell.detailTextLabel.font = [UIFont fontWithName:GENERAL_FONT size:17];//cell.detailTextLabel.font.pointSize];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_lot) {
        return _fetchedResultsController.fetchedObjects.count;
    }
    
    Protein *prot = [_fetchedResultsController.fetchedObjects objectAtIndex:section];
    
	return [self conjugatesForProtein:prot].count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (!_lot) {
        Protein *prot = [_fetchedResultsController.fetchedObjects objectAtIndex:section];
        return prot.proName;
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"CloneCell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }

    LabeledAntibody *conjugate;
    if (_lot) {
        conjugate = [_fetchedResultsController objectAtIndexPath:indexPath];
    }else{
        conjugate = [self conjugateForIndexPath:indexPath];
    }
        
    NSString *string;
    if (conjugate.tag.tagIsMetal.boolValue) {
        string = [NSString stringWithFormat:@"%@%@", conjugate.tag.tagMW, conjugate.tag.tagName];
    }else{
        string = conjugate.tag.tagName;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@) | Lot %@ | Label %@", conjugate.lot.clone.protein.proName, conjugate.lot.clone.cloName, conjugate.lot.lotNumber, string];
    if (conjugate.lot.clone.cloIsPhospho.boolValue) {
        cell.textLabel.text = [@"p-" stringByAppendingString:cell.textLabel.text];
    }
    
    cell.textLabel.text = [[NSString stringWithFormat:@"#%@ ", conjugate.labBBTubeNumber] stringByAppendingString:cell.textLabel.text];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Date of conjugation: %@", conjugate.labDateOfLabeling];
    
    if (conjugate.place) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    cell.tintColor = [UIColor orangeColor];
        
    UIColor *color;
    if(conjugate.deleted.boolValue){
        color = [UIColor colorWithWhite:0.9 alpha:1];
    }else{
        if(conjugate.labCellsUsedForValidation.length > 0 || conjugate.lot.lotCellsValidation.length > 0 || conjugate.lot.validationExperiments.count > 0){
            NSArray *array = [General arrayOfValidationNotesForLot:conjugate.lot andConjugate:conjugate];
            color = [General colorForValidationNotesDictionaryArray:array];
            cell.accessoryType = UITableViewCellAccessoryDetailButton;
        }else{
            color = [UIColor darkGrayColor];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    cell.textLabel.textColor = color;
    cell.detailTextLabel.textColor = color;
    
    if (conjugate.catchedInfo.intValue == 1 && conjugate.deleted.intValue != 1) {
        cell.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:.3];
    }else{
        cell.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (!_lot) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:_fetchedResultsController.sections.count];
        for (Protein *protein in _fetchedResultsController.fetchedObjects) {
            if (![array containsObject:[protein.proName substringToIndex:1]]) {
                [array addObject:[protein.proName substringToIndex:1]];
            }
        }
        return [NSArray arrayWithArray:array];
    }
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    for (Protein *protein in _fetchedResultsController.fetchedObjects) {
        if ([protein.proName hasPrefix:title]) {
            return [_fetchedResultsController.fetchedObjects indexOfObject:protein];
        }
    }
    return index;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LabeledAntibody *conjugate;
    if (_lot) {
        conjugate = [_fetchedResultsController objectAtIndexPath:indexPath];
    }else{
        conjugate = [self conjugateForIndexPath:indexPath];
    }
    if (conjugate.place) {
        Place *parent = conjugate.place.parent;
        ADBGenericPlaceViewController *placeViewer = [[ADBGenericPlaceViewController alloc]initWithNibName:nil bundle:nil andPlace:parent andScope:[NSArray arrayWithObjects:conjugate.place, nil]];
        [self.navigationController pushViewController:placeViewer animated:YES];
    }
}

//Override if necesary
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    LabeledAntibody *conjugate;
    if (_lot) {
        conjugate = [_fetchedResultsController objectAtIndexPath:indexPath];
    }else{
        conjugate = [self conjugateForIndexPath:indexPath];
    }
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Archive" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        if (!conjugate.deleted.boolValue) {
            _deletable = conjugate;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Archive?" message:@"Are you sure? This action can not be undone" delegate:self cancelButtonTitle:@"Archive" otherButtonTitles:@"Cancel", nil];
            alert.tag = 1;
            [alert show];
        }
    }];

    UITableViewRowAction *shareAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Mark is low" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){

        conjugate.catchedInfo = @"1";
            [[IPExporter getInstance]updateInfoForObject:conjugate withBlock:nil];
        [self.tableView reloadData];
        }];
        shareAction.backgroundColor = [UIColor grayColor];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    if (conjugate.deleted.intValue != 1) {
        [array addObject:deleteAction];
    }
    if (conjugate.catchedInfo.intValue != 1 && conjugate.deleted.intValue != 1) {
        [array addObject:shareAction];
    }
    return [NSArray arrayWithArray:array];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1 && buttonIndex == 0){
        //_deletable.deleted = @"1";
        [[IPExporter getInstance]deleteObject:_deletable withBlock:nil];
        [self.tableView reloadData];
    }
}


-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
    LabeledAntibody *conjugate;
    if (_lot) {
        conjugate = [_fetchedResultsController objectAtIndexPath:indexPath];
    }else{
        conjugate = [self conjugateForIndexPath:indexPath];
    }
    ADBAllInfoForAbViewController *info = [[ADBAllInfoForAbViewController alloc]initWithNibName:nil bundle:nil andConjugate:conjugate];
    [self.navigationController pushViewController:info animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

#pragma mark addconjugateprotocol

-(void)addConjugate:(ADBAddConjugateViewController *)controller{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self refreshTable];
}

//This needs Subclass
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[super filterContentForSearchText:searchText scope:scope];
	if (!self.previousPredicate) {
        self.previousPredicate = self.fetchedResultsController.fetchRequest.predicate;
    }
    
	if (searchText != nil) {
        if (!_lot) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"proName contains [cd] %@", searchText];
            NSPredicate *other = [NSPredicate predicateWithFormat:@"ANY clones.cloName contains [cd] %@", searchText];
            
            [self.fetchedResultsController.fetchRequest setPredicate:[NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, other, nil]]];
            [NSFetchedResultsController deleteCacheWithName:@"allCache"];
        }
		
	}else {
		[self.fetchedResultsController.fetchRequest setPredicate:self.previousPredicate];
		[NSFetchedResultsController deleteCacheWithName:@"allCache"];
	}
	[self refreshTable];
    NSLog(@"results: %lu", (unsigned long)[[self.fetchedResultsController fetchedObjects]count]);
	self.searchDisplayController.searchBar.showsCancelButton = YES;
}


@end
