//
//  ADBInfoCommertialViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/11/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBInfoCommertialViewController.h"
#import "ADBShopParsers.h"
#import "Object+Utilities.h"
#import "ADBDetailsREIViewController.h"

@interface ADBInfoCommertialViewController ()

@property (nonatomic, strong) NSDictionary *infoDictionary;

@end

@implementation ADBInfoCommertialViewController

@synthesize reagent = _reagent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andReagent:(ComertialReagent *)reagent
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.reagent = reagent;
    }
    return self;
}

-(void)linkTables{
    [General iPhoneBlock:^{
        self.tableView.bounds = CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
        CGRect first = self.tableView2.frame;
        float height1 = self.tableView.frame.origin.y + self.tableView.frame.size.height + 5;
        self.tableView2.frame = CGRectMake(first.origin.x, height1, first.size.width, self.view.bounds.size.height - height1 );
        
    } iPadBlock:nil];
}

-(void)retrieveAbInfo{
        //if (_reagent.catchedInfo.length == 0) {
            NSString *companyName = self.reagent.provider.proAcronym;
            NSString *reference = self.reagent.comReference;
            if ([companyName isEqualToString:@"CST"]) {
                companyName = @"Cell+Signaling";
                reference = [reference stringByReplacingOccurrencesOfString:@"BF" withString:@""];
            }
            if ([companyName isEqualToString:@"SANTA_CRUZ"]) {
                companyName = [companyName stringByReplacingOccurrencesOfString:@"_" withString:@"+"];
            }
            if ([companyName isEqualToString:@"BD"]) {
                companyName = [companyName stringByReplacingOccurrencesOfString:@"BD" withString:@"Becton+Dickinson"];
            }
            if ([companyName isEqualToString:@"RD"]) {
                companyName = @"RND";
            }
    
            NSString *url = [NSString stringWithFormat:@"http://www.biocompare.com/Search-Antibodies/?search=%@+%@", reference, companyName];
            NSLog(@"url is %@", url);
            NSMutableURLRequest *request = [General callToGetAPI:url];
            NSLog(@"Will call %@", request.URL.absoluteString);
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                if (!error) {
                    //NSLog(@"Me devuelve esto %@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
                    ADBShopParsers *parser = [[ADBShopParsers alloc]init];
                    NSArray *result = [parser parseDataForProduct:data];
                    if (result) {
                        NSString *url2 = [NSString stringWithFormat:@"http://www.biocompare.com%@", [[result objectAtIndex:1]objectAtIndex:0]];

                        NSMutableURLRequest *request2 = [General callToGetAPI:url2];
                        NSLog(@"Will call 2 %@", request2.URL.absoluteString);
                        [NSURLConnection sendAsynchronousRequest:request2 queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response2, NSData *data2, NSError *error2){
                            if (!error2) {
                                
                                NSArray *array2 = [parser parseProduct:data2];
                                if (array2 && array2.count >= 3) {
                                    NSLog(@"Array 2 %@", array2);
                                    NSDictionary *dict = [array2 objectAtIndex:2];
                                    NSError *error3;
                                    //--[self.managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
                                    _reagent.catchedInfo = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error3] encoding:NSUTF8StringEncoding];
                                    NSData *data = [self.reagent.catchedInfo dataUsingEncoding:NSUTF8StringEncoding];
                                    NSError *error;
                                    self.infoDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                                    [General logError:error];
                                    [self.tableView reloadData];
                                    [[IPExporter getInstance]updateInfoForObject:_reagent withBlock:nil];
                                    //--[self.managedObjectContext setMergePolicy:NSErrorMergePolicy];

                                }
                                
                            }
                        }];
                    }
                }
            }];
        //}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self retrieveAbInfo];
    
    [self.imageQR setBackgroundImage:[Object imageQRForObject:self.reagent] forState:UIControlStateNormal];
    [self.imageQR addTarget:self action:@selector(tappedQR:) forControlEvents:UIControlEventTouchUpInside];
    
    self.title = [NSString stringWithFormat:@"%@ | %@ - %@", self.reagent.comName, self.reagent.provider.proName, self.reagent.comReference];
    
    NSData *data = [self.reagent.catchedInfo dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    self.infoDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    [General logError:error];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reorder:)];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self linkTables];
}

-(void)tappedQR:(UIButton *)sender{
    if (sender.selected) {
        sender.frame = CGRectMake(sender.frame.origin.x, sender.frame.origin.y, sender.frame.size.width/4, sender.frame.size.height/4);
    }else{
        sender.frame = CGRectMake(sender.frame.origin.x, sender.frame.origin.y, sender.frame.size.width*4, sender.frame.size.height*4);
    }
    sender.selected = !sender.selected;
}

-(void)reorder:(UIBarButtonItem *)sender{
    ADBPurchaseBoxViewController *box = [[ADBPurchaseBoxViewController alloc]init];
    box.delegate = self;
    [General iPhoneBlock:^{
        [self showModalWithCancelButton:box fromVC:self withPresentationStyle:UIModalPresentationFullScreen];
    } iPadBlock:^{
        self.popover = [[UIPopoverController alloc]initWithContentViewController:box];
        [self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }];
}

-(void)didExecuteOrderWithAmoung:(int)amount{
    //TODO refract

    //Add instances
    for (int x = 0; x<amount; x++) {
        ReagentInstance *instance = (ReagentInstance *)[General newObjectOfType:REAGENTINSTANCE_DB_CLASS saveContext:NO];
        [General doLinkForProperty:@"comertialReagent" inObject:instance withReceiverKey:@"reiComertialReagentId" fromDonor:_reagent withPK:@"comComertialReagentId"];
        instance.reiStatus = @"requested";
    }
    [General saveContextAndRoll];
    
    [self dismissModalOrPopover];
    [self.tableView2 reloadData];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        return @"Product information";
    }
    return @"Product units";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = 0;
    if (tableView == self.tableView) {
        count = [self.infoDictionary allKeys].count;
    }else{
        count = self.reagent.reagentInstances.allObjects.count;
    }
    return count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if (tableView == self.tableView) {
        static NSString *cellId = @"ComInfoCell";
        cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        }
        cell.textLabel.text = [self.infoDictionary.allKeys objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [self.infoDictionary.allValues objectAtIndex:indexPath.row];
    }else{
        static NSString *cellId = @"InstanceCell";
        cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        }
        ReagentInstance *instance = (ReagentInstance *)[self.reagent.reagentInstances.allObjects objectAtIndex:indexPath.row];
        cell.textLabel.text = instance.comertialReagent.comName;
        if ([instance.reiStatus isEqualToString:@"ordered"]) {
            cell.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0 alpha:0.03];
        }else if([instance.reiStatus isEqualToString:@"stock"]){
            cell.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:0.03];
        }else if([instance.reiStatus isEqualToString:@"requested"]){
            cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.5 alpha:0.03];
        }
    }
    [self setGrayColorInTableText:cell];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (tableView != self.tableView) {
        ADBDetailsREIViewController *details = [[ADBDetailsREIViewController alloc]initWithNibName:nil bundle:nil andRei:(ReagentInstance *)[self.reagent.reagentInstances.allObjects objectAtIndex:indexPath.row]];
        details.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        [self.navigationController pushViewController:details animated:YES];
        return;
    }
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

@end
