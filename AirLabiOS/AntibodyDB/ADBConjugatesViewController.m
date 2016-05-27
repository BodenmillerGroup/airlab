//
//  ADBConjugatesViewController.m
// AirLab
//
//  Created by Raul Catena on 3/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBConjugatesViewController.h"
#import "ADBGenericPlaceViewController.h"
#import "ADBAllInfoForAbViewController.h"
#import "ADBInfoCommertialViewController.h"

@interface ADBConjugatesViewController (){
    BOOL showArchived;
}

@property (nonatomic, strong) Lot *lot;

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

-(void)getNumberForConj:(LabeledAntibody *)lab{
    NSMutableURLRequest *request = [General callToAPI:@"lastAntibodyForGroup" withPost:[NSString stringWithFormat:@"data={\"groupId\":\"%@\"}", [[ADBAccountManager sharedInstance]currentGroupPerson].group.grpGroupId]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (!error) {
            NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[@"Label tube with conjugated anti-" stringByAppendingString:lab.lot.clone.protein.proName] message:result preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *close = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:close];
            [self presentViewController:alert animated:YES completion:nil];
            
            if (result.intValue != 0) {
                lab.labBBTubeNumber = result;
                [General saveContextAndRoll];
                if (lab.labLabeledAntibodyId) {
                    [[IPExporter getInstance]updateInfoForObject:lab withBlock:nil];
                }
            }
        }
    }];
}

-(void)checkNumbers{
    NSArray *array = [General searchDataBaseForClass:LABELEDANTIBODY_DB_CLASS sortBy:@"createdAt" ascending:YES inMOC:self.managedObjectContext];
    for (LabeledAntibody *lab in array) {
        if (lab.labBBTubeNumber)continue;
        else {
            [self getNumberForConj:lab];
            return;//Important to go stepwise
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Antibody conjugates";
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem)], [[UIBarButtonItem alloc]initWithTitle:@"Show Finished" style:UIBarButtonItemStyleDone target:self action:@selector(toggleArchived:)]];
    [self checkNumbers];
}

-(void)toggleArchived:(UIBarButtonItem *)sender{
    showArchived = !(BOOL)sender.tag;
    if (sender.tag == 0) {
        sender.tag = 1;
        sender.title = @"Hide Finished";
        [self.tableView reloadData];
        return;
    }
    sender.tag = 0;
    sender.title = @"Show Finished";
    [self.tableView reloadData];
}

