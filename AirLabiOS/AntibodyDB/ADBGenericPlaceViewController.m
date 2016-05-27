//
//  ADBGenericPlaceViewController.m
// AirLab
//
//  Created by Raul Catena on 5/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBGenericPlaceViewController.h"
#import "ADBLabelsForBox.h"
#import "ADBPlaceCell.h"
#import "ADBPlaceView.h"

static NSString *kCellID = @"cellID";

@interface ADBGenericPlaceViewController ()

@property (nonatomic, strong) Place *place;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *shelves;
@property (nonatomic, strong) UIView *zoomableView;

@property (nonatomic, strong) NSArray *scope;

@end

@implementation ADBGenericPlaceViewController

@synthesize place = _place;
@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPlace:(Place *)place
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.place = place;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPlace:(Place *)place andScope:(NSArray *)scopePlaces
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.place = place;
        self.scope = scopePlaces;
    }
    return self;
}

/*
 UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
 button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
 [button setTitle:@"+" forState:UIControlStateNormal];
 [button setTitleColor:[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1] forState:UIControlStateNormal];
 button.frame = CGRectMake(scroll.bounds.size.width - 40, 10 + (200*x), 40, 40);
 [General addBorderToButton:button withColor:[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1]];
 button.tag = x;[_scrollView addSubview:button];
 */

-(void)populateGridFreedge{
    
    NSSortDescriptor *colDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"plaY" ascending:YES];
    NSArray *sortedArray = [[_place.children allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:colDescriptor, nil]];
    
    int y = 0;
    for(Place *place in sortedArray){
        UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(10, 10 + (220*y), self.view.frame.size.width -  20, 210)];
        scroll.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
        scroll.backgroundColor = [UIColor whiteColor];
        scroll.tag = y;
        [self.scrollView addSubview:scroll];
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, 10 + (220*(y + 1)));
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [button setTitle:@"+" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        button.frame = CGRectMake(scroll.bounds.size.width - 40, 10 + (220*y), 40, 40);
        [button.titleLabel setFont:[UIFont systemFontOfSize:40.0f]];
        [button addTarget:self action:@selector(addItemForShelf:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = y;
        [_scrollView addSubview:button];
        
        NSSortDescriptor *rowDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"plaY" ascending:YES];
        NSArray *sortedArray2 = [[place.children allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:rowDescriptor, nil]];
        int x = 0;
        for(Place *aplace in sortedArray2){
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ADBPlaceView" owner:self options:nil];
            ADBPlaceView *placeView = [topLevelObjects objectAtIndex:0];
            placeView.place = aplace;
            //aBut.frame = CGRectMake(10 + (190*x), 10, 180, 180);
            placeView.frame = CGRectOffset(placeView.frame, 10 + placeView.bounds.size.width * x, 20);
            
            [placeView.button addTarget:self action:@selector(objectTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            
            [scroll addSubview:placeView];
            scroll.contentSize = CGSizeMake(10 + (190*(x+1)), scroll.bounds.size.height);
            x++;
        }
        y++;
    }
    for(int x = 0; x<self.place.plaSelves.intValue; x++){
        
    }
}

-(void)populateRack{
    ADBRackView *rackV = [[ADBRackView alloc]initWithFrame:self.scrollView.frame andPlace:self.place];
    self.scrollView.delegate = rackV;
    rackV.delegate = self;
    [self.scrollView addSubview:rackV];
}

-(void)populateBox{
    ADBScatolaView *boxkV = [[ADBScatolaView alloc]initWithFrame:self.scrollView.frame andPlace:self.place andScope:self.scope];
    self.scrollView.delegate = boxkV;
    boxkV.delegate = self;
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    [General addBorderToButton:but withColor:[UIColor orangeColor]];
    [but setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [but setTitle:@"Empty box" forState:UIControlStateNormal];
    but.frame = CGRectMake(20, 20, 150, 35);
    [but addTarget:self action:@selector(emptyBox) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:boxkV];
    [self.scrollView addSubview:but];
}


-(void)addScrollViewToCanvas{
    self.collectionView = nil;
    for(UIView *view in self.view.subviews)[view removeFromSuperview];
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    if(self.scrollView.frame.origin.y != 0){
        self.scrollView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    }
    self.scrollView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.scrollView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_scrollView];
    _scrollView.minimumZoomScale = 0.9;
	_scrollView.maximumZoomScale = 3;
	_scrollView.delegate = self;
}

-(void)viewSetUp{
    
    if([self.place.plaType isEqualToString:@"fridge"] || [self.place.plaType isEqualToString:@"freezer"] || [self.place.plaType isEqualToString:@"cupboard"]){
        [self addScrollViewToCanvas];
        [self populateGridFreedge];
    }else if([self.place.plaType isEqualToString:@"rack"]){
        [self addScrollViewToCanvas];
        [self populateRack];
    }else if([self.place.plaType isEqualToString:@"box"]){
        [self addScrollViewToCanvas];
        [self populateBox];
    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    }
    
    if ([self.place.plaType isEqualToString:@"box"]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actions:)];
    }
}

