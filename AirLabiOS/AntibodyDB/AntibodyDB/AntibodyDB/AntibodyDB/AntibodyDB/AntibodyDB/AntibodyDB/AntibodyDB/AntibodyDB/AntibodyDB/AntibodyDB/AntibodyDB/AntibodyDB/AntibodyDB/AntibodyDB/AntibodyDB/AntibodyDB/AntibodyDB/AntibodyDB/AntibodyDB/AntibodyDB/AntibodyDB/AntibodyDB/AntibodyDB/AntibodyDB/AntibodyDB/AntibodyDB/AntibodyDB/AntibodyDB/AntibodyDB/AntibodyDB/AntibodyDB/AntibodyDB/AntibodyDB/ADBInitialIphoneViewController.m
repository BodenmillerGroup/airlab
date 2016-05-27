//
//  ADBInitialIphoneViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 6/20/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBInitialIphoneViewController.h"
#import "ADBLeftInventarioViewController.h"
#import "ADBPlansViewController.h"
#import "ADBRecetasViewController.h"
#import "VRGViewController.h"
#import "ADBSciArtViewController.h"
#import "PSNatureViewController.h"
#import "ADBSearchLabViewController.h"
#import "ADBUtilitiesViewController.h"

#import "ADBRotatory.h"

@interface ADBInitialIphoneViewController ()

@property (nonatomic, strong) UILabel *sectorLabel;

@property (nonatomic, strong) NSArray *options;
@property (nonatomic, strong) NSArray *icons;

@end

@implementation ADBInitialIphoneViewController

@synthesize sectorLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void) wheelDidChangeValue:(NSString *)newValue {
    self.sectorLabel.text = newValue;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1 - Call super method
    [super viewDidLoad];
    // 2 - Create sector label
    sectorLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 350, 120, 30)];
    sectorLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:sectorLabel];
    // 3 - Set up rotary wheel
    ADBRotatory *wheel = [[ADBRotatory alloc] initWithFrame:CGRectMake(0, 0, 200, 200)
                                                    andDelegate:self
                                                   withSections:12];
    wheel.center = CGPointMake(160, 240);
    // 4 - Add wheel to view
    [self.view addSubview:wheel];
    return;
    
    
    self.title = @"AirLab";
    self.options = @[@"Inventory", @"Protocols", @"Experiments", @"Papers", @"Calendar", @"News", @"Search Lab", @"Lab Gadgets", @"iPad version"];
    self.icons = @[
                   @"share.png",
                   @"file.png",
                   @"cylinder.png",
                   @"document.png",
                   @"calendar.png",
                   @"newspaper.png",
                   @"search.png",
                   @"swiss.png",
                   @"iPad"
                   ];
    [self setTheTableviewWithStyle:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Log off" style:UIBarButtonItemStyleBordered target:self action:@selector(logoff)];
    
    [[IPImporter getInstance]setAcompleter:ZGROUPPERSON_DB_CLASS withBlock:nil];
    [[IPImporter getInstance]setAcompleter:GROUP_DB_CLASS withBlock:nil];
    [[IPFetchObjects getInstance] addTagsFromServerWithBlock:nil];
    [[IPFetchObjects getInstance] addSpeciesFromServerWithBlock:nil];
    [[IPFetchObjects getInstance] addProviderssFromServerWithBlock:nil];
}

-(void)logoff{
    [[ADBAccountManager sharedInstance]logOff];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _options.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *stringCell = @"aCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:stringCell];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCell];
    }
    
    cell.textLabel.text = [_options objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[_icons objectAtIndex:indexPath.row]];
    [self setGrayColorInTableText:cell];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ADBMasterViewController *controller;
    switch (indexPath.row) {
        case 0:
            controller = [[ADBLeftInventarioViewController alloc]init];
            break;
        case 1:
            controller = [[ADBRecetasViewController alloc]init];
            break;
        case 2:
            controller = [[ADBPlansViewController alloc]initWithNibName:@"ADBPlansViewControllerIPhone" bundle:nil];
            break;
        case 3:
            controller = [[ADBSciArtViewController alloc]init];
            break;
        case 4:
            controller = [[VRGViewController alloc]init];
            break;
        case 5:
            controller = [[PSNatureViewController alloc]init];
            break;
        case 6:
            controller = [[ADBSearchLabViewController alloc]init];
            break;
        case 7:
            controller = [[ADBUtilitiesViewController alloc]init];
            break;
        case 8:{
            controller = [[ADBMasterViewController alloc]init];
            controller.view.frame = self.view.frame;
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.view.bounds.size.width - 30, self.view.bounds.size.height)];
            [controller.view addSubview:label];
            label.text = @"Try the iPad version to enjoy many more features. All your data will be readily available.";
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.textColor = [UIColor grayColor];
            label.textAlignment = NSTextAlignmentCenter;
        }
            
            break;
            
        default:
            break;
    }
    [self.navigationController pushViewController:controller animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}



@end
