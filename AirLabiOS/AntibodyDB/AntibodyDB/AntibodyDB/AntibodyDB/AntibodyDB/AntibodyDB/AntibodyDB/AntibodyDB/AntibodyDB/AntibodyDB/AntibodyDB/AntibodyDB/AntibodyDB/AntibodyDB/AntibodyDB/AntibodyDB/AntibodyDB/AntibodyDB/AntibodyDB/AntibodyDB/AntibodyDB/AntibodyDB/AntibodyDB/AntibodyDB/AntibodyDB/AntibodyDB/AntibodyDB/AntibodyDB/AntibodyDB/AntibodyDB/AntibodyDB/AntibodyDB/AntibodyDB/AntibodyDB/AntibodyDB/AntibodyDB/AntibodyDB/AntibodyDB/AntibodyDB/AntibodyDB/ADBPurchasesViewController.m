//
//  ADBPurchasesViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/11/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBPurchasesViewController.h"
#import "ADBAlmacenCellTableViewCell.h"
#import "ADBRequestedCell.h"
#import "ADBOrderedCell.h"
#import "ADBAddPurchaseViewController.h"
#import "ADBInfoCommertialViewController.h"

@interface ADBPurchasesViewController ()

@property (nonatomic, strong) ComertialReagent *activeReagent;
@property (nonatomic, strong) ADBMasterViewController *browser;

@end

@implementation ADBPurchasesViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize segment = _segment;

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
    self.title = @"Reagents Inventory";
    
    [[IPFetchObjects getInstance]addReagentInstancesFromServerWithBlock:^{[self.fetchedResultsController performFetch:nil];[self.tableView reloadData];}];
    [[IPFetchObjects getInstance]addComertialReagentsFromServerWithBlock:^{[self.fetchedResultsController performFetch:nil];[self.tableView reloadData];}];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem)];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self refreshTable];
}

-(void)addItem{
    ADBAddPurchaseViewController *purchase = [[ADBAddPurchaseViewController alloc]init];
    purchase.title = @"Choose an option";
    [self showModalWithCancelButton:purchase fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
}

-(void)segementChanged:(UISegmentedControl *)sender{
    if (sender.selectedSegmentIndex > 0) {
        self.noAutorefresh = YES;
    }else{
        self.noAutorefresh = NO;
    }
    
    self.fetchedResultsController = nil;
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    if(error)[General logError:error];
    [self.tableView reloadData];
    self.previousPredicate = nil;
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request;
        
        NSMutableArray *preds = [NSMutableArray arrayWithObject:[NSPredicate predicateWithFormat:@"deleted == nil"]];
        
        if(_segment.selectedSegmentIndex == 0) {
            request = [NSFetchRequest fetchRequestWithEntityName:COMERTIALREAGENT_DB_CLASS];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
        }else{
            request = [NSFetchRequest fetchRequestWithEntityName:COMERTIALREAGENT_DB_CLASS];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
            
                NSString *var;
                int index = (int)_segment.selectedSegmentIndex;
                switch (index) {
                    case 1:
                        var = @"requested";
                        break;
                    case 2:
                        var = @"approved";
                        break;
                    case 3:
                        var = @"ordered";
                        break;
                        
                    default:
                        break;
                }
                //request.predicate = [NSPredicate predicateWithFormat:@"reiStatus == %@", var];
            [preds addObject:[NSPredicate predicateWithFormat:@"ANY reagentInstances.reiStatus == %@", var]];
        }
        request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithArray:preds]];
        
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];//TODO add section name keypath with protein or epitope
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fetchedResultsController.fetchedObjects.count;
}