-(void)actions:(UIBarButtonItem *)sender{
    UIActionSheet *as = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Print", @"Send email", @"Generate PDF", @"Generate labels", @"Generate Caps labels", nil];
    [as showFromBarButtonItem:sender animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [General print:self.view fromSender:self.navigationItem.rightBarButtonItem withJobName:[NSString stringWithFormat:@"%@ Box layout", _place.plaName]];
            break;
        case 1:
            [General sendToFriend:nil withData:[General generatePDFData:self.view] withSubject:[NSString stringWithFormat:@"%@ Box layout", _place.plaName] fileName:[NSString stringWithFormat:@"%@_Box_layout.pdf", _place.plaName] fromVC:self];
            break;
        case 2:
            [General generatePDFFromScrollView:self.view onVC:self];
            break;
        case 3:{
            if([self.place.plaType isEqualToString:@"box"]){
                [ADBLabelsForBox generatePDFforBox:self.place showIn:self];
            }else{
                [General showOKAlertWithTitle:@"Labels not available" andMessage:@"For the time being only boxes labels are supported" delegate:nil];
            }
            break;
        }
        case 4:{
            if([self.place.plaType isEqualToString:@"box"]){
                [ADBLabelsForBox generatePDFforCapsBox:self.place showIn:self];
            }else{
                [General showOKAlertWithTitle:@"Labels not available" andMessage:@"For the time being only boxes labels are supported" delegate:nil];
            }
            break;
        }
            
        default:
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.place.plaName;
    
    NSError *error;
    [self.collectionView registerNib:[UINib nibWithNibName:@"ADBPlaceCell" bundle:nil] forCellWithReuseIdentifier:kCellID];
    [self.fetchedResultsController performFetch:&error];[General logError:error];
    [self viewSetUp];
    
}

-(void)addItem:(UIBarButtonItem *)sender{
    ADBAddPlaceViewController *add = [[ADBAddPlaceViewController alloc]initWithNibName:nil bundle:nil withParent:self.place withX:nil andY:nil];
    add.delegate = self;
    [self showModalOrPopoverWithViewController:add withFrame:CGRectMake(self.view.bounds.size.width, 0, 0, 0)];
}

-(void)addItemForShelf:(UIButton *)sender{
    NSSortDescriptor *colDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"plaY" ascending:YES];
    NSArray *sortedArray = [[_place.children allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:colDescriptor, nil]];
    Place *aplace = [sortedArray objectAtIndex:sender.tag];
    ADBAddPlaceViewController *add = [[ADBAddPlaceViewController alloc]initWithNibName:nil bundle:nil withParent:aplace withX:nil andY:[NSString stringWithFormat:@"%li", (long)sender.tag]];
    add.delegate = self;
    [self showModalOrPopoverWithViewController:add withFrame:sender.frame];
}

-(void)objectTapped:(UIButton *)sender{
    if([sender.superview isMemberOfClass:[ADBPlaceView class]]){
        Place *thePlace = [(ADBPlaceView *)sender.superview place];
        ADBGenericPlaceViewController *placeVC = [[ADBGenericPlaceViewController alloc]initWithNibName:@"ADBHabitacionesViewController" bundle:nil andPlace:thePlace];
        [self.navigationController pushViewController:placeVC animated:YES];
    }
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:PLACE_DB_CLASS];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"plaType" ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"parent == %@", self.place];
        
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
    if([place.plaType isEqualToString:@"cupboard"])cell.imageView.image = [UIImage imageNamed:@"shelf.jpg"];
    if([place.plaType isEqualToString:@"fridge"])cell.imageView.image = [UIImage imageNamed:@"fridge.jpg"];
    if([place.plaType isEqualToString:@"freezer"])cell.imageView.image = [UIImage imageNamed:@"freezer.jpg"];
    if([place.plaType isEqualToString:@"nitrogen"])cell.imageView.image = [UIImage imageNamed:@"nitrogen.jpg"];
    if([place.plaType isEqualToString:@"hab"])cell.imageView.image = [UIImage imageNamed:@"door.png"];
    if([place.plaType isEqualToString:@"rack"])cell.imageView.image = [UIImage imageNamed:@"rack.jpg"];
    if([place.plaType isEqualToString:@"box"])cell.imageView.image = [UIImage imageNamed:@"box.jpg"];
    if([place.plaType isEqualToString:@"cage"])cell.imageView.image = [UIImage imageNamed:@"cage.jpg"];
    if([place.plaType isEqualToString:@"other"])cell.imageView.image = [UIImage imageNamed:@"other.jpg"];
    
    return cell;
}