-(void)showAdd{
    ADBAddConjugateViewController *add = [[ADBAddConjugateViewController alloc]init];
    add.delegate = self;
    if (_lot)[add didSelectLot:_lot];
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
                if (!showArchived && lab.tubFinishedBy.intValue != 0) {
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
    cell.textLabel.textColor = [UIColor darkGrayColor];
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

-(void)addApplicationsBulletsToCell:(UITableViewCell *)cell withClone:(Clone *)clone{
    for(UIView *aView in cell.contentView.subviews){
        if([aView isMemberOfClass:[UILabel class]] && aView.tag == 1)[aView removeFromSuperview];
    }
    UILabel *labelI = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 50, 5, 20, 20)];
    labelI.text = @"I";
    labelI.backgroundColor = [UIColor lightGrayColor];//[ADBApplicationType colorForImaging:[General jsonStringToObject:clone.cloApplication]];
    labelI.textColor = [UIColor whiteColor];
    labelI.layer.cornerRadius = labelI.bounds.size.width/2;
    labelI.textAlignment = NSTextAlignmentCenter;
    labelI.clipsToBounds = YES;
    labelI.tag = 1;
    UIColor *acolor = [General colorForClone:clone forApplication:1];
    if([General antibodyWorksForFlow:clone]){
        [cell.contentView addSubview:labelI];
        if(acolor)labelI.backgroundColor = acolor;
    }else{
        if(acolor){
            [cell.contentView addSubview:labelI];
            labelI.backgroundColor = acolor;
        }
    }
    
    UILabel *labelF = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 75, 5, 20, 20)];
    labelF.text = @"F";
    labelF.backgroundColor = [UIColor lightGrayColor];//[ADBApplicationType colorForFlow:[General jsonStringToObject:clone.cloApplication]];
    labelF.textColor = [UIColor whiteColor];
    labelF.layer.cornerRadius = labelF.bounds.size.width/2;
    labelF.textAlignment = NSTextAlignmentCenter;
    labelF.clipsToBounds = YES;
    labelF.tag = 1;
    UIColor *bcolor = [General colorForClone:clone forApplication:0];
    if([General antibodyWorksForFlow:clone]){
        [cell.contentView addSubview:labelF];
        if(bcolor)labelF.backgroundColor = bcolor;
    }else{
        if(bcolor){
            [cell.contentView addSubview:labelF];
            labelF.backgroundColor = bcolor;
        }
    }
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
    cell.textLabel.text = [NSString stringWithFormat:@"#%@ %@ | Lot %@ | Label %@", conjugate.labBBTubeNumber, [General showFullAntibodyName:conjugate.lot.clone withSpecies:NO], conjugate.lot.lotNumber, string];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Date of conjugation: %@", conjugate.labDateOfLabeling];
    
    cell.tintColor = [UIColor orangeColor];
    
    [self addApplicationsBulletsToCell:cell withClone:conjugate.lot.clone];
    
    UIColor *color;
    if(conjugate.tubFinishedBy.intValue != 0){
        color = [UIColor colorWithWhite:0.9 alpha:1];
    }else if(conjugate.tubIsLow.intValue == 1  && conjugate.tubFinishedBy.intValue == 0) {
        color = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    }else{
        color = [UIColor darkGrayColor];
    }
    cell.textLabel.textColor = color;
    cell.detailTextLabel.textColor = color;
    
    return cell;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (!_lot) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:_fetchedResultsController.sections.count];
        for (Protein *protein in _fetchedResultsController.fetchedObjects) {
            if (protein.proName.length > 0) {
                if (![array containsObject:[protein.proName substringToIndex:1]]) {
                    [array addObject:[protein.proName substringToIndex:1]];
                }
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
    ADBAllInfoForAbViewController *info = [[ADBAllInfoForAbViewController alloc]initWithNibName:nil bundle:nil andConjugate:conjugate];
    [self.navigationController pushViewController:info animated:YES];
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
        
        if (conjugate.tubFinishedBy.intValue == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure" message:@"This action is not reversible" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
                [General finishedTube:conjugate withBlock:^{
                    UIAlertController *alertB = [UIAlertController alertControllerWithTitle:@"Reorder" message:@"Would you like to place an order request" preferredStyle:UIAlertControllerStyleAlert];
                    [alertB addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
                    [alertB addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
                        
                        [General reorder:conjugate.lot withAmount:1 andPurpose:@"Keep stock" withBlock:^{
                            [self.tableView reloadData];
                        }];
                        
                    }]];
                    [self presentViewController:alertB animated:YES completion:nil];
                    [self.tableView reloadData];
                }];
                
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];

    UITableViewRowAction *lowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Mark is low" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            [General lowlevelsofTube:conjugate withBlock:^{

            }];
        
        }];
    lowAction.backgroundColor = [UIColor grayColor];
    
    UITableViewRowAction *locationAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Locate" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        Place *parent = conjugate.place.parent;
        ADBGenericPlaceViewController *placeViewer = [[ADBGenericPlaceViewController alloc]initWithNibName:nil bundle:nil andPlace:parent andScope:[NSArray arrayWithObjects:conjugate.place, nil]];
        [self.navigationController pushViewController:placeViewer animated:YES];
    }];
    locationAction.backgroundColor = [UIColor blueColor];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    if (conjugate.tubFinishedBy.intValue == 0) {
        [array addObject:deleteAction];
    }
    if (conjugate.tubIsLow.intValue != 1 && conjugate.tubFinishedBy.intValue == 0) {
            [array addObject:lowAction];
    }
    if (conjugate.place) {
        [array addObject:locationAction];
    }
    return [NSArray arrayWithArray:array];
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

#pragma mark addconjugateprotocol

-(void)addConjugate:(ADBAddConjugateViewController *)controller{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self getNumberForConj:controller.conjugate];
    [self refreshTable];
}

//This needs Subclass
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[super filterContentForSearchText:searchText scope:scope];
    
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
