//
//  ADBHabiacionesViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/15/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBHabitacionesViewController.h"
#import "ADBPlaceCell.h"
#import "ADBGenericPlaceViewController.h"

static NSString *kCellID = @"cellID";

@interface ADBHabitacionesViewController ()

@end

@implementation ADBHabitacionesViewController

@synthesize fetchedResultsController = _fetchedResultsController;

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
    self.title = @"Lab Rooms";
    
    [[IPFetchObjects getInstance]addPlacesForServerWithBlock:^{
        [_fetchedResultsController performFetch:nil];
        [self.collectionView reloadData];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    NSError *error;
    [self.collectionView registerNib:[UINib nibWithNibName:@"ADBPlaceCell" bundle:nil] forCellWithReuseIdentifier:kCellID];
    [self.fetchedResultsController performFetch:&error];[General logError:error];    
}

-(void)addItem:(UIBarButtonItem *)sender{
    ADBAddRoomViewController *add = [[ADBAddRoomViewController alloc]init];
    add.delegate = self;
    [self showModalOrPopoverWithViewController:add withFrame:self.navigationController.navigationBar.frame];
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:PLACE_DB_CLASS];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"plaType" ascending:YES]];
        NSString *query = @"hab";
        request.predicate = [NSPredicate predicateWithFormat:@"plaType == %@", query];
        
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
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    ADBPlaceCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    
    Place *place = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.label1.text = place.plaName;
    cell.label2.text = nil;
    cell.imageView.image = [UIImage imageNamed:@"door.png"];
    
    return cell;
}

//Always override
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Place *aplace = [_fetchedResultsController objectAtIndexPath:indexPath];
    ADBGenericPlaceViewController *placeVC = [[ADBGenericPlaceViewController alloc]initWithNibName:@"ADBHabitacionesViewController" bundle:nil andPlace:aplace];
    [self.navigationController pushViewController:placeVC animated:YES];
    
}

#pragma mark AddHabDelegate

-(void)didAddHabitacion:(Place *)place{
    [self dismissModalOrPopover];
    [self refreshTable];
    [self.collectionView reloadData];
}

@end
