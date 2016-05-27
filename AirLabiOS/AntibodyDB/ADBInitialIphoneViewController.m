//
//  ADBInitialIphoneViewController.m
// AirLab
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
#import "ADBPinboardViewController.h"

#import "ADBRotatory.h"

@interface ADBInitialIphoneViewController (){
    int currentSelection;
}

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


- (void) wheelDidChangeValue:(NSString *)newValue index:(int)index{
    currentSelection = index;
    self.sectorLabel.text = newValue;
}


-(void)setUpDialerWheel{
    self.title = @"AirLab";
    // 1 - Call super method
    
    // 3 - Set up rotary wheel
    ADBRotatory *wheel = [[ADBRotatory alloc] initWithFrame:CGRectMake(0, 0, 300, 300)
                                                andDelegate:self
                                               withSections:9
                                                     images: @[
                                                               @"share.png",
                                                               @"file.png",
                                                               @"cylinder.png",
                                                               @"document.png",
                                                               @"newspaper.png",
                                                               @"calendar.png",
                                                               @"search.png",
                                                               @"swiss.png",
                                                               @"talk.png"
                                                               
                                                               ] andTitles:
                          @[@"Inventory",
                            @"Protocols",
                            @"Experiments",
                            @"Papers",
                            @"News",
                            @"Calendar",
                            @"Search Lab",
                            @"Lab Gadgets",
                            @"Pinboard"
                            ]];
    
    wheel.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2-100);
    wheel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    // 4 - Add wheel to view
    [self.view addSubview:wheel];
    
    UIView *circle = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    circle.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    circle.layer.borderWidth = 1.0;
    circle.layer.cornerRadius = 30;
    circle.layer.borderColor = [UIColor grayColor].CGColor;
    circle.userInteractionEnabled = NO;
    circle.center = CGPointMake(wheel.bounds.size.width/2, wheel.bounds.size.height/2);
    circle.frame = CGRectOffset(circle.frame, wheel.bounds.size.width/2 - 20, 0);
    [wheel addSubview:circle];
    
    sectorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    sectorLabel.textAlignment = NSTextAlignmentCenter;
    sectorLabel.font = [UIFont systemFontOfSize:20];
    sectorLabel.textColor = [UIColor orangeColor];
    sectorLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    sectorLabel.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2-50);
    [self.view addSubview:sectorLabel];
    
    [self wheelDidChangeValue:@"Inventory" index:0];
}

-(void)tapped:(int)index{
    currentSelection = index;
    [self play];
}

-(void)setUpNormalList{
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Log off" style:UIBarButtonItemStyleDone target:self action:@selector(logoff)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Log off" style:UIBarButtonItemStyleBordered target:self action:@selector(logOff)];
    
    [[IPImporter getInstance]setAcompleter:ZGROUPPERSON_DB_CLASS withBlock:nil];
    [[IPImporter getInstance]setAcompleter:GROUP_DB_CLASS withBlock:nil];
    [[IPFetchObjects getInstance] addTagsFromServerWithBlock:nil];
    [[IPFetchObjects getInstance] addSpeciesFromServerWithBlock:nil];
    [[IPFetchObjects getInstance] addProviderssFromServerWithBlock:nil];
    [[IPFetchObjects getInstance] addCommentWallsForServerWithBlock:nil];
    [self setUpDialerWheel];
    
    
    return;
    
    [self setUpNormalList];
    
}

-(void)logOff{
    [[ADBAccountManager sharedInstance]logOff];
}

-(void)notis{
    for (UIView *view in self.view.subviews) {
        if (view.tag == 1000) {
            [view removeFromSuperview];
        }
    }
    int remaining = 0;
    for (int x = 0; x<4; x++) {
        if(x == 1)
        remaining = remaining + [[[ADBNotificationCenter alloc]init]unseenForArray:self.orders ofClass:REAGENTINSTANCE_DB_CLASS];
        if(x == 3)
        remaining = remaining + [[[ADBNotificationCenter alloc]init]unseenForArray:self.comments ofClass:COMMENTWALL_DB_CLASS];
    }
    if (remaining>0) {
        UIButton *label = [UIButton buttonWithType:UIButtonTypeCustom];
        label.frame = CGRectMake(self.view.bounds.size.width-50, self.view.bounds.size.height - 50, 30, 30);
        [label addTarget:self action:@selector(goToPinboard) forControlEvents:UIControlEventTouchUpInside];
        [label setTitle:[NSString stringWithFormat:@"%i", remaining] forState:UIControlStateNormal];
        label.backgroundColor = [UIColor orangeColor];
        label.clipsToBounds = YES;
        label.tag = 1000;
        [label setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
        label.layer.cornerRadius = label.bounds.size.width/2;
        [self.view addSubview:label];
    }
}

-(void)goToPinboard{
   ADBPinboardViewController * controller = [[ADBPinboardViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
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

-(void)play{
    ADBMasterViewController *controller;
    switch (currentSelection) {
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
            controller = [[PSNatureViewController alloc]init];
            break;
        case 5:
            controller = [[VRGViewController alloc]init];
            break;
        case 6:
            controller = [[ADBSearchLabViewController alloc]init];
            break;
        case 7:
            controller = [[ADBUtilitiesViewController alloc]init];
            break;
        case 8:
            controller = [[ADBPinboardViewController alloc]init];
            break;
        case 9:{
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
        case 8:
            controller = [[ADBPinboardViewController alloc]init];
            break;
        case 9:{
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
