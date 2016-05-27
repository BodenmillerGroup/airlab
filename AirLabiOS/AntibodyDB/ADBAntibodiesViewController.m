//
//  ADBAntibodiesViewController.m
// AirLab
//
//  Created by Raul Catena on 3/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAntibodiesViewController.h"
#import "Species.h"
#import "ADBAddKitViewController.h"
#import "ADBLotsViewController.h"
#import "ADBApplicationType.h"

@interface ADBAntibodiesViewController (){
    int index;
}

@property (nonatomic, strong) Protein *protein;

@end

@implementation ADBAntibodiesViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andProtein:(Protein *)protein
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.protein = protein;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Antibodies";
    if (_protein) {
        self.title = [self.title stringByAppendingFormat:@" for %@", _protein.proName];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem)];
}

-(void)showAdd{
    ADBAddAntibodyViewController *add = [[ADBAddAntibodyViewController alloc]init];
    add.delegate = self;
    [self showModalWithCancelButton:add fromVC:self withPresentationStyle:UIModalPresentationFormSheet];
}

-(void)addItem{

    [self showAdd];
}

#pragma mark openbis delegate

-(void)didGetData:(NSData *)data{
    [self dismissModalOrPopover];
}

-(void)didFailedToGetData{
    [self dismissModalOrPopover];
    [General showOKAlertWithTitle:ERROR andMessage:@"Could not connect to OpenBis, try to synchronise again later" delegate:self];
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CLASS_CLONE];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:[[IPImporter getInstance]keyOfObject:CLASS_CLONE] ascending:YES]];
        if (_protein) {
            request.predicate = [NSPredicate predicateWithFormat:@"protein == %@", _protein];
        }
        [NSFetchedResultsController deleteCacheWithName:@"antibodies"];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"antibodies"];//TODO add section name keypath with protein or epitope
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fetchedResultsController.fetchedObjects.count;
}

-(void)addApplicationsBulletsToCell:(UITableViewCell *)cell withClone:(Clone *)clone{
    for(UIView *aView in cell.contentView.subviews){
        if([aView isMemberOfClass:[UILabel class]] && aView.tag == 1)[aView removeFromSuperview];
    }
    UILabel *labelI = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 25, 5, 20, 20)];
    labelI.text = @"I";
    labelI.backgroundColor = [UIColor lightGrayColor];//[ADBApplicationType colorForImaging:[General jsonStringToObject:clone.cloApplication]];
    labelI.textColor = [UIColor whiteColor];
    labelI.layer.cornerRadius = labelI.bounds.size.width/2;
    labelI.textAlignment = NSTextAlignmentCenter;
    labelI.clipsToBounds = YES;
    labelI.tag = 1;
    UIColor *acolor = [General colorForClone:clone forApplication:1];
    if([General antibodyWorksForImaging:clone]){
        [cell.contentView addSubview:labelI];
        if(acolor)labelI.backgroundColor = acolor;
    }else{
        if(acolor){
            [cell.contentView addSubview:labelI];
            labelI.backgroundColor = acolor;
        }
    }
    
    UILabel *labelF = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 50, 5, 20, 20)];
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
    for(UIView *aView in cell.contentView.subviews){
        if([aView isMemberOfClass:[UIButton class]]){
            [aView removeFromSuperview];
        }
    }
    Clone *clone = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *reactive = @"";
    for(Species *species in [clone speciesReactive]){
        reactive = [reactive stringByAppendingString:[NSString stringWithFormat:@" %@ |", species.spcAcronym]];
    }
    if(reactive.length == 0)reactive = @"Unknown";
    else{
        if (reactive.length > 1){
            NSString *string = [reactive substringWithRange:NSMakeRange(0, reactive.length - 1)];
            reactive = string;
        }
    }

    cell.textLabel.text = [NSString stringWithFormat:@"%@", [General showFullAntibodyName:clone withSpecies:YES]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ Reactive with: %@", clone.cloBindingRegion, reactive];
    
    [self addApplicationsBulletsToCell:cell withClone:clone];
    
    [self setGrayColorInTableText:cell];
    
    return cell;
}

