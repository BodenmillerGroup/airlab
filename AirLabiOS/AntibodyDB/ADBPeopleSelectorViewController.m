//
//  ADBPeopleSelectorViewController.m
//  AirLab
//
//  Created by Raul Catena on 6/30/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import "ADBPeopleSelectorViewController.h"

@interface ADBPeopleSelectorViewController ()
@property (nonatomic, strong) NSArray *everyBody;
@property (nonatomic, strong) NSMutableArray *selected;
@end

@implementation ADBPeopleSelectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.everyBody = [[[[ADBAccountManager sharedInstance]currentGroupPerson]group]groupPersons].allObjects;
    [self setTheTableviewWithStyle:UITableViewStylePlain];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[[ADBAccountManager sharedInstance]currentGroupPerson]group]groupPersons].count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *personCell = @"PersonCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:personCell];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:personCell];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    ZGroupPerson *person  = [_everyBody objectAtIndex:indexPath.row];
    if (!person.person.perName) {
        cell.textLabel.text = person.person.perEmail;
        cell.detailTextLabel.text = nil;
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", person.person.perName, person.person.perLastname];
        cell.detailTextLabel.text = person.person.perEmail;
    }
    if (person == [[ADBAccountManager sharedInstance]currentGroupPerson]) {
        cell.textLabel.textColor = [UIColor blueColor];
        cell.textLabel.text = [cell.textLabel.text stringByAppendingString:@" (Me)"];
    }else{
        [self setGrayColorInTableText:cell];
    }
    if ([_selected containsObject:person]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!_selected)self.selected = [NSMutableArray arrayWithCapacity:_everyBody.count];
    if (_unique == YES) {
        if([_selected containsObject:[_everyBody objectAtIndex:indexPath.row]]){
            [_selected removeAllObjects];
        }else{
            [_selected removeAllObjects];
            [_selected addObject:[_everyBody objectAtIndex:indexPath.row]];
        }
        
    }else{
        if([_selected containsObject:[_everyBody objectAtIndex:indexPath.row]])[_selected removeObject:[_everyBody objectAtIndex:indexPath.row]];
        else [_selected addObject:[_everyBody objectAtIndex:indexPath.row]];
    }
    [tableView reloadData];
}

-(void)done{
    [self.delegate didSelectPeople:[NSArray arrayWithArray:_selected]];
}

@end
