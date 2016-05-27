//
//  ADBAddSampleViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 6/16/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddSampleViewController.h"

@interface ADBAddSampleViewController ()

@property (nonatomic, strong) NSArray *options;

@end

@implementation ADBAddSampleViewController

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
    
    self.options = @[@"Chemical", @"Parafin Block", @"Section", @"Cell line", @"DNA", @"RNA", @"Protein", @"Snap Frozen Tissue",  @"Hybridoma",  @"Antibody", @"Primer", @"PCR Primer set", @"Plasmid Prep", @"Recombinant Protein", @"Fixed tissue block", @"Virus Prep", @"Blood/Serum/Plasma", @"Mouse", @"Monkey", @"Rat", @"Minipig", @"Zebra Fish", @"Bacteria", @"Yeast", @"Seed", @"Plant", @"Fly", @"Other..."];
    
    [self setTheTableviewWithStyle:UITableViewStylePlain];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _options.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *type = @"TyepCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:type];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:type];
    }
    
    cell.textLabel.text = [_options objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == self.options.count - 1){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Sample Type" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
        return;
    }
    [self.delegate willCreateSample:[_options objectAtIndex:indexPath.row]];
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    return [alertView textFieldAtIndex:0].text.length > 0? YES:NO;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self.delegate willCreateSample:[alertView textFieldAtIndex:0].text];
    }
}

@end
