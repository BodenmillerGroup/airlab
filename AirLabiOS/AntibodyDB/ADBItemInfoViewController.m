//
//  ADBItemInfoViewController.m
// AirLab
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

-(ComertialReagent *)preprocessPossiblyNewComertialReagent{
    NSDictionary *dictionary = [self.reagentInfo objectAtIndex:2];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:COMERTIALREAGENT_DB_CLASS];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"comComertialReagentId" ascending:YES]];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                             [NSPredicate predicateWithFormat:@"comName == %@", [dictionary valueForKey:@"Item"]],
                                                                             [NSPredicate predicateWithFormat:@"provider.proName == %@", [dictionary valueForKey:@"Company"]],
                                                                             
                                                                             ]];
    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error)[General logError:error];
    
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
    requestB.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"proProviderId" ascending:YES]];
    requestB.predicate = [NSPredicate predicateWithFormat:@"proName == %@", [dictionary valueForKey:@"Company"]];
    NSArray *resultsProv = [self.managedObjectContext executeFetchRequest:requestB error:&error];
    if (error)[General logError:error];
    Provider *provider;
    if (resultsProv.count > 0) {
        provider = resultsProv.lastObject;
    }else{
        provider = (Provider *)[General newObjectOfType:PROVIDER_DB_CLASS saveContext:NO];
        provider.proName = [dictionary valueForKey:@"Company"];
    }
    [General doLinkForProperty:@"provider" inObject:comReag withReceiverKey:@"comProviderId" fromDonor:provider withPK:@"proProviderId"];
    
    return comReag;
}

-(Clone *)preprocessPosiblyNewClone{
    
    NSDictionary *dictionary = [self.reagentInfo objectAtIndex:2];
    Clone *clone;
    if (_isAntibody) {
        
        //Info from dict
        clone = (Clone *)[General newObjectOfType:CLONE_DB_CLASS saveContext:YES];
        clone.cloName = [dictionary valueForKey:@"Clone"];
        clone.cloIsotype = [dictionary valueForKey:@"Isotype"];
        clone.cloBindingRegion = [dictionary valueForKey:@"Immunogen"]?[dictionary valueForKey:@"Immunogen"]:[dictionary valueForKey:@"Antigen"];
        clone.cloIsPolyclonal = [[dictionary valueForKey:@"Clonality"]hasPrefix:@"Poly"]?@"1":@"0";
        
        //Trying to extract Host
        NSArray *previousHost = [General searchDataBaseForClass:SPECIES_DB_CLASS withTermContained:[dictionary valueForKey:@"Host"] inField:@"spcName" sortBy:@"spcName" ascending:YES inMOC:self.managedObjectContext];
        if (previousHost.count > 0) {
            [General doLinkForProperty:@"speciesHost" inObject:clone withReceiverKey:@"cloSpeciesHost" fromDonor:previousHost.lastObject withPK:@"spcSpeciesId"];
        }
        
        NSString *protein = [dictionary valueForKey:@"Antigen"];
        NSArray *previousProt = [General searchDataBaseForClass:PROTEIN_DB_CLASS withTerm:protein inField:@"proName" sortBy:@"proProteinId" ascending:YES inMOC:self.managedObjectContext];
        if (previousProt.count > 0) {
            [General doLinkForProperty:@"protein" inObject:clone withReceiverKey:@"cloProteinId" fromDonor:previousProt.lastObject withPK:@"proProteinId"];
        }else{
            if([dictionary valueForKey:@"Antigen"]){
                Protein *protein = (Protein *)[General newObjectOfType:PROTEIN_DB_CLASS saveContext:YES];
                protein.proName = [dictionary valueForKey:@"Antigen"];
                [General doLinkForProperty:@"protein" inObject:clone withReceiverKey:@"cloProteinId" fromDonor:protein withPK:@"proProteinId"];
            }
        }
    }
    return clone;
}

-(void)didExecuteOrderWithAmount:(int)amount andPurpose:(NSString *)purpose{

    ComertialReagent *comReag = [self preprocessPossiblyNewComertialReagent];
    Clone *clone = [self preprocessPosiblyNewClone];
    
    NSDictionary *dictionary = [self.reagentInfo objectAtIndex:2];    
    
    [General didExecuteOrderOfReagent:comReag clone:clone withAmount:amount andPurpose:purpose withBlock:^{
        [self dismissModalOrPopover];
        
        if (_isAntibody == YES) {
            for (Lot *rei in comReag.reagentInstances) {
                if([rei isMemberOfClass:[Lot class]])
                [General doLinkForProperty:@"clone" inObject:rei withReceiverKey:@"lotCloneId" fromDonor:clone withPK:@"cloCloneId"];
            }
            ADBAddAntibodyViewController *add = [[ADBAddAntibodyViewController alloc]initWithNibName:nil bundle:nil andEditableClone:clone andDict:dictionary];
            add.delegate = self;
            [self showModalWithCancelButton:add fromVC:self withPresentationStyle:UIModalPresentationFormSheet];
        }
    }]; 
}

-(void)addAntibody:(ADBAddAntibodyViewController *)controller withNewProtein:(BOOL)newProt{
    [self dismissModalOrPopover];
}


@end