-(void)addBulletsToCell:(ADBAlmacenCellTableViewCell *)cell withCom:(ComertialReagent *)reagent{
    int stock = 0;
    int requested = 0;
    int ordered = 0;
    int arrived = 0;
    for (ReagentInstance *instance in reagent.reagentInstances) {
        if ([instance.reiStatus isEqualToString:@"requested"] || [instance.reiStatus isEqualToString:@"approved"]) {
            requested++;
        }
        if ([instance.reiStatus isEqualToString:@"stock"]) {
            stock++;
        }
        if ([instance.reiStatus isEqualToString:@"ordered"]) {
            ordered++;
        }
        if ([instance.reiStatus isEqualToString:@"arrived"]) {
            arrived++;
        }
        if (!instance.reiStatus) {
            stock++;
        }
    }
    cell.requestedNum.text = [NSString stringWithFormat:@"%i", requested];
    cell.stockNum.text = [NSString stringWithFormat:@"%i", stock];
    cell.orderedNum.text = [NSString stringWithFormat:@"%i", ordered];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int)_segment.selectedSegmentIndex;
    UITableViewCell *cell;
    
    //General inventory
    if (index == 0) {
        static NSString *cellId = @"AlmaCell";
        
        ADBAlmacenCellTableViewCell *acell = (ADBAlmacenCellTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
        if (!acell) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:[General isIphone]?@"ADBAlmacenCellTableViewCellIPhone":@"ADBAlmacenCellTableViewCell" owner:self options:nil];
            
            acell = [topLevelObjects objectAtIndex:0];
        }
        ComertialReagent *comertialReagent = [_fetchedResultsController objectAtIndexPath:indexPath];
        acell.nameLabel.text = comertialReagent.comName;
        acell.referenceLabel.text = comertialReagent.comReference;
        acell.providerLabel.text = comertialReagent.provider.proName;
        [self addBulletsToCell:acell withCom:comertialReagent];
        cell = acell;
    }
    //Requested
    if (index == 1) {
        static NSString *cellId = @"ReqCell";
        
        ADBRequestedCell *acell = (ADBRequestedCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
        if (!acell) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:[General isIphone]?@"ADBRequestedCellIPhone":@"ADBRequestedCell" owner:self options:nil];
            acell = [topLevelObjects objectAtIndex:0];
        }
        ComertialReagent *comertialReagent = [_fetchedResultsController objectAtIndexPath:indexPath];
        acell.nameLabel.text = comertialReagent.comName;
        acell.referenceLabel.text = comertialReagent.comReference;
        acell.providerLabel.text = comertialReagent.provider.proName;
        acell.reagent = comertialReagent;
        acell.delegate = self;
        [self addBulletsToCell:acell withCom:comertialReagent];
        cell = acell;
    }
    
    //Ordered
    if (index == 2) {
        static NSString *cellId = @"ApprovedCell";
        
        ADBOrderedCell *acell = (ADBOrderedCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
        if (!acell) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ADBApprovedCellTableViewCell" owner:self options:nil];
            acell = [topLevelObjects objectAtIndex:0];
        }
        ComertialReagent *comertialReagent = [_fetchedResultsController objectAtIndexPath:indexPath];
        acell.nameLabel.text = comertialReagent.comName;
        acell.referenceLabel.text = comertialReagent.comReference;
        acell.providerLabel.text = comertialReagent.provider.proName;
        acell.reagent = comertialReagent;
        acell.delegate = self;
        [self addBulletsToCell:acell withCom:comertialReagent];
        cell = acell;
    }
    
    //Ordered
    if (index == 3) {
        static NSString *cellId = @"OrdCell";
        
        ADBOrderedCell *acell = (ADBOrderedCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
        if (!acell) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ADBOrderedCell" owner:self options:nil];
            acell = [topLevelObjects objectAtIndex:0];
        }
        ComertialReagent *comertialReagent = [_fetchedResultsController objectAtIndexPath:indexPath];
        acell.nameLabel.text = comertialReagent.comName;
        acell.referenceLabel.text = comertialReagent.comReference;
        acell.providerLabel.text = comertialReagent.provider.proName;
        acell.reagent = comertialReagent;
        acell.delegate = self;
        [self addBulletsToCell:acell withCom:comertialReagent];
        cell = acell;
    }
    
    
    //Arrived
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    ComertialReagent *reagent = [_fetchedResultsController objectAtIndexPath:indexPath];
    ADBInfoCommertialViewController *info = [[ADBInfoCommertialViewController alloc]initWithNibName:nil bundle:nil andReagent:reagent];
    [self showModalWithCancelButton:info fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int)_segment.selectedSegmentIndex;
    if (index == 1) {
        return [General isIphone]?213.0f:139.0f;
    }
    return [General isIphone]?155.0f:102.0f;
}

