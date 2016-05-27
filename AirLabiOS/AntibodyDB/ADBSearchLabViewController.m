//
//  ADBSearchLabViewController.m
//  AirLab
//
//  Created by Raul Catena on 10/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBSearchLabViewController.h"

@interface ADBSearchLabViewController ()

@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) NSArray *arrayOfEntities;

@end

@implementation ADBSearchLabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Search lab";
    self.arrayOfEntities = @[COMERTIALREAGENT_DB_CLASS, CLONE_DB_CLASS, ENSAYO_DB_CLASS, PART_DB_CLASS, SAMPLE_DB_CLASS, LABELEDANTIBODY_DB_CLASS, PLAN_DB_CLASS, PANEL_DB_CLASS, SCIENTIFICARTICLE_DB_CLASS];
    [_search becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)update{
    [self executeSearch];
}

-(void)executeSearch{
    [_results removeAllObjects];
    if (!_results) {
        _results = [NSMutableArray arrayWithCapacity:100];
    }
    NSDictionary *dictOfKeys = @{
                             COMERTIALREAGENT_DB_CLASS:@[@"comName"],
                             CLONE_DB_CLASS:@[@"cloName", @"protein.proName"],
                             ENSAYO_DB_CLASS:@[@"enyTitle", @"enyHypothesis", @"enyPurpose"],
                             PART_DB_CLASS:@[@"prtText"],
                             SAMPLE_DB_CLASS: @[@"samName"],
                             LABELEDANTIBODY_DB_CLASS:@[@"lot.lotNumber"],
                             PLAN_DB_CLASS:@[@"plnTitle"],
                             PANEL_DB_CLASS:@[@"panName"],
                             SCIENTIFICARTICLE_DB_CLASS:@[@"sciAbstract", @"sciTitle", @"sciAuthors"]
                             };
    
    int x = 0;
    for (NSString *entity in _arrayOfEntities) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:100];
        NSString *primaryKey = [[IPImporter getInstance]keyOfObject:entity];
        
        NSArray *theKeys = [dictOfKeys valueForKey:entity];
        for (NSString *key in theKeys) {
            NSArray *arrayForTerm  = [General searchDataBaseForClass:entity withTermContained:_search.text inField:key sortBy:primaryKey ascending:YES inMOC:self.managedObjectContext];
            
            if (arrayForTerm.count > 0) {
                [array addObjectsFromArray:arrayForTerm];
            }
        }
        
        if (array.count > 0) {
            [_results addObject:array];
        }
        
        x++;
    }
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _results.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [(NSArray *)[_results objectAtIndex:section]count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return NSStringFromClass([[[_results objectAtIndex:section]firstObject]class]);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *string = @"SearchCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:string];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:string];
    }
    NSArray *array = [_results objectAtIndex:indexPath.section];
    Object *object = [array objectAtIndex:indexPath.row];
    
    cell.detailTextLabel.text = nil;
    
    NSString *entity = NSStringFromClass([object class]);
    if ([entity isEqualToString:COMERTIALREAGENT_DB_CLASS]) {
        cell.textLabel.text = [object valueForKey:@"comName"];
    }
    if ([entity isEqualToString:CLONE_DB_CLASS]) {        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [object valueForKey:@"cloName"], [(Clone *)object protein].proName];
        //VERY INTERESTING
        //cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [object valueForKey:@"cloName"], [linker valueForKeyPath:@"speciesProtein.protein.proName"]];
    }
    if ([entity isEqualToString:ENSAYO_DB_CLASS]) {
        cell.textLabel.text = [object valueForKey:@"enyTitle"];
    }
    if ([entity isEqualToString:PART_DB_CLASS]) {
        cell.textLabel.text = [object valueForKeyPath:@"ensayo.enyTitle"];
        cell.detailTextLabel.text = [object valueForKey:@"prtText"];
    }
    if ([entity isEqualToString:SAMPLE_DB_CLASS]) {
        cell.textLabel.text = [object valueForKey:@"samName"];
    }
    if ([entity isEqualToString:LABELEDANTIBODY_DB_CLASS]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ Clone %@", [object valueForKeyPath:@"lot.clone.protein.proName"], [object valueForKeyPath:@"lot.clone.cloName"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Conjugate to %@%@", [object valueForKeyPath:@"tag.tagName"], [object valueForKeyPath:@"tag.tagMW"]];
    }
    if ([entity isEqualToString:PLAN_DB_CLASS]) {
        cell.textLabel.text = [object valueForKeyPath:@"plnTitle"];
    }
    if ([entity isEqualToString:PANEL_DB_CLASS]) {
        cell.textLabel.text = [object valueForKeyPath:@"panName"];
    }
    if ([entity isEqualToString:SCIENTIFICARTICLE_DB_CLASS]) {
        cell.textLabel.text = [object valueForKeyPath:@"sciTitle"];
        cell.detailTextLabel.text = [object valueForKeyPath:@"sciAuthors"];
    }
    
    
    return cell;
}

@end
