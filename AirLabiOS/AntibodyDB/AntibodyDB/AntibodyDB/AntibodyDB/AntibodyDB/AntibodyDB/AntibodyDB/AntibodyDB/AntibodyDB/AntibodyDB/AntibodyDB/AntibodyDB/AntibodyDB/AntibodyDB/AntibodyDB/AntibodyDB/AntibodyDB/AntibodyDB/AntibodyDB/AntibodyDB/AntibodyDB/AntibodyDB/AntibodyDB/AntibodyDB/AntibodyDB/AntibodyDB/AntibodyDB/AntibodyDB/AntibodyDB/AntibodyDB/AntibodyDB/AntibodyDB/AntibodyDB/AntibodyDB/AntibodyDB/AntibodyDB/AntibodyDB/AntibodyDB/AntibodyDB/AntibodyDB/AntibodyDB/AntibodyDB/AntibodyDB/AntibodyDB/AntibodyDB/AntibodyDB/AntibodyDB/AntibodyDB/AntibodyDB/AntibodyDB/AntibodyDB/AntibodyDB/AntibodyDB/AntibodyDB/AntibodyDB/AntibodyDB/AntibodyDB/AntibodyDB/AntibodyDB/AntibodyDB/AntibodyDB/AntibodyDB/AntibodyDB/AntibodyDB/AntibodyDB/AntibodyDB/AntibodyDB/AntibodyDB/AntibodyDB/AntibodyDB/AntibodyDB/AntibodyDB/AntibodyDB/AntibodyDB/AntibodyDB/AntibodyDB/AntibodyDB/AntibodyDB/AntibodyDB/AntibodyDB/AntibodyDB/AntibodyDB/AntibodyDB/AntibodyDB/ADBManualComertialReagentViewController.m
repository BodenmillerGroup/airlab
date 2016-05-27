//
//  ADBManualComertialReagentViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 6/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBManualComertialReagentViewController.h"
#import "ADBPurchaseBoxViewController.h"

@interface ADBManualComertialReagentViewController ()

@property (nonatomic, strong) NSMutableDictionary *properties;
@property (nonatomic, strong) Provider *provider;

@end

@implementation ADBManualComertialReagentViewController

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
    if (!self.properties) {
        self.properties = [NSMutableDictionary dictionary];
    }
    
    [General addBorderToButton:_addTagButton withColor:[UIColor orangeColor]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
}

-(void)selectProvider:(UIButton *)sender{
    ADBProviderSelectorViewController *providerSelector = [[ADBProviderSelectorViewController alloc]init];
    providerSelector.delegate = self;
    [self showModalOrPopoverWithViewController:providerSelector withFrame:sender.frame];
}

-(void)didSelectProvider:(Provider *)provider{
    self.provider = provider;
    [self.providerButton setTitle:provider.proName forState:UIControlStateNormal];
    [self dismissModalOrPopover];
}

-(void)save{
    if (_nameOfReagent.text.length == 0) {
        [General showOKAlertWithTitle:@"Please input name" andMessage:nil];
        return;
    }
    
    if (_nameOfReagent.text.length >254) {
        [General showOKAlertWithTitle:@"Sample name is too long" andMessage:nil];
        return;
    }
    ComertialReagent *com = (ComertialReagent *)[General newObjectOfType:COMERTIALREAGENT_DB_CLASS saveContext:YES];
    ReagentInstance *rei = (ReagentInstance *)[General newObjectOfType:REAGENTINSTANCE_DB_CLASS saveContext:YES];
    [General doLinkForProperty:@"comertialReagent" inObject:rei withReceiverKey:@"reiComertialReagentId" fromDonor:com withPK:@"comComertialReagentId"];
    rei.reiStatus = @"requested";
    rei.catchedInfo = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:_price.text, @"price", nil] options:0 error:nil]encoding:NSUTF8StringEncoding];
    
    com.comName = _nameOfReagent.text;
    com.comReference = _reference.text;
    com.catchedInfo = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithDictionary:_properties] options:0 error:nil]encoding:NSUTF8StringEncoding];
    
    if (_aNewProvider.text.length > 0) {
        NSArray *found = [General searchDataBaseForClass:PROVIDER_DB_CLASS withTerm:_aNewProvider.text inField:@"proName" sortBy:@"proName" ascending:YES inMOC:self.managedObjectContext];
        if (found.count > 0) {
            self.provider = found.lastObject;
        }else{
            self.provider = (Provider *)[General newObjectOfType:PROVIDER_DB_CLASS saveContext:YES];
            _provider.proName = _aNewProvider.text;
        }
    }else{
        if (!_provider) {
            [General showOKAlertWithTitle:@"Please select a provider" andMessage:@"If you don't find it in the list, please enter a name in the text field on the right"];
            return;
        }
    }
    
    [General doLinkForProperty:@"provider" inObject:com withReceiverKey:@"comProviderId" fromDonor:_provider withPK:@"proProviderId"];
    
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.delegate didAddReagentManually:com];
}

- (IBAction)addNewProperty:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Name of property" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    UITextField *tv = [alertView textFieldAtIndex:0];
    return tv.text.length > 0? YES:NO;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self.properties setValue:@"" forKey:[alertView textFieldAtIndex:0].text];
        [self.tableView reloadData];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.properties.allKeys.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    for (UIView *aview in cell.contentView.subviews) {
        if ([aview isMemberOfClass:[UITextField class]]) {
            [aview removeFromSuperview];
        }
    }
    
    cell.textLabel.text = [_properties.allKeys objectAtIndex:indexPath.row];
    UITextField *field = [[UITextField alloc]initWithFrame:CGRectMake(cell.contentView.bounds.size.width - 300, 10, 280, 20)];
    field.tag = indexPath.row;
    field.delegate = self;
    field.text = [_properties valueForKey:cell.textLabel.text];
    field.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    if (field.text.length > 0) {
        field.placeholder = @"Insert Value";
    }
    [cell.contentView addSubview:field];
    
    [self setGrayColorInTableText:cell];
    
    return cell;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [_properties setValue:textField.text forKey:[_properties.allKeys objectAtIndex:textField.tag]];
}

@end