//Override if necesary
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array = [NSMutableArray array];
    switch (_segment.selectedSegmentIndex) {
        case 1:{
            UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Reject" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
                [self didRejectRequest:(ComertialReagent *)[_fetchedResultsController objectAtIndexPath:indexPath]];
            }];
            [array addObject:deleteAction];
            UITableViewRowAction *approve = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Approve" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
                ADBRequestedCell *cell = (ADBRequestedCell *)[tableView cellForRowAtIndexPath:indexPath];
                [self didApproveRequest:(ComertialReagent *)[_fetchedResultsController objectAtIndexPath:indexPath] units:[cell unitsApproved]];
            }];
            approve.backgroundColor = [UIColor colorWithRed:0 green:0.4 blue:0 alpha:1];
            [array addObject:approve];
            }
        
            break;
        case 2:{
            UITableViewRowAction *orderAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Mark as Ordered" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
                [self didOrder:(ComertialReagent *)[_fetchedResultsController objectAtIndexPath:indexPath]];
            }];
            [array addObject:orderAction];
            orderAction.backgroundColor = [UIColor colorWithRed:0 green:0.4 blue:0 alpha:1];
            
            if ([[[[[ADBAccountManager sharedInstance]currentGroupPerson]group]grpGroupId]intValue] == 2) {
                UITableViewRowAction *matZentrum = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"MaterialZentrum" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
                    [self materialZentrum:nil];
                }];
                [array addObject:matZentrum];
            }
        }
            
            break;
        case 3:{
            UITableViewRowAction *receivedAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Received" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
                [self didMarkAsArrived:(ComertialReagent *)[_fetchedResultsController objectAtIndexPath:indexPath]];
            }];
            receivedAction.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.5 alpha:1];
            [array addObject:receivedAction];
        }
            
            break;
            
        default:
            break;
    }
    
    return [NSArray arrayWithArray:array];
}

-(void)materialZentrum:(NSArray *)array{
    _browser = [[ADBMasterViewController alloc]init];
    _browser.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showThumb)];
    ADBAppDelegate *del = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
    UIWebView *wb = [[UIWebView alloc]initWithFrame:del.window.frame];
    wb.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [_browser.view addSubview:wb];
    [wb loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.mul.uzh.ch/materialzentrum/mul-shop/shop.html"]]];
    [self showModalWithCancelButton:_browser fromVC:(UIViewController *)self withPresentationStyle:UIModalPresentationFullScreen];
}

-(void)showThumb{
    ADBPurchasesViewController *pur = [[ADBPurchasesViewController alloc]init];
    [_browser showModalOrPopoverWithViewController:pur withFrame:CGRectMake(_browser.view.bounds.size.width - 200, 0, 200, 200)];
    [pur.segment setSelectedSegmentIndex:2];
    [pur segementChanged:pur.segment];
    pur.segment.alpha = 0.0f;
}

#pragma mark RequestedCellProtocol

-(void)didRejectRequest:(ComertialReagent *)reagent{

    for (ReagentInstance *instance in reagent.reagentInstances) {
        NSLog(@"_______ %@", instance.reiStatus);
        if ([instance.reiStatus isEqualToString:@"requested"]) {
            instance.reiStatus = @"";
            [[IPExporter getInstance]intialDeleteObject:instance];
        }
    }
    self.fetchedResultsController = nil;
    [self refreshTable];
}

