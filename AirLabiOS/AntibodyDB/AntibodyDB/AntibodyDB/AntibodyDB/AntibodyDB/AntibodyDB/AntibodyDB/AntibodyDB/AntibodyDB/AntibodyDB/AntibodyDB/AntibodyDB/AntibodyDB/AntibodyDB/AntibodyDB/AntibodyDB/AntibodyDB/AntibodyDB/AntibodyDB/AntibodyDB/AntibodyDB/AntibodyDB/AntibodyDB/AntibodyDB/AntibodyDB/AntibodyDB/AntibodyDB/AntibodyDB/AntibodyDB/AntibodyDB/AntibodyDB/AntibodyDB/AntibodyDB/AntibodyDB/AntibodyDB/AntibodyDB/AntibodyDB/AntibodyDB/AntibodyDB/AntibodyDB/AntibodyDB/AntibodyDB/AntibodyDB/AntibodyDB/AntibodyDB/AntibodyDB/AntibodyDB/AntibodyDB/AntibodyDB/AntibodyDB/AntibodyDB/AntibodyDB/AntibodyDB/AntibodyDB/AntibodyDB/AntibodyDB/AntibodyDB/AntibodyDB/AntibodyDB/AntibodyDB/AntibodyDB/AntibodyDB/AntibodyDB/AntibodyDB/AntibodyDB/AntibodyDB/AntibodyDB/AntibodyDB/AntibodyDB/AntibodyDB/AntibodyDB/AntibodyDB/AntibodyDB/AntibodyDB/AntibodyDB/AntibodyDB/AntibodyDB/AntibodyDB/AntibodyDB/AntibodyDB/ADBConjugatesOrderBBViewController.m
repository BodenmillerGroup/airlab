//
//  ADBConjugatesOrderBBViewController.m
//  AntibodyDB
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
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:LABELEDANTIBODY_DB_CLASS];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"labBBTubeNumber" ascending:YES selector:@selector(localizedStandardCompare:)]];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];//TODO add section name keypath with protein or epitope
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)setColorAndFontToCell:(UITableViewCell *)cell{
    //cell.textLabel.font = [UIFont fontWithName:GENERAL_FONT size:20];//cell.textLabel.font.pointSize];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    //cell.detailTextLabel.font = [UIFont fontWithName:GENERAL_FONT size:17];//cell.detailTextLabel.font.pointSize];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
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
    
    LabeledAntibody *conjugate = [_fetchedResultsController objectAtIndexPath:indexPath];
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
        }else{
            color = [UIColor darkGrayColor];
        }
    }
    
    cell.textLabel.textColor = color;
    cell.detailTextLabel.textColor = color;
    
    return cell;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LabeledAntibody *labAB = [_fetchedResultsController objectAtIndexPath:indexPath];
    if (labAB.place) {
        Place *parent = labAB.place.parent;
        ADBGenericPlaceViewController *placeViewer = [[ADBGenericPlaceViewController alloc]initWithNibName:nil bundle:nil andPlace:parent andScope:[NSArray arrayWithObjects:labAB.place, nil]];
        [self.navigationController pushViewController:placeViewer animated:YES];
    }
}

//Override if necesary
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    LabeledAntibody *conjugate = [_fetchedResultsController objectAtIndexPath:indexPath];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LabeledAntibody *deletable = [_fetchedResultsController objectAtIndexPath:indexPath];
        if (!deletable.deleted.boolValue) {
            _deletable = deletable;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Delete?" message:@"Are you sure? This action can not be undone" delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
            alert.tag = 1;
            [alert show];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1 && buttonIndex == 0){
        //_deletable.deleted = @"1";
        [[IPExporter getInstance]deleteObject:_deletable withBlock:nil];
        [self.tableView reloadData];
    }
}


-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
    LabeledAntibody *conjugate = [_fetchedResultsController objectAtIndexPath:indexPath];
    ADBAllInfoForAbViewController *info = [[ADBAllInfoForAbViewController alloc]initWithNibName:nil bundle:nil andConjugate:conjugate];
    [self.navigationController pushViewController:info animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


//This needs Subclass
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[super filterContentForSearchText:searchText scope:scope];
	if (!self.previousPredicate) {
        self.previousPredicate = self.fetchedResultsController.fetchRequest.predicate;
    }
    
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
