//
//  ADBAntibodyGatewayViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/16/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAntibodyGatewayViewController.h"
#import "ADBProteinsViewController.h"
#import "ADBAntibodiesViewController.h"
#import "ADBConjugatesViewController.h"
#import "ADBPanelsViewController.h"
//#import "ADBOpenBisSignInViewController.h"
#import "ADBConjugatesOrderBBViewController.h"

@interface ADBAntibodyGatewayViewController ()

@end

@implementation ADBAntibodyGatewayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)loadGatewayComponents{
    [[IPFetchObjects getInstance]addProteinsFromServerWithBlock:nil];
    [[IPFetchObjects getInstance]addSpeciesProteinFromServerWithBlock:nil];
    [[IPFetchObjects getInstance]addCloneSpeciesProteinFromServerWithBlock:nil];
    [[IPFetchObjects getInstance]addClonesFromServerWithBlock:nil];
    [[IPFetchObjects getInstance]addConjugatesFromServerWithBlock:nil];
    [[IPFetchObjects getInstance]addLostFromServerWithBlock:nil];
    [[IPFetchObjects getInstance]addPanelsFromServerWithBlock:nil];
    //[[IPFetchObjects getInstance]addPanelLabeledAntibodiesFromServerWithBlock:nil];//Moved to panels to speed up
}

-(void)openProtTab{
    ADBProteinsViewController *prots = [[ADBProteinsViewController alloc]init];
    UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:prots];
    [self changeRightController:navCon];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadGatewayComponents];
    
    self.title = @"Antibody Gateway";
    
    self.options = @[
                     @"Proteins",
                     @"Antibodies",
                     @"Antibody conjugates",
                     @"Conjugates, by tube #",
                     @"Antibody panels",
                     ];
    
    self.icons = @[
                   @"share.png",
                   @"antibodies.png",
                   @"antibodieLab.png",
                   @"antibodieLab.png",
                   @"abacus.png",
                   ];
    [self setTheTableviewWithStyle:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [General iPhoneBlock:nil iPadBlock:^{[self openProtTab];}];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshOpenBis)];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = [self.options objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[self.icons objectAtIndex:indexPath.row]];
    [self setGrayColorInTableText:cell];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id controller = nil;
    switch (indexPath.row) {
        case 0:
            controller = [[ADBProteinsViewController alloc]init];
            break;
        case 1:
            controller = [[ADBAntibodiesViewController alloc]init];
            break;
        case 2:
            controller = [[ADBConjugatesViewController alloc]init];
            break;
        case 3:
            controller = [[ADBConjugatesOrderBBViewController alloc]init];
            break;
        case 4:
            controller = [[ADBPanelsViewController alloc]initWithNibName:@"ADBPanelsViewController" bundle:nil];
            break;
            
        default:
            break;
    }
    if (controller) {
        [General iPhoneBlock:^{
            [self.navigationController pushViewController:controller animated:YES];
        } iPadBlock:^{
            UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:controller];
            [self changeRightController:navCon];
        }];
    }
}


@end
