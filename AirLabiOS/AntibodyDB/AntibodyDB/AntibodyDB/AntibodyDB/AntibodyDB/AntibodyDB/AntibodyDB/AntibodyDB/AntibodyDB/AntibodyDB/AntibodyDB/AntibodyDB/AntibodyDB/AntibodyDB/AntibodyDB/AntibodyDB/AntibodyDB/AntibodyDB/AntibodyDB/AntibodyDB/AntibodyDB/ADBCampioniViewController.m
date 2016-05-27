//
//  ADBCampioniViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 6/16/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBCampioniViewController.h"
#import "ADBButtonWithIndexPath.h"

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
    [General iPhoneBlock:^{
        [[IPFetchObjects getInstance]addSamplesFromServerWithBlock:^{
            [self.tableView reloadData];
        }];
    } iPadBlock:^{
        if (self.navigationController.viewControllers.count == 1) {
            [[IPFetchObjects getInstance]addSamplesFromServerWithBlock:^{
                [self.tableView reloadData];
            }];
        }
    }];
    
    self.tableView.separatorColor = [UIColor clearColor];
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
    
    //if (tableView == self.searchDisplayController.searchResultsTableView){
      //  rows = (int)[self.filtered count];
    //}else{
        if ([[_fetchedResultsController sections] count] > 0) {
            if ([[_fetchedResultsController sections] count] == 1) {
                rows = (int)_fetchedResultsController.fetchedObjects.count;
            }else{
                id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
                rows = (int)[sectionInfo numberOfObjects];
            }
            
        }
    //}
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

/*-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    NSArray *array = [sectionInfo objects];
    return [(Sample *)array.lastObject samType];
}*/


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 15)];
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    NSArray *array = [sectionInfo objects];
    label.textColor = [UIColor orangeColor];
    label.text = [@"  " stringByAppendingString:[(Sample *)array.lastObject samType]];
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
    
    Sample *sample = [_fetchedResultsController objectAtIndexPath:indexPath];
    if (sample.children.count > 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = sample.samName;
    
    [self setGrayColorInTableText:cell];
    
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
    info.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.5 alpha:1];
    [array addObject:info];
    
    return [NSArray arrayWithArray:array];
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

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [super filterContentForSearchText:searchText scope:scope];
    if (!self.previousPredicate) {
        self.previousPredicate = self.fetchedResultsController.fetchRequest.predicate;
    }
    
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
