//
//  ADBAddKitViewController.m
// AirLab
//
//  Created by Raul Catena on 5/7/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddKitViewController.h"

@interface ADBAddKitViewController ()

@property (nonatomic, strong) Provider *provider;
@property (nonatomic, strong) Clone *clone;
@property (nonatomic, strong) NSDictionary *prevInfo;

@end

@implementation ADBAddKitViewController

@synthesize delegate = _delegate;
@synthesize lot = _lot;
@synthesize provider = _provider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andClone:(Clone *)aClone andDict:(NSDictionary *)dict
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.clone = aClone;
        self.prevInfo = dict;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andClone:(Clone *)aClone andDict:(NSDictionary *)dict andLot:(Lot *)lot
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.clone = aClone;
        self.prevInfo = dict;
        self.lot = lot;
    }
    return self;
}

-(void)previousLotsInfo{
    Lot *anyOtherLot;
    if(self.lot){
        self.lotNumber.text = _lot.lotNumber;
        self.amount.value = _lot.lotConcentration.floatValue;
        self.dataSheetLink.text = _lot.lotDataSheetLink;
        self.provider = self.lot.provider;
        self.orderNumber.text = self.lot.comertialReagent.comReference;
    }
    for (Lot *alot in self.clone.lots) {
          if (alot.comertialReagent.comReference.length > 0) {
              anyOtherLot = alot;
              break;
          }
      }
      
      self.orderNumber.text = anyOtherLot.comertialReagent.comReference;
      if(!_lot)self.provider = anyOtherLot.comertialReagent.provider;

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
    [General addBorderToButton:_providerButton withColor:[UIColor orangeColor]];
}

-(void)concentrationChanged:(UISlider *)sender{
    int sobra = (int)sender.value%20;
    float value;
    if (sobra == 0) {
        value = (int)sender.value;
    }else{
        value = floorf(sender.value-sobra);
    }
    sender.value = value;
    
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
    if (!_clone) {
        [General showOKAlertWithTitle:@"Select a clone first" andMessage:nil delegate:self];
        return;
    }
    NSString *missing = @"";
    if(self.lotNumber.text.length == 0){
        missing = [missing stringByAppendingString:@"Lot number/name\n"];
    }
    if(!self.provider){
        missing = [missing stringByAppendingString:@"Provider\n"];
    }
    
    if(missing.length > 0){
        [General showOKAlertWithTitle:@"Information missing:" andMessage:missing delegate:self];
        return;
    }
    if(!_lot)self.lot = (Lot *)[General newObjectOfType:LOT_DB_CLASS saveContext:YES];
    [General doLinkForProperty:@"clone" inObject:self.lot withReceiverKey:@"lotCloneId" fromDonor:self.clone withPK:@"cloCloneId"];
    NSLog(@"g");
    [General doLinkForProperty:@"provider" inObject:self.lot withReceiverKey:@"lotProviderId" fromDonor:self.provider withPK:@"proProviderId"];
    NSLog(@"h");
    if(!_lot.requester)[General doLinkForProperty:@"requester" inObject:self.lot withReceiverKey:@"reiRequestedBy" fromDonor:[[ADBAccountManager sharedInstance]currentGroupPerson] withPK:@"gpeGroupPersonId"];
    self.lot.reiRequestedAt = self.lotOrderDate.date.description;
    self.lot.lotExpirationDate = self.lotExpirationDate.date.description;
    self.lot.lotHasCarrier = [NSString stringWithFormat:@"%i", self.carrierSwitch.on];
    self.lot.lotDataSheetLink = self.dataSheetLink.text;
    self.lot.lotConcentration = [NSString stringWithFormat:@"%.0f", _amount.value];
    self.lot.lotNumber = [NSString stringWithFormat:@"%@", self.lotNumber.text];
    self.lot.reiStatus = @"requested";
    NSArray *comExists = [General searchDataBaseForClass:COMERTIALREAGENT_DB_CLASS withTerm:_orderNumber.text inField:@"comReference" sortBy:@"comReference" ascending:YES inMOC:self.managedObjectContext];
    ComertialReagent *comReagent;
    if (comExists.count > 0) {
        comReagent = comExists.lastObject;
    }else{
        comReagent = (ComertialReagent *)[General newObjectOfType:COMERTIALREAGENT_DB_CLASS saveContext:YES];
    }
    comReagent.comReference = _orderNumber.text;
    
    [General doLinkForProperty:@"provider" inObject:comReagent withReceiverKey:@"comProviderId" fromDonor:_provider withPK:@"proProviderId"];
    comReagent.comName = [NSString stringWithFormat:@"%@ - clone %@", self.clone.protein.proName, self.clone.cloName];
    [General doLinkForProperty:@"comertialReagent" inObject:_lot withReceiverKey:@"reiComertialReagentId" fromDonor:comReagent withPK:@"comComertialReagentId"];
    [General saveContextAndRoll];
    if([_lot valueForKey:[[IPImporter getInstance]keyOfObject:NSStringFromClass([_lot class])]]){
        [[IPExporter getInstance]updateInfoForObject:_lot withBlock:nil];
    }
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
