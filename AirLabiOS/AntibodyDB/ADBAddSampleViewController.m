//
//  ADBAddSampleViewController.m
// AirLab
//
//  Created by Raul Catena on 6/16/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddSampleViewController.h"

@interface ADBAddSampleViewController ()

@property (nonatomic, strong) NSMutableArray *options;

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

-(void)filter:(NSString *)searchTerm{NSLog(@"__________");
    self.filtered = nil;
    for (NSString *string in _options) {
        if ([string.lowercaseString rangeOfString:searchTerm].length > 0) {
            if (!self.filtered) {
                self.filtered = [NSMutableArray arrayWithCapacity:_options.count];
            }
            [self.filtered addObject:string];
        }
    }
}
    
-(void)allOptions{
    self.options = [NSMutableArray arrayWithArray:@[@"Chemical",
                                                    @"Parafin Block",
                                                    @"Section",
                                                    @"Cell line",
                                                    @"DNA",
                                                    @"RNA",
                                                    @"Protein",
                                                    @"Snap Frozen Tissue",
                                                    @"Hybridoma",
                                                    @"Antibody",
                                                    @"Primer",
                                                    @"PCR Primer set",
                                                    @"Plasmid Prep",
                                                    @"Recombinant Protein",
                                                    @"Fixed tissue block",
                                                    @"Virus Prep",
                                                    @"Blood/Serum/Plasma",
                                                    @"Mouse",
                                                    @"Monkey",
                                                    @"Rat",
                                                    @"Minipig",
                                                    @"Zebra Fish",
                                                    @"Bacteria",
                                                    @"Yeast",
                                                    @"Seed",
                                                    @"Plant",
                                                    @"Fly",
                                                    @"Other..."]];
    [self addOtherTypes];
}

-(void)addOtherTypes{
    NSArray *allSamples = [General searchDataBaseForClass:SAMPLE_DB_CLASS sortBy:[[IPImporter getInstance]keyOfObject:SAMPLE_DB_CLASS] ascending:YES inMOC:self.managedObjectContext];
    for (Sample *sample in allSamples) {
        if (![_options containsObject:sample.samType]) {
            if(sample.samType.length > 0)
            [_options insertObject:sample.samType.copy atIndex:0];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self allOptions];
    self.filtered = self.options;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filtered.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *type = @"TyepCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:type];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:type];
    }
    
    cell.textLabel.text = [self.filtered objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == self.filtered.count - 1){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Sample Type" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
        return;
    }
    [self.delegate willCreateSample:[self.filtered objectAtIndex:indexPath.row]];
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    return [alertView textFieldAtIndex:0].text.length > 0? YES:NO;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self.delegate willCreateSample:[alertView textFieldAtIndex:0].text];
    }
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    if (searchText != nil) {
        [self filter:searchText];
        
    }else {
        self.filtered = self.options;
    }
    [self refreshTable];
    self.searchDisplayController.searchBar.showsCancelButton = YES;
}

@end