//Always override
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Place *place = [_fetchedResultsController objectAtIndexPath:indexPath];
    ADBGenericPlaceViewController *placeVC = [[ADBGenericPlaceViewController alloc]initWithNibName:@"ADBHabitacionesViewController" bundle:nil andPlace:place];
    [self.navigationController pushViewController:placeVC animated:YES];
}

#pragma mark AddHabDelegate

-(void)didAddPlace:(Place *)place{
    [self dismissModalOrPopover];
    [self refreshTable];
    [self viewSetUp];
    [self.collectionView reloadData];
    
}

#pragma mark rack view delegate

-(void)didTouchButtonAtX:(NSString *)x andY:(NSString *)y withFrame:(CGRect)frame{
    ADBAddPlaceViewController *placeNew = [[ADBAddPlaceViewController alloc]initWithNibName:nil bundle:nil withParent:_place withX:x andY:y];
    placeNew.delegate = self;
    [self showModalOrPopoverWithViewController:placeNew withFrame:frame];
}

-(void)didTouchButtonWithPlace:(Place *)place{
    ADBGenericPlaceViewController *placeVC = [[ADBGenericPlaceViewController alloc]initWithNibName:@"ADBHabitacionesViewController" bundle:nil andPlace:place];
    [self.navigationController pushViewController:placeVC animated:YES];
}

#pragma mark Scatola view delegate


-(void)didTouchScatolaButtonAtX:(NSString *)x andY:(NSString *)y withFrame:(CGRect)frame{
    ADBReagentPickerViewController *rea = [[ADBReagentPickerViewController alloc]initWithNibName:nil bundle:nil andTag:x.intValue];
    rea.delegate = self;
    UINavigationController *cont = [[UINavigationController alloc]initWithRootViewController:rea];
    [self showModalOrPopoverWithViewController:cont withFrame:frame];
}

-(void)emptyBox{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Empty box?"
                                          message:@"Are you sure? This action can not be undone"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelActionInAlert = [UIAlertAction
                                          actionWithTitle:@"Cancel"
                                          style:UIAlertActionStyleDefault
                                          handler:nil];
    [alertController addAction:cancelActionInAlert];
    
    UIAlertAction *deleteActionInAlert = [UIAlertAction
                                          actionWithTitle:@"Empty box?"
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction *action)
                                          {
                                              for (Place *place in _place.children) {
                                                  for (Tube *tube in place.tubes) {
                                                      tube.place = nil;
                                                      tube.tubPlaceId = nil;
                                                      [[IPExporter getInstance]updateInfoForObject:tube withBlock:nil];
                                                  }
                                              }
                                          }];
    [alertController addAction:deleteActionInAlert];
    alertController.view.tintColor = [UIColor orangeColor];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark reagent picker delegate

-(void)didPickTube:(Tube *)tube withTag:(int)tag{
    //TODO
    NSArray *array = [General searchDataBaseForClass:PLACE_DB_CLASS withDictionaryOfTerms:[NSDictionary dictionaryWithObjects:@[[NSString stringWithFormat:@"%i", tag], self.place] forKeys:@[@"plaX", @"parent"]] sortBy:@"plaX" ascending:YES inMOC:self.managedObjectContext];
    Place *place;
    if (array.count > 0) {
        place = array.lastObject;
    }else{
        place = (Place *)[General newObjectOfType:PLACE_DB_CLASS saveContext:NO];
        place.plaX = [NSString stringWithFormat:@"%i", tag];
        place.plaY = @"0";
    }
    [General doLinkForProperty:@"parent" inObject:place withReceiverKey:@"plaParentId" fromDonor:_place withPK:@"plaPlaceId"];
    [General doLinkForProperty:@"place" inObject:tube withReceiverKey:@"tubPlaceId" fromDonor:place withPK:@"plaPlaceId"];
    
    [[IPExporter getInstance]updateInfoForObject:place withBlock:nil];
    [[IPExporter getInstance]updateInfoForObject:tube withBlock:nil];
    
    [self dismissModalOrPopover];
    [General saveContextAndRoll];
    [self refreshTable];
    [self viewSetUp];
}

-(void)didTouchScatolaButtonWithTube:(id)tube andFrame:(CGRect)frame{
    ADBTubePopViewController *tubeInfo = [[ADBTubePopViewController alloc]initWithNibName:nil bundle:nil andTube:tube];
    tubeInfo.delegate = self;
    self.popover = [[UIPopoverController alloc]initWithContentViewController:tubeInfo];
    [self.popover presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)didRemoveTube{
    [self viewSetUp];
    [self dismissModalOrPopover];
    [General saveContextAndRoll];
}

@end
