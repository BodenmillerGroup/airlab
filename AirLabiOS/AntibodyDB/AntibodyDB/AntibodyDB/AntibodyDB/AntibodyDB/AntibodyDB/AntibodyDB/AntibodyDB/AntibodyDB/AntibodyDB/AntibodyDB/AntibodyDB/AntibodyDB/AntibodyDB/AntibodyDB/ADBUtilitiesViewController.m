    //
//  Gadgets.m
//  BenchPal
//
//  Created by Raul Catena on 5/10/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBUtilitiesViewController.h"
#import "ADBAllCounters.h"
#import "ADBTimers.h"
//#import "CellCounterViewController.h"
#import "ADBChemistryViewController.h"
#import "ADBSDSPageViewController.h"
#import "ADBDilutorViewController.h"
#import "ADBCalculadoraInterna.h"
//#import "GeneticCode.h"
//#import "PCRCalculator.h"
#import "ADBTemplaterViewController.h"
//#import "ColonyCounterViewController.h"

@interface ADBUtilitiesViewController()

@property (nonatomic, strong) NSArray *theObjects;

@end

@implementation ADBUtilitiesViewController


- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Gadgets";
    //self.clearsSelectionOnViewWillAppear = NO;
    
    [self setTheTableviewWithStyle:UITableViewStylePlain];
    
	//gadgetOptions = [NSArray arrayWithObjects:@"Timers", @"Calculator", @"Molarity Calculator", @"Dilution Calculator", @"DNA/RNA Calculator", @"PCR Calculator", @"Genetic code", @"Restriction Enzymes", @"Aminoacids",  @"Colony Counter", @"SDS-Page", @"Periodic Table", @"Blast", @"Cell Counter", @"QR Code scanner", @"Labels printer", @"Plate layout creator", nil];
    self.theObjects = [NSArray arrayWithObjects:@"Timers", @"Calculator", @"Chemistry Calculator", @"Dilution Calculator", @"Plate layout creator", nil];//@"DNA/RNA Calculator", @"PCR Calculator", @"Genetic code",  @"Blast", @"Cell Counter", @"Colony Counter",  nil];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [_theObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    
    [self setGrayColorInTableText:cell];
    cell.textLabel.text = [_theObjects objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

#define OPTIONS @"Timers", @"Calculator", @"Chemistry Calculator", @"Dilution Calculator", @"SDS-Page", @"Plate layout creator",@"PCR Calculator", @"Blast", @"Cell Counter", @"Colony Counter", nil];

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectedObject = [_theObjects objectAtIndex:indexPath.row];
	[[self.splitViewController.viewControllers objectAtIndex:1] setTitle:selectedObject];
    __block UIViewController *gadgetVC = nil;
    switch (indexPath.row){
        case 0:
            gadgetVC = [[ADBAllCounters alloc]init];
            break;
        case 1:
            gadgetVC = [[ADBCalculadoraInterna alloc]init];
            break;
        case 2:
            gadgetVC = [[ADBChemistryViewController alloc]init];
            break;
        case 3:
            gadgetVC = [[ADBDilutorCalculator alloc]init];
            break;
        case 4:
            [General iPhoneBlock:^{
                gadgetVC = [[ADBTemplaterViewController alloc]initWithNibName:@"ADBTemplaterViewControllerIPhone" bundle:nil];
            } iPadBlock:^{
                gadgetVC = [[ADBTemplaterViewController alloc]init];
            }];
            
            break;
        
        default:
            gadgetVC = [[ADBMasterViewController alloc]init];
            break;
    }
	[self.navigationController pushViewController:gadgetVC animated:YES];
}


@end