-(void)addApplicationsWithClone:(Clone *)clone{
    ADBDefineApplicationsViewController *define = [[ADBDefineApplicationsViewController alloc]initWithNibName:nil bundle:nil andClone:clone];
    UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:define];
    define.delegate = self;
    [self showModalOrPopoverWithViewController:navCon withFrame:CGRectMake(self.view.bounds.size.width, 0, 2, 2)];
}

-(void)doneDefiningApplicationsForClone:(Clone *)clone{
    [[IPExporter getInstance]updateInfoForObject:clone withBlock:nil];
    [self dismissModalOrPopover];
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array = [NSMutableArray array];
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [self editClone:indexPath];
    }];
    [array addObject:editAction];
    UITableViewRowAction *addLot = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Add Lot" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [self addLot:indexPath];
    }];
    addLot.backgroundColor = [UIColor orangeColor];
    [array addObject:addLot];
    
    UITableViewRowAction *defineApplicaitons = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Define applications" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [self addApplicationsWithClone:[_fetchedResultsController objectAtIndexPath:indexPath]];
    }];
    defineApplicaitons.backgroundColor = [UIColor purpleColor];
    [array addObject:defineApplicaitons];
    
    return [NSArray arrayWithArray:array];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ADBLotsViewController *lot = [[ADBLotsViewController alloc]initWithNibName:nil bundle:nil andClone:[_fetchedResultsController objectAtIndexPath:indexPath]];
    [self.navigationController pushViewController:lot animated:YES];
}

-(void)showLotAddAtIndex:(int)indexOfClone{
    ADBAddKitViewController *addLot = [[ADBAddKitViewController alloc]initWithNibName:nil bundle:nil andClone:[self.fetchedResultsController.fetchedObjects objectAtIndex:indexOfClone] andDict:nil];
    addLot.delegate = self;
    [self showModalWithCancelButton:addLot fromVC:self withPresentationStyle:UIModalPresentationFormSheet];
}

-(void)editClone:(NSIndexPath *)indexPath{
    ADBAddAntibodyViewController *edit = [[ADBAddAntibodyViewController alloc]initWithNibName:nil bundle:nil andEditableClone:[_fetchedResultsController objectAtIndexPath:indexPath] andDict:nil];
    edit.delegate = self;
    [self showModalWithCancelButton:edit fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
}

-(void)addLot:(NSIndexPath *)indexPath{
    [self showLotAddAtIndex:indexPath.row];
}

-(void)didAddLot:(Lot *)lot{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self refreshTable];
    [self dismissModalOrPopover];
}

//ERASING

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

#pragma mark -
#pragma mark Content Filtering

//This needs Subclass
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[super filterContentForSearchText:searchText scope:scope];
    
	if (searchText != nil) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cloName contains [cd] %@", searchText];
        NSPredicate *other = [NSPredicate predicateWithFormat:@"protein.proName contains [cd] %@", searchText];
        NSPredicate *other2 = [NSPredicate predicateWithFormat:@"catchedInfo contains [cd] %@", searchText];
        
		[self.fetchedResultsController.fetchRequest setPredicate:[NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, other, other2, nil]]];
		[NSFetchedResultsController deleteCacheWithName:@"allCache"];
	}else {
		[self.fetchedResultsController.fetchRequest setPredicate:self.previousPredicate];
		[NSFetchedResultsController deleteCacheWithName:@"allCache"];
	}
	[self refreshTable];
    NSLog(@"results: %lu", (unsigned long)[[self.fetchedResultsController fetchedObjects]count]);
	self.searchDisplayController.searchBar.showsCancelButton = YES;
}


#pragma mark AddAntibodyProtocol

-(void)addAntibody:(ADBAddAntibodyViewController *)controller withNewProtein:(BOOL)newProt{
    [self dismissModalOrPopover];
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self refreshTable];
}


@end
