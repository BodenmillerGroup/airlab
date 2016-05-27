//
//  ADBChooseGroupViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/21/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBChooseGroupViewController.h"

@interface ADBChooseGroupViewController ()

@property (nonatomic, strong) NSArray *groups;

@end

@implementation ADBChooseGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGroups:(NSSet *)groups
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.groups = groups.allObjects;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Choose a working group";
    [self setTheTableviewWithStyle:UITableViewStylePlain];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _groups.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"aCellIdd";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    ZGroupPerson *personGroup = [_groups objectAtIndex:indexPath.row];
    if (personGroup.gpeRole.intValue == -1) {
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.text = @"Pending to activate by group's administrator";
        cell.detailTextLabel.textColor = [UIColor blueColor];
    }else{
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.text = nil;
    }
    cell.textLabel.text = personGroup.group.grpName;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    ZGroupPerson *personGroup = [_groups objectAtIndex:indexPath.row];
    if (personGroup.gpeRole.intValue == -1) {
        return;
    }
    [self.delegate didChooseGroupPerson:personGroup];
}


@end
