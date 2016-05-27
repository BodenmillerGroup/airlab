//
//  ADBTubeInfoViewController.m
// AirLab
//
//  Created by Raul Catena on 6/2/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBTubeInfoViewController.h"

@interface ADBTubeInfoViewController ()

@property (nonatomic, strong) NSDictionary *infoDictionary;

@end

@implementation ADBTubeInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andInfo:(NSDictionary *)info
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.infoDictionary = info;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTheTableviewWithStyle:UITableViewStylePlain];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _infoDictionary.allKeys.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if (tableView == self.tableView) {
        static NSString *cellId = @"ComInfoCell";
        cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        }
        cell.textLabel.text = [self.infoDictionary.allKeys objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [self.infoDictionary.allValues objectAtIndex:indexPath.row];
    }
    [self setGrayColorInTableText:cell];
    return cell;
}

@end
