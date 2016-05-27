//
//  ADBPartsViewController.m
// AirLab
//
//  Created by Raul Catena on 6/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBEnsayosViewController.h"
#import "ADBJournalViewController.h"
#import "ADBNewJournalViewViewController.h"

@interface ADBEnsayosViewController ()

@property (nonatomic, strong) Plan *plan;

@end

@implementation ADBEnsayosViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPlan:(Plan *)plan
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.plan = plan;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTheTableviewWithStyle:UITableViewStylePlain];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [[IPFetchObjects getInstance]addEnsayosForServerWithBlock:^{
        [self.fetchedResultsController performFetch:nil];
        [self.tableView reloadData];
    }];
}

-(void)addItem:(UIBarButtonItem *)sender{
    ADBAddEnsayoViewController *add = [[ADBAddEnsayoViewController alloc]init];
    add.delegate = self;
    [self showModalWithCancelButton:add fromVC:self withPresentationStyle:UIModalPresentationFormSheet];
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENSAYO_DB_CLASS];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
        request.predicate = [NSPredicate predicateWithFormat:@"plan == %@", _plan];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];//TODO add section name keypath with protein or epitope
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fetchedResultsController.fetchedObjects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    Ensayo *part = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = part.enyTitle;
    [self addThumbsToCell:cell withEnsayo:part];
    
    return cell;
}


-(void)addThumbsToCell:(UITableViewCell *)cell withEnsayo:(Ensayo *)ensayo{
    for (UIView *aV in cell.contentView.subviews) {
        if ([aV isMemberOfClass:[UIImageView class]]) {
            [aV removeFromSuperview];
        }
    }
    if (ensayo.parts.count == 0) {
        return;
    }
    NSMutableArray *files = [NSMutableArray arrayWithCapacity:5];
    int counter = 0;
    for (Part *part in ensayo.parts) {
        if ([part.prtType isEqualToString:@"pic"]) {
            NSData *data = [(ZFilePart *)part.fileparts.anyObject file].zetData;
            if(data)[files addObject:data];
            counter++;
        }
        NSArray *possible = @[@"png", @"jpg", @"bmp", @"gif", @"tif", @"jpeg", @"tiff"];
        if ([part.prtType isEqualToString:@"fil"]) {
            ZFilePart *linker = part.fileparts.anyObject;
            if ([possible containsObject:linker.file.filExtension]) {
                NSData *data = [linker file].zetData;
                if(data)[files addObject:data];
            }
        }
        if(counter == 5)break;
    }
    
    for (NSData *data in files) {
        UIImageView *iv = [[UIImageView alloc]initWithImage:[UIImage imageWithData:data]];
        float width = [[UIScreen mainScreen]bounds].size.width;
        float cellW = 40;
        iv.frame = CGRectMake(width - (45 * [files indexOfObject:data]), 0, cellW, cellW);
        iv.layer.cornerRadius = cellW/2;
        iv.clipsToBounds = YES;
        [cell.contentView addSubview:iv];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    Ensayo *ensayo = (Ensayo *)[_fetchedResultsController objectAtIndexPath:indexPath];
    //ADBJournalViewController *ensayos = [[ADBJournalViewController alloc]initWithNibName:nil bundle:nil andEnsayo:ensayo];
    ADBNewJournalViewViewController *ensayos = [[ADBNewJournalViewViewController alloc]initWithNibName:nil bundle:nil andEnsayo:ensayo];
    [self.navigationController pushViewController:ensayos animated:YES];
}

-(void)didAddEnsayo:(Ensayo *)ensayo{
    [General doLinkForProperty:@"plan" inObject:ensayo withReceiverKey:@"enyPlanId" fromDonor:_plan withPK:@"plnPlanId"];
    [self dismissModalOrPopover];
    [_fetchedResultsController performFetch:nil];
    [self.tableView reloadData];
}

@end
