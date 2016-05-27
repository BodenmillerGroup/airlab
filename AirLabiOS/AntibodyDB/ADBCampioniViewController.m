//
//  ADBCampioniViewController.m
// AirLab
//
//  Created by Raul Catena on 6/16/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBCampioniViewController.h"
#import "ADBButtonWithIndexPath.h"
#import "ADBGenericPlaceViewController.h"

@interface ADBCampioniViewController ()

@property (nonatomic, strong) Sample *parent;

@end

@implementation ADBCampioniViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andParent:(Sample *)parent
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.parent = parent;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    self.title = @"My samples";
    [[IPFetchObjects getInstance]addFilesForGroupServerWithBlock:^{}];
    [[IPFetchObjects getInstance]addSamplesFromServerWithBlock:^{
        [[self tableView]reloadData];
    }];
    
    self.tableView.separatorColor = [UIColor clearColor];
    [self redo:NO];
}

-(void)redo:(BOOL)animated{
    NSArray *array = [General searchDataBaseForClass:SAMPLE_DB_CLASS sortBy:@"samSampleId" ascending:YES inMOC:self.managedObjectContext];
    for (Sample *com in array) {
        if ([com.samData containsString:@"\r"] || [com.samData containsString:@"\n"]) {
            com.samData = [General jsonObjectToString:[General jsonStringToObject:com.samData]];
        }
        [[IPExporter getInstance]updateInfoForObject:com withBlock:nil];
    }
}

-(void)addItem:(UIBarButtonItem *)sender{
    ADBAddSampleViewController *add = [[ADBAddSampleViewController alloc]init];
    add.delegate = self;
    [General iPhoneBlock:^{
        [self showModalWithCancelButton:add fromVC:self withPresentationStyle:UIModalPresentationFullScreen];
    } iPadBlock:^{
        self.popover = [[UIPopoverController alloc]initWithContentViewController:add];
        [self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //NSLog(@"Calculating sections");
    NSInteger count = [[_fetchedResultsController sections] count];
    
	if (count == 0) {
		count = 0;
	}
    return count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    int rows = 0;

    if ([[_fetchedResultsController sections] count] > 0) {
        if ([[_fetchedResultsController sections] count] == 1) {
            rows = (int)_fetchedResultsController.fetchedObjects.count;
        }else{
            id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
            rows = (int)[sectionInfo numberOfObjects];
        }
        
    }
    NSLog(@"Calculating rows %i", rows);
    
	return rows;
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request;
        request = [NSFetchRequest fetchRequestWithEntityName:SAMPLE_DB_CLASS];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"samType" ascending:YES]];
        if (_parent) {
            request.predicate = [NSPredicate predicateWithFormat:@"parent = %@", _parent];
        }else{
            request.predicate = [NSPredicate predicateWithFormat:@"parent = nil"];
        }
        
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"samType" cacheName:nil];//TODO add section name keypath with protein or epitope
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 15)];
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    NSArray *array = [sectionInfo objects];
    label.textColor = [UIColor orangeColor];
    NSString *append = [(Sample *)array.lastObject samType];
    if (append)
    label.text = [@"  " stringByAppendingString:append];
    return label;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    for (UIView *aview in cell.contentView.subviews) {
        if ([aview isKindOfClass:[UIButton class]]) {
            [aview removeFromSuperview];
        }
    }
    
    [self setGrayColorInTableText:cell];
    cell.detailTextLabel.text = nil;
    
    Sample *sample = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    if(sample.tubIsLow.intValue == 1){
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.tintColor = [UIColor redColor];
        cell.detailTextLabel.text = @"Low levels";
        cell.detailTextLabel.textColor = [UIColor redColor];
    }else{
        cell.detailTextLabel.textColor = [UIColor grayColor];
        if (sample.children.count > 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    if (sample.tubFinishedBy.intValue != 0) {
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = nil;
    }
    
    cell.textLabel.text = sample.samName;
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array = [NSMutableArray array];
    
    UITableViewRowAction *aliquot = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Add aliquots" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [self addAliquot:indexPath];
    }];
    aliquot.backgroundColor = [UIColor orangeColor];
    [array addObject:aliquot];
    
    UITableViewRowAction *info = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Sample data" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [self moreInfo:indexPath];
    }];
    info.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
    [array addObject:info];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Archive" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //[self deleteSample:indexPath];
        [General finishedTube:[_fetchedResultsController objectAtIndexPath:indexPath] withBlock:^{[self.tableView reloadData];}];
        
    }];
    
    UITableViewRowAction *shareAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Mark is low" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [General lowlevelsofTube:[_fetchedResultsController objectAtIndexPath:indexPath] withBlock:^{[self.tableView reloadData];}];
        //[self markLow:indexPath];
    }];
    shareAction.backgroundColor = [UIColor grayColor];
    
    UITableViewRowAction *locationAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Locate" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [self locateSample:indexPath];
    }];
    locationAction.backgroundColor = [UIColor blueColor];
    
    Sample *sample = [_fetchedResultsController objectAtIndexPath:indexPath];
    if (sample.tubFinishedBy.intValue == 0) {
        [array addObject:deleteAction];
    }
    if (sample.tubIsLow.intValue != 1 && sample.tubFinishedBy.intValue == 0) {
        [array addObject:shareAction];
    }
    if (sample.place)
        [array addObject:locationAction];
    
    return [NSArray arrayWithArray:array];
}


    
-(void)locateSample:(NSIndexPath *)indexPath{
    Sample *sample = [_fetchedResultsController objectAtIndexPath:indexPath];
    Place *parent = sample.place.parent;
    ADBGenericPlaceViewController *placeViewer = [[ADBGenericPlaceViewController alloc]initWithNibName:nil bundle:nil andPlace:parent andScope:[NSArray arrayWithObjects:sample.place, nil]];
    [self.navigationController pushViewController:placeViewer animated:YES];
}

