//
//  ADBShopResultsViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/10/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBShopResultsViewController.h"
#import "ADBShopParsers.h"
#import "ADBItemInfoViewController.h"

@interface ADBShopResultsViewController (){
    BOOL isAntibody;
}

@end

@implementation ADBShopResultsViewController

@synthesize urlCat = _urlCat;
@synthesize results = _results;
@synthesize catResults = _catResults;

/*-(void)setResults:(NSArray *)results{
    _results = results;
    _catResults = nil;
}

-(void)setCatResults:(NSArray *)catResults{
    _catResults = catResults;
    _results = nil;
}*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)url
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.urlCat = url;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andResults:(NSArray *)results{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.results = results;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(_urlCat){
        [self searchBiocompareCategory:_urlCat];
    }else{
        self.navigationItem.backBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(backToHomeInNavCon)];
    }
}

#pragma tableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int count;
    if(self.results){
            count = (int)[[self.results lastObject]count];
    }
    else if(self.catResults){
        count = (int)[self.catResults.lastObject count];
    }else{
        count = 0;
    }
    return count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"CloneCell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    if(self.results){
        cell.textLabel.text = [[self.results objectAtIndex:0]objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = @"";
    }
    if(self.catResults){
        cell.textLabel.text = [[self.catResults objectAtIndex:0]objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [[self.catResults objectAtIndex:1]objectAtIndex:indexPath.row];
    }
    [self setGrayColorInTableText:cell];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:self.tableView didSelectRowAtIndexPath:indexPath];

    if(self.results){
        ADBShopResultsViewController *results = [[ADBShopResultsViewController alloc]initWithNibName:nil bundle:nil andUrl:[[self.results objectAtIndex:1]objectAtIndex:indexPath.row]];
        results.title = [NSString stringWithFormat:@"%@ | %@", [self.results objectAtIndex:0], self.title];
        [self.navigationController pushViewController:results animated:YES];
    }
    if(self.catResults){
        ADBItemInfoViewController *item = [[ADBItemInfoViewController alloc]initWithNibName:nil bundle:nil withUrl:[[self.catResults objectAtIndex:2]objectAtIndex:indexPath.row]];
        item.isAntibody = isAntibody;
        item.title = [NSString stringWithFormat:@"Product description: %@", [[self.catResults objectAtIndex:0]objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:item animated:YES];
    }
    
}

#pragma mark biocompare


-(void)searchBiocompare:(UITextField *)searchField{
    
    if(!parserBrain){
        parserBrain = [[ADBShopParsers alloc]init];
    }
	
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable)[self noInternetConnection];
    else{
        [self startNavBarSpinner];
        NSString *plusString = [searchField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSMutableString *finalURL = [NSMutableString stringWithFormat:@"http://www.biocompare.com/General-Search/?search=%@", plusString];
        NSMutableURLRequest *request = [General callToGetAPI:finalURL];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response_, NSData *data_, NSError *error_){
            if(error_){
                [self errorInternetConnection];
            }else{
                self.results = [parserBrain parseData:data_];
                [self.tableView reloadData];
            }
            [self stopNavBarSpinner];
        }];
    }
}

-(void)searchBiocompareCategory:(NSString *)suffix{
	
    if(!parserBrain){
        parserBrain = [[ADBShopParsers alloc]init];
    }
    
    if ([suffix rangeOfString:@"Antibodies"].length > 0) {
        isAntibody = YES;
    }else{
        isAntibody = NO;
    }
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable)[self noInternetConnection];
    else{
        [self startNavBarSpinner];
        NSString *string = [NSString stringWithFormat:@"http://www.biocompare.com%@", suffix];
        NSMutableURLRequest *request = [General callToGetAPI:string];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response_, NSData *data_, NSError *error_){
            if(error_){
                [self errorInternetConnection];
            }else{
                self.catResults = [parserBrain parseCategoryData:data_];
                [self.tableView reloadData];
            }
            [self stopNavBarSpinner];
        }];
    }
}

@end
