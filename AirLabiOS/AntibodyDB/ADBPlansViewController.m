//
//  ADBPlansViewController.m
// AirLab
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
    self.title = @"My projects";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [[IPFetchObjects getInstance]addPlansForServerWithBlock:^{
        
        [self.fetchedResultsController performFetch:nil];
        
        [self.tableView reloadData];
        [self.collectionView reloadData];
        
        
    }];
    
    [General iPhoneBlock:^{
        [self setTheTableviewWithStyle:UITableViewStylePlain];
    } iPadBlock:^{
        [self.collectionView registerNib:[UINib nibWithNibName:@"ADBPlaceCell" bundle:nil] forCellWithReuseIdentifier:kCellID];
    }];

    
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

-(void)addItem:(UIBarButtonItem *)sender{
    ADBNewPlanViewController *plan = [[ADBNewPlanViewController alloc]init];
    plan.delegate = self;
    [self showModalWithCancelButton:plan fromVC:self withPresentationStyle:UIModalPresentationFormSheet];
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

-(UIImage *)chooseImage:(Plan *)plan{
    for (Ensayo *ensayo in plan.ensayos) {
        for (Part *part in ensayo.parts) {
            NSMutableSet *set = [NSMutableSet set];
            if ([part.prtType isEqualToString:@"pic"]) {
                NSData *data = [[part.fileparts.anyObject file] zetData];
                if(data)[set addObject:data];
            }
            NSArray *possible = @[@"png", @"jpg", @"bmp", @"gif", @"tif", @"jpeg", @"tiff"];
            if ([part.prtType isEqualToString:@"fil"]) {
                ZFilePart *linker = part.fileparts.anyObject;
                if ([possible containsObject:linker.file.filExtension]) {
                    NSData *data = [[linker file] zetData];
                    if(data)[set addObject:data];
                }
            }
            NSData *data = set.allObjects.lastObject;
            if(data)return [UIImage imageWithData:data];
        }
    }
    return nil;
}

//Always override
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ADBPlaceCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:@"origins16_lg.jpg"];
    
    Plan *obj = [_fetchedResultsController objectAtIndexPath:indexPath];
    UIImage *image = [self chooseImage:obj];
    if(image)cell.imageView.image = image;
    cell.label1.text = obj.plnTitle;
    cell.label2.text = nil;
    cell.imageView.layer.cornerRadius = cell.imageView.bounds.size.width/2;
    cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.imageView.layer.borderWidth = 1.0f;
    [cell.imageView setClipsToBounds:YES];
    
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
    cell.imageView.image = [self chooseImage:[_fetchedResultsController objectAtIndexPath:indexPath]];
    [General constraintIVofTVC:cell withSize:CGSizeMake(80, 80)];
    
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