-(void)addAliquot:(NSIndexPath *)indexPath{
    Sample *sampleBase = [_fetchedResultsController objectAtIndexPath:indexPath];
    __block ADBNewCampioniViewController *controller;
    [General iPhoneBlock:^{
        controller = [[ADBNewCampioniViewController alloc]initWithNibName:@"ADBNewCampioniViewControllerIPhone" bundle:nil andType:nil orParent:sampleBase];
    } iPadBlock:^{
        controller = [[ADBNewCampioniViewController alloc]initWithNibName:nil bundle:nil andType:nil orParent:sampleBase];
    }];
    controller.delegate = self;
    [self showModalWithCancelButton:controller fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
}

-(void)moreInfo:(NSIndexPath *)indexPath{
    Sample *sampleBase = [_fetchedResultsController objectAtIndexPath:indexPath];
    __block ADBNewCampioniViewController *controller;
    [General iPhoneBlock:^{
        controller = [[ADBNewCampioniViewController alloc]initWithNibName:@"ADBNewCampioniViewControllerIPhone" bundle:nil andType:nil orSample:sampleBase];
    } iPadBlock:^{
        controller = [[ADBNewCampioniViewController alloc]initWithNibName:nil bundle:nil andType:nil orSample:sampleBase];
    }];
    controller.delegate = self;
    [self showModalWithCancelButton:controller fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    Sample *parent = [_fetchedResultsController objectAtIndexPath:indexPath];
    if (parent.children.count > 0) {
        ADBCampioniViewController *aliquots = [[ADBCampioniViewController alloc]initWithNibName:nil bundle:nil andParent:parent];
        [self.navigationController pushViewController:aliquots animated:YES];
    }
}

-(void)willCreateSample:(NSString *)type{
    ADBNewCampioniViewController *new = [[ADBNewCampioniViewController alloc]initWithNibName:nil bundle:nil andType:type orSample:nil];
    new.delegate = self;
    [self.popover dismissPopoverAnimated:YES];
    [self showModalWithCancelButton:new fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
}

-(void)didAddSample:(Sample *)sample{
    [self dismissViewControllerAnimated:YES completion:^{[self refreshTable];}];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.fetchedResultsController = nil;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [super filterContentForSearchText:searchText scope:scope];
    
    if (searchText != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"samName contains [cd] %@", searchText];
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
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
