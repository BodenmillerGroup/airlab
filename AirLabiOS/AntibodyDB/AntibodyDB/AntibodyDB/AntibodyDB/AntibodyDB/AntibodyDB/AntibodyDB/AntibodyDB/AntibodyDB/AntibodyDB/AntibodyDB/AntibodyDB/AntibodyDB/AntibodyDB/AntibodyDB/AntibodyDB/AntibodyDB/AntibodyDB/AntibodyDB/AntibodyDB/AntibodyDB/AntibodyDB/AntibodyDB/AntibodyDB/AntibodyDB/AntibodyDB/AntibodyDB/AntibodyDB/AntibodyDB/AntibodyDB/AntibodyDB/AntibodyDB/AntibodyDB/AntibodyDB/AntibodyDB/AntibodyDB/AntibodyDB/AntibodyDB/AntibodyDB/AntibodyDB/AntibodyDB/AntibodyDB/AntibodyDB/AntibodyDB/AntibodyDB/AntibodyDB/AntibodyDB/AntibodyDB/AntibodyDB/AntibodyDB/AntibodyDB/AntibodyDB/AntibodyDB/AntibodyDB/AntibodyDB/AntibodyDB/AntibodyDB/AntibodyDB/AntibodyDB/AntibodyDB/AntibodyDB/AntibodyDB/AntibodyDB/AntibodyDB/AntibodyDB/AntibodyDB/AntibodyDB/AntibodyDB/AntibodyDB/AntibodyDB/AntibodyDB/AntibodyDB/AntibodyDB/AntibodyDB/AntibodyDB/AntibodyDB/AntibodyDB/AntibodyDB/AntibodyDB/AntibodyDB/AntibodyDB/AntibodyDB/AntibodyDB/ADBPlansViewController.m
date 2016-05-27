//
//  ADBPlansViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 6/5/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBPlansViewController.h"
#import "ADBEnsayosViewController.h"
#import "ADBPlaceCell.h"

static NSString *kCellID = @"cellPlan";

@interface ADBPlansViewController ()

@end

@implementation ADBPlansViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    [General iPhoneBlock:^{
        [self setTheTableviewWithStyle:UITableViewStylePlain];
    } iPadBlock:^{
        [self.collectionView registerNib:[UINib nibWithNibName:@"ADBPlaceCell" bundle:nil] forCellWithReuseIdentifier:kCellID];
    }];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [[IPFetchObjects getInstance]addPlansForServerWithBlock:^{
        
        [self.fetchedResultsController performFetch:nil];
        
        [self.tableView reloadData];
        [self.collectionView reloadData];
        
        
    }];
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

-(void)addItem:(UIBarButtonItem *)sender{
    ADBNewPlanViewController *plan = [[ADBNewPlanViewController alloc]init];
    plan.delegate = self;
    [self showModalOrPopoverWithViewController:plan withFrame:self.navigationController.navigationBar.frame];
}

-(void)didAddPlan:(Plan *)plan{
    [self refreshTable];
    [self.collectionView reloadData];
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:PLAN_DB_CLASS];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"plnPlanId" ascending:YES]];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];//TODO add section name keypath with protein or epitope
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

#pragma mark UICollectionView
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return _fetchedResultsController.fetchedObjects.count;//self.data.count;
}

//Always override
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ADBPlaceCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:@"origins16_lg.jpg"];
    //UIImageView *iv = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"origins16_lg.jpg"]];
    //iv.bounds = cell.bounds;
    //[cell.contentView addSubview:iv];
    Plan *obj = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.label1.text = obj.plnTitle;
    cell.label2.text = nil;
    //UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, cell.bounds.size.height - 15, cell.bounds.size.width - 30, 10)];
    //lab.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    //lab.text = obj.plnTitle;
    //[cell.contentView addSubview:lab];
    
    
    /*MyCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
     
     //cell.image.image = nil;
     
     NSDictionary *images = [[self.data objectAtIndex:indexPath.row]objectForKey:@"images"];
     NSDictionary *lowRes = [images objectForKey:@"low_resolution"];
     NSString *url = [lowRes objectForKey:@"url"];
     
     if (url) {NSLog(@"URL is %@", url);
     if ([_photos valueForKey:url]) {
     cell.image.image = [_photos valueForKey:url];
     }else{
     cell.image.image = [UIImage imageNamed:PLACEHOLDER_IMAGE];
     }
     }else{
     cell.image.image = [UIImage imageNamed:PLACEHOLDER_IMAGE];
     }
     
     //cell.label.text = [NSString stringWithFormat:@"{%ld,%ld}", (long)indexPath.row, (long)indexPath.section];*/
    
    return cell;
}

//Always override
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = [_fetchedResultsController objectAtIndexPath:indexPath];
    ADBEnsayosViewController *ensayos = [[ADBEnsayosViewController alloc]initWithNibName:nil bundle:nil andPlan:plan];
    [self.navigationController pushViewController:ensayos animated:YES];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *title = @"iPhoneCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:title];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:title];
    }
    
    cell.textLabel.text = [(Plan *)[_fetchedResultsController objectAtIndexPath:indexPath] plnTitle];
    [self setGrayColorInTableText:cell];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fetchedResultsController.fetchedObjects.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    Plan *plan = [_fetchedResultsController objectAtIndexPath:indexPath];
    ADBEnsayosViewController *ensayos = [[ADBEnsayosViewController alloc]initWithNibName:nil bundle:nil andPlan:plan];
    [self.navigationController pushViewController:ensayos animated:YES];
}

@end
