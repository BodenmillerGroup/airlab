//
//  ADBDetailsREIViewController.m
//  AirLab
//
//  Created by Raul Catena on 10/24/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBDetailsREIViewController.h"

@interface ADBDetailsREIViewController ()

@property (nonatomic, strong) ReagentInstance *rei;

@end

@implementation ADBDetailsREIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.noAutorefresh = YES;
    [self setTheTableviewWithStyle:UITableViewStylePlain];
    [[IPImporter getInstance]setAcompleter:ZGROUPPERSON_DB_CLASS withBlock:nil];
    //[[IPImporter getInstance]tryPairs];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andRei:(ReagentInstance *)rei{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.rei = rei;
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *details = @"details";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:details];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:details];
    }
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"Requested by: %@ %@", _rei.requester.person.perName?_rei.requester.person.perName:@"", _rei.requester.person.perLastname?_rei.requester.person.perLastname:@""];
            cell.detailTextLabel.text = _rei.reiRequestedAt;
        }
            break;
        case 1:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"Approved by: %@ %@", _rei.approver.person.perName?_rei.approver.person.perName:@"", _rei.approver.person.perLastname?_rei.approver.person.perLastname:@""];
            cell.detailTextLabel.text = nil;
        }
            break;
        case 2:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"Ordered by: %@ %@", _rei.orderer.person.perName?_rei.orderer.person.perName:@"", _rei.orderer.person.perLastname?_rei.orderer.person.perLastname:@""];
            cell.detailTextLabel.text = _rei.reiOrderedAt;
        }
            break;
        case 3:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"Received by: %@ %@", _rei.receiver.person.perName?_rei.receiver.person.perName:@"", _rei.receiver.person.perLastname?_rei.receiver.person.perLastname:@""];
            cell.detailTextLabel.text = _rei.reiReceivedAt;
        }
            break;
            
        case 4:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"Finished by: %@ %@", _rei.finisher.person.perName?_rei.finisher.person.perName:@"", _rei.finisher.person.perLastname?_rei.finisher.person.perLastname:@""];
            cell.detailTextLabel.text = _rei.tubFinishedAt;
        }
            break;
        default:
            break;
    }
    
    [self setGrayColorInTableText:cell];
    
    return cell;
}

@end
