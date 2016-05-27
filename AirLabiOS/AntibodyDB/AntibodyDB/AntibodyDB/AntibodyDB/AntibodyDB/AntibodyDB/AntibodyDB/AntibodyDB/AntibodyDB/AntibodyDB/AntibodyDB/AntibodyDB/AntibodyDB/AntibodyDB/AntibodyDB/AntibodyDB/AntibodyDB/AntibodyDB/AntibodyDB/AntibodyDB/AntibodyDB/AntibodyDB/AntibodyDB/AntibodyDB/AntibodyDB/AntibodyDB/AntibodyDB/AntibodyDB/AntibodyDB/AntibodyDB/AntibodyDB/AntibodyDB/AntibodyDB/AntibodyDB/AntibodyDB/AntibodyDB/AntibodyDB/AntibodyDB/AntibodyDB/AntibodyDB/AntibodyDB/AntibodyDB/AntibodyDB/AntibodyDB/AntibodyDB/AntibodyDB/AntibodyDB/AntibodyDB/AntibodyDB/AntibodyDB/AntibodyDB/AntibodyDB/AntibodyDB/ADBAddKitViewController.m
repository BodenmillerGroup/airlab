//
//  ADBAddKitViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/7/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddKitViewController.h"

@interface ADBAddKitViewController ()

@property (nonatomic, strong) Provider *provider;
@property (nonatomic, strong) Clone *clone;

@end

@implementation ADBAddKitViewController

@synthesize delegate = _delegate;
@synthesize lot = _lot;
@synthesize provider = _provider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andClone:(Clone *)aClone
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.clone = aClone;
    }
    return self;
}

-(void)previousLotsInfo{
    Lot *anyOtherLot;
    
    /////RCF no entiendo esto
    for (Lot *alot in self.clone.lots) {
          if (alot.reagentInstance.comertialReagent.comReference.length > 0) {
              anyOtherLot = alot;
              break;
          }
      }
      
      self.orderNumber.text = anyOtherLot.reagentInstance.comertialReagent.comReference;
      self.provider = anyOtherLot.reagentInstance.comertialReagent.provider;
      if (!anyOtherLot) {
          NSLog(@"No lot");
      }
      
      if (!anyOtherLot.reagentInstance) {
          NSLog(@"No REI");
      }
      if (!anyOtherLot.reagentInstance.comertialReagent) {
          NSLog(@"No Coi");
      }
      if (!anyOtherLot.reagentInstance.comertialReagent.provider) {
          NSLog(@"No Proc");
      }
      if (self.provider) {NSLog(@"There is a provider");
          [self.providerButton setTitle:_provider.proName forState:UIControlStateNormal];
          self.providerLabel.hidden = YES;
          self.providerTextField.hidden = YES;
      }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [self previousLotsInfo];
}

-(void)concentrationChanged:(UISlider *)sender{
    self.amountLabel.text = [NSString stringWithFormat:@"%.0f ug", sender.value];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.clone.lots.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"CloneCell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    Lot *protein = [self.clone.lots.allObjects objectAtIndex:indexPath.row];
    cell.textLabel.text = protein.lotNumber;
    cell.detailTextLabel.text = protein.provider.proName;
    
    return cell;
}

-(void)done{
    
    //TODO populate the lot
    if (!_clone) {
        [General showOKAlertWithTitle:@"Select a clone first" andMessage:nil];
        return;
    }
    
    
    
    NSString *missing = @"";
    
    if(self.lotNumber.text.length > 0){
        self.lot.lotNumber = self.lotNumber.text;
    }else{
        missing = [missing stringByAppendingString:@"Lot number/name\n"];
    }
    
    if(!self.provider){
        missing = [missing stringByAppendingString:@"Provider\n"];
    }
    if(missing.length > 0){
        [General showOKAlertWithTitle:@"Information missing:" andMessage:missing];
        return;
    }
        
    self.lot = (Lot *)[General newObjectOfType:LOT_DB_CLASS saveContext:YES];
    [General doLinkForProperty:@"clone" inObject:self.lot withReceiverKey:@"lotCloneId" fromDonor:self.clone withPK:@"cloCloneId"];
    [General doLinkForProperty:@"provider" inObject:self.lot withReceiverKey:@"lotProviderId" fromDonor:self.provider withPK:@"proProviderId"];
    self.lot.lotOrderDate = self.lotOrderDate.date.description;
    self.lot.lotExpirationDate = self.lotExpirationDate.date.description;
    //TODO carrier
    self.lot.lotHasCarrier = [NSString stringWithFormat:@"%i", self.carrierSwitch.on];
    self.lot.lotDataSheetLink = self.dataSheetLink.text;
    self.lot.lotConcentration = [NSString stringWithFormat:@"%.0f", _amount.value];
    self.lot.lotNumber = self.lotNumber.text;
    //self.
    
    
    
    ReagentInstance *reinstance = (ReagentInstance *)[General newObjectOfType:REAGENTINSTANCE_DB_CLASS saveContext:YES];
    reinstance.reiStatus = @"requested";
    [General doLinkForProperty:@"reagentInstance" inObject:_lot withReceiverKey:@"lotReagentInstanceId" fromDonor:reinstance withPK:@"reiReagentInstanceId"];
    
    NSArray *comExists = [General searchDataBaseForClass:COMERTIALREAGENT_DB_CLASS withTerm:_orderNumber.text inField:@"comReference" sortBy:@"comReference" ascending:YES inMOC:self.managedObjectContext];
    ComertialReagent *comReagent;
    if (comExists.count > 0) {
        comReagent = comExists.lastObject;
    }else{
        comReagent = (ComertialReagent *)[General newObjectOfType:COMERTIALREAGENT_DB_CLASS saveContext:YES];
        comReagent.comReference= _orderNumber.text;
    }
    [General doLinkForProperty:PROVIDER_DB_CLASS inObject:comReagent withReceiverKey:@"comProviderId" fromDonor:_provider withPK:@"proProviderId"];
    
    comReagent.comName = [NSString stringWithFormat:@"%@ - clone %@", self.clone.protein.proName, self.clone.cloName];
    
    [General doLinkForProperty:COMERTIALREAGENT_DB_CLASS inObject:reinstance withReceiverKey:@"reiComertialReagentId" fromDonor:comReagent withPK:@"comComertialReagentId"];
    
    [General saveContextAndRoll];
    [self.delegate didAddLot:self.lot];
}

-(void)selectProvider:(UIButton *)sender{
    ADBProviderSelectorViewController *providerSelector = [[ADBProviderSelectorViewController alloc]init];
    providerSelector.delegate = self;
    [self showModalOrPopoverWithViewController:providerSelector withFrame:sender.frame];
}

-(void)didSelectProvider:(Provider *)provider{
    self.provider = provider;
    [self.providerButton setTitle:provider.proName forState:UIControlStateNormal];
    self.providerLabel.hidden = YES;
    self.providerTextField.hidden = YES;
    [self dismissModalOrPopover];
}

@end
