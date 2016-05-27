//
//  ADBReagentPickerViewController.m
// AirLab
//
//  Created by Raul Catena on 5/20/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBReagentPickerViewController.h"
#import "ADBTubeInfoViewController.h"

@interface ADBReagentPickerViewController (){
    int tagOfNew;
}

@property (nonatomic, strong) NSMutableArray *source;

@end

@implementation ADBReagentPickerViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTag:(int)tag
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        tagOfNew = tag;
    }
    return self;
}

- (IBAction)typeChanged:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == 0) {
        [self getSourcesRIs:YES conjugates:NO andSamples:NO];
    }else if(sender.selectedSegmentIndex == 1){
        [self getSourcesRIs:NO conjugates:YES andSamples:NO];
    }else{
        [self getSourcesRIs:NO conjugates:NO andSamples:YES];
    }
}

-(void)getSourcesRIs:(BOOL)risBool conjugates:(BOOL)conBool andSamples:(BOOL)samBool{
    
    self.source = [NSMutableArray array];
    if (risBool) {
        NSArray *array = [General searchDataBaseForClass:REAGENTINSTANCE_DB_CLASS sortBy:@"reiReagentInstanceId" ascending:YES inMOC:self.managedObjectContext];
        self.source = [NSMutableArray arrayWithArray:array];
    }
    
    if (conBool) {
        NSArray *arrayB = [General searchDataBaseForClass:LABELEDANTIBODY_DB_CLASS sortBy:@"labBBTubeNumber" ascending:YES inMOC:self.managedObjectContext];
        
        
        NSSortDescriptor *aSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"labBBTubeNumber" ascending:YES comparator:^(id obj1, id obj2) {
            
            if ([obj1 integerValue] > [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if ([obj1 integerValue] < [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        NSArray *ordered = [NSMutableArray arrayWithArray:[arrayB sortedArrayUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]]];
        
        [self.source addObjectsFromArray:ordered];
    }
    
    if (samBool) {
        NSArray *arrayC = [General searchDataBaseForClass:SAMPLE_DB_CLASS sortBy:@"zetAPI" ascending:YES inMOC:self.managedObjectContext];
        [self.source addObjectsFromArray:arrayC];
    }
    
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getSourcesRIs:YES conjugates:YES andSamples:YES];
    [self.tubeTypeSelector setSelectedSegmentIndex:UISegmentedControlNoSegment];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.searchDisplayController.isActive)return self.filtered.count;
    return _source.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"TubePickerCell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    id tube;
    if (self.searchDisplayController.isActive){
        tube = [self.filtered objectAtIndex:indexPath.row];
    }else{
        tube = [self.source objectAtIndex:indexPath.row];
    }
    
    if([tube isMemberOfClass:[ReagentInstance class]]){
        cell.textLabel.text = [[(ReagentInstance *)tube comertialReagent]comName];
        cell.imageView.image = [UIImage imageNamed:@"water-bottle.png"];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }else if([tube isMemberOfClass:[LabeledAntibody class]]){
        Clone *clone = [[(LabeledAntibody *)tube lot]clone];
        cell.textLabel.text = [NSString stringWithFormat:@"(%@) %@ %@", [(LabeledAntibody *)tube labBBTubeNumber], clone.cloName, clone.protein.proName];
        cell.imageView.image = [UIImage imageNamed:@"antibodieLab.png"];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else if([tube isMemberOfClass:[Sample class]]){
        cell.textLabel.text = [(Sample *)tube samName];
        cell.imageView.image = [UIImage imageNamed:@"cylinder.png"];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    Tube *tub = (Tube *)tube;
    if (!tub.place) {
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }else{
        cell.textLabel.textColor = [UIColor lightGrayColor];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    Tube *tube;
    if (self.searchDisplayController.isActive){
        tube = [self.filtered objectAtIndex:indexPath.row];
    }else{
        tube = [self.source objectAtIndex:indexPath.row];
    }
    [self.delegate didPickTube:tube withTag:tagOfNew];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    Tube *tube;
    if (self.searchDisplayController.isActive){
        tube = [self.filtered objectAtIndex:indexPath.row];
    }else{
        tube = [self.source objectAtIndex:indexPath.row];
    }
    if ([tube isMemberOfClass:[ReagentInstance class]]) {
        ComertialReagent *com = [(ReagentInstance *)tube comertialReagent];
        NSData *data = [com.catchedInfo dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            NSError *error;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            ADBTubeInfoViewController *info = [[ADBTubeInfoViewController alloc]initWithNibName:nil bundle:nil andInfo:dict];
            [self.navigationController pushViewController:info animated:YES];
        }
    }
    
}

#pragma mark -
#pragma mark Content Filtering

//This needs Subclass
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[super filterContentForSearchText:searchText scope:scope];

    if(!self.filtered)self.filtered = [NSMutableArray arrayWithCapacity:_source.count];
    [self.filtered removeAllObjects];
    
	for (id tube in _source) {
        NSString *titleTube = [General titleForTube:tube];
        if ([titleTube rangeOfString:searchText].location != NSNotFound) {
            [self.filtered addObject:tube];
        }
    }
    
	[self.tableView reloadData];
    NSLog(@"results: %lu", (unsigned long)[[self.fetchedResultsController fetchedObjects]count]);
	self.searchDisplayController.searchBar.showsCancelButton = YES;
}


@end
