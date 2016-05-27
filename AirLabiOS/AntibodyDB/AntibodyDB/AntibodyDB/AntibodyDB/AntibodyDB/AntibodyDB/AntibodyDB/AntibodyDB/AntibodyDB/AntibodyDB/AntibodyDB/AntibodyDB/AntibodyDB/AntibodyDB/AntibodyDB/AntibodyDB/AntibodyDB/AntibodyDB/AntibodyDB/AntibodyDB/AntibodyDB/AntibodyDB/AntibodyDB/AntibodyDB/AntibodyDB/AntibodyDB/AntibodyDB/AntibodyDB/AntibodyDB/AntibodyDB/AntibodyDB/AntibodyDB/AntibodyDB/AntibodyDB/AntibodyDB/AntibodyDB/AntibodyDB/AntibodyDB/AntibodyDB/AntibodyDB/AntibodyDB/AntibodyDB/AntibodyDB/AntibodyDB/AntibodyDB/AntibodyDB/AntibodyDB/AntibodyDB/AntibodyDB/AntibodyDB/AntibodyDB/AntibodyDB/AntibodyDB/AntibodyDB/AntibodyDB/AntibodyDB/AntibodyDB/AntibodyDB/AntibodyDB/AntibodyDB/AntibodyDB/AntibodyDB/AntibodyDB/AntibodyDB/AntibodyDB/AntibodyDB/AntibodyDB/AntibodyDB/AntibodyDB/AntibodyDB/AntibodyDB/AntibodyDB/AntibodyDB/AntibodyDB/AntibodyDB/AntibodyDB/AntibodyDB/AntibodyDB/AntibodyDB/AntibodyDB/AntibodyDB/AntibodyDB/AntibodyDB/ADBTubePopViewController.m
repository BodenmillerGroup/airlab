//
//  ADBViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBTubePopViewController.h"
#import "Object+Utilities.h"

@interface ADBTubePopViewController ()

@property (nonatomic, strong) Tube *tube;
@property (nonatomic, strong) NSDictionary *infoDictionary;

@end

@implementation ADBTubePopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTube:(Tube *)tube
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tube = tube;
    }
    return self;
}

- (IBAction)markEmpty:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Delete this tube?" message:@"Are you sure? This action is irreversible and the tube will no longer be accessible" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes, Delete", nil];
    alert.tag = 1;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1){
        if(buttonIndex == 1){
            self.tube.place = nil;
            self.tube.tubPlaceId = nil;
            [[IPExporter getInstance]deleteObject:self.tube withBlock:nil];
            [self.delegate didRemoveTube];
        }
    }
}

- (IBAction)reorder:(UIButton *)sender {
    ADBPurchaseBoxViewController *box;
    if([self.tube isMemberOfClass:[ReagentInstance class]]){
        box = [[ADBPurchaseBoxViewController alloc]initWithNibName:nil bundle:nil andReagent:[(ReagentInstance *)self.tube comertialReagent]];
    }else if([self.tube isMemberOfClass:[LabeledAntibody class]]){
        box = [[ADBPurchaseBoxViewController alloc]initWithNibName:nil bundle:nil andReagent:[(Lot *)[(LabeledAntibody *)self.tube lot ]reagentInstance].comertialReagent];
    }
    box.delegate = self;
    self.popover = [[UIPopoverController alloc]initWithContentViewController:box];
    [self.popover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)removeTube:(id)sender {
    self.tube.place = nil;
    self.tube.tubPlaceId = nil;
    [[IPExporter getInstance]updateInfoForObject:self.tube withBlock:nil];
    [self.delegate didRemoveTube];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.preferredContentSize = self.view.bounds.size;
    
    if([self.tube isMemberOfClass:[ReagentInstance class]]){
        NSData *data = [[(ReagentInstance *)self.tube comertialReagent].catchedInfo dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        self.infoDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        [General logError:error];
    }
    if([self.tube isMemberOfClass:[LabeledAntibody class]]){
        NSArray *keys = [[_tube entity]attributesByName].allKeys;
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:keys.count];
        for(NSString *key in keys){
            [dict setValue:[_tube valueForKey:key] forKey:key];
        }
        self.infoDictionary = [NSDictionary dictionaryWithDictionary:dict];
    }
    if ([self.tube isMemberOfClass:[Sample class]]) {
        NSData *data = [[(Sample *)self.tube samData] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        self.infoDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (error)[General logError:error];
        
        self.reorder.hidden = YES;
        self.empty.frame = self.reorder.frame;
    }
    
    [self.qrImage setBackgroundImage:[Object imageQRForObject:self.tube] forState:UIControlStateNormal];
    [self.qrImage addTarget:self action:@selector(tappedQR:) forControlEvents:UIControlEventTouchUpInside];
    
    self.topLabel.layer.borderColor = [UIColor grayColor].CGColor;
    self.topLabel.layer.borderWidth = 2.0f;
    self.topLabel.layer.cornerRadius = self.topLabel.bounds.size.width/2;
    
    self.sideLabel.layer.borderColor = [UIColor grayColor].CGColor;
    self.sideLabel.layer.borderWidth = 2.0f;
    self.sideLabel.layer.cornerRadius = 5.0f;
    
    self.topLabel.text = [General titleForTube:self.tube];
    self.sideLabel.text = [General titleForSideOfTube:self.tube];
    
    [General addBorderToButton:self.empty withColor:[UIColor redColor]];
    [General addBorderToButton:self.reorder withColor:[UIColor orangeColor]];
    [General addBorderToButton:self.remove withColor:[UIColor blueColor]];
}

-(void)tappedQR:(UIButton *)sender{
    if (sender.selected) {
        sender.frame = CGRectMake(sender.frame.origin.x, sender.frame.origin.y, sender.frame.size.width/4, sender.frame.size.height/4);
    }else{
        sender.frame = CGRectMake(sender.frame.origin.x, sender.frame.origin.y, sender.frame.size.width*4, sender.frame.size.height*4);
    }
    sender.selected = !sender.selected;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.infoDictionary.allKeys.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    static NSString *cellId = @"ComInfoCell";
    cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    cell.textLabel.text = [self.infoDictionary.allKeys objectAtIndex:indexPath.row];
    //cell.detailTextLabel.text = [self.infoDictionary.allValues objectAtIndex:indexPath.row];
    [self setGrayColorInTableText:cell];
    return cell;
}

#pragma mark purchase protocol

-(void)didExecuteOrderOfReagent:(ComertialReagent *)reagent WithAmoung:(int)amount{
    //Add instances
    for (int x = 0; x<amount; x++) {
        ReagentInstance *instance = (ReagentInstance *)[General newObjectOfType:REAGENTINSTANCE_DB_CLASS saveContext:NO];
        
        [General doLinkForProperty:COMERTIALREAGENT_DB_CLASS inObject:instance withReceiverKey:@"reiComertialReagentId" fromDonor:reagent withPK:@"comComertialReagentId"];
        
        instance.reiStatus = @"requested";
    }
    [General saveContextAndRoll];
    
    [self.popover dismissPopoverAnimated:YES];
}

@end