-(void)didApproveRequest:(ComertialReagent *)reagent units:(int)units{
    [self refreshTable];
    
    NSMutableArray *array = [NSMutableArray array];
    for (ReagentInstance *instance in reagent.reagentInstances) {
        if ([instance.reiStatus isEqualToString:@"requested"]) {
            [array addObject:instance];
        }
    }
    if (array.count != units) {
        if (array.count > units) {
            while (array.count > units) {
                ReagentInstance *object = array.lastObject;
                object.reiStatus = @"";
                [array removeLastObject];
                [[IPExporter getInstance]intialDeleteObject:object];
            }
        }else{
            for (int x = 0; x<units-array.count; x++) {
                ReagentInstance *instance = (ReagentInstance *)[General newObjectOfType:REAGENTINSTANCE_DB_CLASS saveContext:NO];
               instance.comertialReagent = [(ReagentInstance *)array.lastObject comertialReagent];
                instance.reiStatus = [(ReagentInstance *)array.lastObject reiStatus];
                [array addObject:instance];
            }
        }
    }
    for (ReagentInstance *instance in array) {
        instance.reiStatus = @"approved";
        instance.reiRequestedBy = [ADBAccountManager sharedInstance].currentGroupPerson.gpeGroupPersonId;
        instance.reiRequestedAt = [NSDate date].description;
        //RCF Requested means approved here
        [[IPExporter getInstance]updateInfoForObject:instance withBlock:nil];
    }
    
    [self refreshTable];
}

#pragma mark ApprovedCellDelegate

-(void)didOrder:(ComertialReagent *)reagent{
    _activeReagent = reagent;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"What is the price per unit?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Don't know", @"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    ReagentInstance *rei;
    for (ReagentInstance *instance in _activeReagent.reagentInstances) {
        if ([instance.reiStatus isEqualToString:@"approved"]) {
            rei = instance;
            break;
        }
    }
    
    NSData *data = [rei.catchedInfo dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *infoDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    [General logError:error];
    
    NSString *previousPrice = [infoDictionary valueForKey:@"price"];
    if (previousPrice) {
        [[alert textFieldAtIndex:0]setText:previousPrice];
    }
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex > 0) {
        for (ReagentInstance *instance in _activeReagent.reagentInstances) {
            if ([instance.reiStatus isEqualToString:@"approved"]) {
                instance.reiStatus = @"ordered";
                if(buttonIndex == 2)
                instance.catchedInfo = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:[alertView textFieldAtIndex:0].text, @"price", nil] options:0 error:nil]encoding:NSUTF8StringEncoding];
                instance.reiOrderedBy = [ADBAccountManager sharedInstance].currentGroupPerson.gpeGroupPersonId;
                instance.reiOrderedAt = [NSDate date].description;
                [[IPExporter getInstance]updateInfoForObject:instance withBlock:nil];
            }
        }
        self.fetchedResultsController = nil;
        [self refreshTable];
    }
}

#pragma mark OrderedCellDelegate

-(void)didMarkAsArrived:(ComertialReagent *)reagent{
    for (ReagentInstance *instance in reagent.reagentInstances) {
        if ([instance.reiStatus isEqualToString:@"ordered"]) {
            instance.reiStatus = @"stock";
            instance.reiReceivedBy = [ADBAccountManager sharedInstance].currentGroupPerson.gpeGroupPersonId;
            instance.reiReceivedAt = [NSDate date].description;
            [[IPExporter getInstance]updateInfoForObject:instance withBlock:nil];
        }
    }
    self.fetchedResultsController = nil;
    [self refreshTable];
}

#pragma mark -
#pragma mark Content Filtering

//This needs Subclass
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[super filterContentForSearchText:searchText scope:scope];
	if (!self.previousPredicate) {
        self.previousPredicate = self.fetchedResultsController.fetchRequest.predicate;
    }

	if (searchText != nil) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"comName contains [cd] %@", searchText];
        NSPredicate *due = [NSPredicate predicateWithFormat:@"provider.proName contains [cd] %@", searchText];
        if (_segment.selectedSegmentIndex != 0) {
            predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate, due]];
        }
		[self.fetchedResultsController.fetchRequest setPredicate:predicate];
		[NSFetchedResultsController deleteCacheWithName:@"allCache"];
	}else {
		[self.fetchedResultsController.fetchRequest setPredicate:self.previousPredicate];
		[NSFetchedResultsController deleteCacheWithName:@"allCache"];
	}
	[self refreshTable];
    NSLog(@"results: %lu", (unsigned long)[[self.fetchedResultsController fetchedObjects]count]);
	self.searchDisplayController.searchBar.showsCancelButton = YES;
}

-(void)didAddReagentManually:(ComertialReagent *)reagent{
    [self refreshTable];
}

@end
