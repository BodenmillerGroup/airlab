//
//  ADBItemInfoViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/10/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBItemInfoViewController.h"
#import "ADBShopParsers.h"

@interface ADBItemInfoViewController ()

@property (nonatomic, strong) NSArray *reagentInfo;
@property (nonatomic, strong) NSString *reagentUrl;

@end

@implementation ADBItemInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withUrl:(NSString *)url
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.reagentUrl = url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTheTableviewWithStyle:UITableViewStylePlain];
    
    self.navigationItem.rightBarButtonItems = @[
                                                [[UIBarButtonItem alloc]initWithTitle:@"Purchase" style:UIBarButtonItemStyleDone target:self action:@selector(addReagent)],
                                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)],
                                                ];
    
    if(_reagentUrl)[self searchProductData];
}

-(void)cancel{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)addReagent{
    ADBPurchaseBoxViewController *box = [[ADBPurchaseBoxViewController alloc]init];
    box.delegate = self;
    [General iPhoneBlock:^{
        [self showModalWithCancelButton:box fromVC:self withPresentationStyle:UIModalPresentationFullScreen];
    } iPadBlock:^{
        [self showModalOrPopoverWithViewController:box withFrame:self.navigationController.navigationBar.frame];
    }];
}

-(void)share{

}

-(void)searchProductData{
    if(!parserBrain){
        parserBrain = [[ADBShopParsers alloc]init];
    }
	
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable)[self noInternetConnection];
    else{
        [self startNavBarSpinner];
        NSMutableURLRequest *request = [General callToGetAPI:[NSString stringWithFormat:@"http://www.biocompare.com%@",self.reagentUrl]];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response_, NSData *data_, NSError *error_){
            if(error_){
                [self errorInternetConnection];
            }else{
                self.reagentInfo = [parserBrain parseProduct:data_];
                [self.tableView reloadData];
            }
            [self stopNavBarSpinner];
        }];
    }
}

#pragma tableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.reagentInfo.lastObject count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"CloneCell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    cell.textLabel.text = [[self.reagentInfo objectAtIndex:0]objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [[self.reagentInfo objectAtIndex:1]objectAtIndex:indexPath.row];
    
    [self setGrayColorInTableText:cell];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.detailTextLabel.text hasPrefix:@"http"]) {
        UIViewController *cont = [[UIViewController alloc]init];
        UIWebView *wb = [[UIWebView alloc]initWithFrame:self.view.window.frame];
        wb.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        [cont.view addSubview:wb];
        [wb loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:cell.detailTextLabel.text]]];
        [self showModalWithCancelButton:cont fromVC:self withPresentationStyle:UIModalPresentationFullScreen];
    }
}

#pragma mark PurchaseBoxProtocol

-(void)didExecuteOrderWithAmoung:(int)amount{
    //TODO refract
    //Pointer to info
    NSDictionary *dictionary = [self.reagentInfo objectAtIndex:2];
    
    //Check reagent is not in DB
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:COMERTIALREAGENT_DB_CLASS];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"comComertialReagentId" ascending:YES]];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                             [NSPredicate predicateWithFormat:@"comName == %@", [dictionary valueForKey:@"Item"]],
                                                                             [NSPredicate predicateWithFormat:@"provider.proName == %@", [dictionary valueForKey:@"Company"]],
                                                                             
                                                                             ]];
    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error)[General logError:error];
    
    //Grab instance or create for Reagent
    ComertialReagent *comReag;
    if (results.count > 0) {
        comReag = results.lastObject;
    }else{
        comReag = (ComertialReagent *)[General newObjectOfType:COMERTIALREAGENT_DB_CLASS saveContext:NO];
        comReag.comName = [dictionary valueForKey:@"Item"];
        comReag.comReference = [dictionary valueForKey:@"Catalog Number"];
        comReag.catchedInfo = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error] encoding:NSUTF8StringEncoding];
        
    }
    
    
    //Check provider
    NSFetchRequest *requestB = [NSFetchRequest fetchRequestWithEntityName:PROVIDER_DB_CLASS];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"proProviderId" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"proName == %@", [dictionary valueForKey:@"Company"]];
    NSArray *resultsProv = [self.managedObjectContext executeFetchRequest:requestB error:&error];
    if (error)[General logError:error];
    if (resultsProv.count > 0) {
        comReag.provider = resultsProv.lastObject;
    }else{
        Provider *prov = (Provider *)[General newObjectOfType:PROVIDER_DB_CLASS saveContext:NO];
        prov.proName = [dictionary valueForKey:@"Company"];
    }
    
    //Add instances
    for (int x = 0; x<amount; x++) {
        ReagentInstance *instance = (ReagentInstance *)[General newObjectOfType:REAGENTINSTANCE_DB_CLASS saveContext:NO];
        [General doLinkForProperty:@"comertialReagent" inObject:instance withReceiverKey:@"reiComertialReagentId" fromDonor:comReag withPK:@"comComertialReagentId"];
        instance.reiStatus = @"requested";
    }
    
    if (_isAntibody == YES) {
        //Create the Protein, and clone, and Lot if possible here
        NSLog(@"Will create an antibody______________");
    }
    
    [General saveContextAndRoll];
    
    [self dismissModalOrPopover];
}


@end
