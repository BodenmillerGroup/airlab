//
//  ADBApplicationsHelperViewViewController.m
//  AirLab
//
//  Created by Raul Catena on 3/4/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import "ADBApplicationsHelperViewViewController.h"

@interface ADBApplicationsHelperViewViewController ()

@property (nonatomic, strong) NSArray *clones;

@end

@implementation ADBApplicationsHelperViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _clones = [General searchDataBaseForClass:CLONE_DB_CLASS sortBy:@"cloCloneId" ascending:YES inMOC:self.managedObjectContext];
    [self setTheTableviewWithStyle:UITableViewStyleGrouped];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _clones.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[General jsonStringToObject:[[(Lot *)[[(Clone *)[_clones objectAtIndex:section]lots]anyObject]comertialReagent]catchedInfo]]allKeys]count]+1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    Clone *clone = (Clone *)[_clones objectAtIndex:section];
    return [NSString stringWithFormat:@"%@%@ %@", clone.cloIsPhospho.intValue == 1?@"p":@"", clone.protein.proName, clone.cloName];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"CloneCell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    for (UIView *sub in cell.subviews) {
        if ([sub isMemberOfClass:[UIButton class]]) {
            [sub removeFromSuperview];
        }
    }
    
    Clone *clone = [_clones objectAtIndex:indexPath.section];
    if (indexPath.row != 0) {
        NSDictionary *dict = [General jsonStringToObject:[[(Lot *)clone.lots.anyObject comertialReagent]catchedInfo]];
        cell.textLabel.text = [dict.allKeys objectAtIndex:indexPath.row-1];
        cell.detailTextLabel.text = [dict.allValues objectAtIndex:indexPath.row-1];
    }else{
        
        NSMutableDictionary *notes = [[General jsonStringToObject:clone.cloApplication]mutableCopy];
        
        NSArray *titles = @[@"sMC", @"iMC", @"FC", @"IF", @"IHC"];
        for (int i = 0;i<5;i++) {
            UIButton *butt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            butt.frame = CGRectMake(i*60 + 180, 0, 58, 40);
            [butt setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
            butt.tag = indexPath.section * 1000 + i;
            [butt addTarget:self action:@selector(appTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            if ([[notes valueForKey:[NSString stringWithFormat:@"%i", i]]boolValue] == YES) {
                [butt setSelected:YES];
            }
            [cell addSubview:butt];
        }
        cell.textLabel.text = @"Define applications";
        cell.detailTextLabel.text = nil;
    }
    
    
    return cell;
}

-(void)appTapped:(UIButton *)sender{
    [sender setSelected:!sender.selected];
    Clone *clone = [_clones objectAtIndex:sender.tag/1000];
    NSMutableDictionary *notes = [[General jsonStringToObject:clone.cloApplication]mutableCopy];
    if(!notes) notes = [NSMutableDictionary dictionary];
    int app = sender.tag % 1000;
    NSLog(@"For app %i", app);
    if ([notes valueForKey:[NSString stringWithFormat:@"%i", app]]) {
        if ([[notes valueForKey:[NSString stringWithFormat:@"%i", app]]boolValue] == YES) {
            [notes setValue:nil forKey:[NSString stringWithFormat:@"%i", app]];
        }else{
            [notes setValue:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%i", app]];
        }
    }else{
        [notes setValue:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%i", app]];
    }
    clone.cloApplication = [General jsonObjectToString:notes];
    [[IPExporter getInstance]updateInfoForObject:clone withBlock:nil];
    [self.tableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        ADBDefineApplicationsViewController *define = [[ADBDefineApplicationsViewController alloc]initWithNibName:nil bundle:nil andClone:[_clones objectAtIndex:indexPath.section]];
        define.delegate = self;
        UINavigationController *navcon = [[UINavigationController alloc]initWithRootViewController:define];
        [self showModalOrPopoverWithViewController:navcon withFrame:CGRectMake(0, 0, 10, 10)];
    }else{
        [General showOKAlertWithTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text andMessage:[tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text delegate:self];
    }
}

-(void)doneDefiningApplicationsForClone:(Clone *)clone{
    [[IPExporter getInstance]updateInfoForObject:clone withBlock:nil];
    [self dismissModalOrPopover];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
