//
//  ADBLeftInventarioViewController.m
// AirLab
//
//  Created by Raul Catena on 5/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBLeftInventarioViewController.h"
#import "ADBShopViewController.h"
#import "ADBPurchasesViewController.h"
#import "ADBAntibodyGatewayViewController.h"
#import "ADBHabitacionesViewController.h"
#import "ADBCampioniViewController.h"

//#import "ADBAllViewController.h"

@interface ADBLeftInventarioViewController ()


@end

@implementation ADBLeftInventarioViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Inventory";
    
    self.options = @[
                     @"Shop",
                     @"Reagents",
                     @"Samples",
                     @"Animals",
                     @"Storage navigator",
                     @"Antibody gateway",
                     ];
    
    self.icons = @[
                   @"shopping-cart.png",
                   @"water-bottle.png",
                   @"cylinder.png",
                   @"uptrend.png",
                   @"drawer.png",
                   @"antibodies.png",
                   ];
    [self setTheTableviewWithStyle:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.options.count;
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
            controller = [[ADBShopViewController alloc]init];
            break;
        case 1:
            controller = [[ADBPurchasesViewController alloc]init];
            break;
        case 2:
            controller = [[ADBCampioniViewController alloc]init];
            break;
        case 3:
            //controller = [[ADBAntibodiesViewController alloc]init];
            break;
        case 4:
            controller = [[ADBHabitacionesViewController alloc]init];
            break;
        case 5:
            controller = [[ADBAntibodyGatewayViewController alloc]init];
            break;
        case 6:
            //
            break;
        case 7:
            //
            break;
            
        default:
            break;
    }
    if(controller){
        if (![controller isMemberOfClass:[ADBAntibodyGatewayViewController class]]) {
            [General iPhoneBlock:^{
                [self.navigationController pushViewController:controller animated:YES];
            } iPadBlock:^{
                UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:controller];
                [self changeRightController:navCon];
            }];
            
        }else{
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


@end
