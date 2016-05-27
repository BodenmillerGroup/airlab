//
//  ADBShopViewController.m
// AirLab
//
//  Created by Raul Catena on 5/10/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBShopViewController.h"
#import "ADBShopResultsViewController.h"
#import "ADBShopParsers.h"

@interface ADBShopViewController ()

@property (nonatomic, strong) NSArray * searchResult;

@end

@implementation ADBShopViewController

@synthesize searchResult = _searchResult;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
                ADBShopResultsViewController *results = [[ADBShopResultsViewController alloc]initWithNibName:nil bundle:nil andResults:[parserBrain parseData:data_]];
                results.title = searchField.text;
                [self.navigationController pushViewController:results animated:YES];
            }
            [self stopNavBarSpinner];
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Shop reagents";
}

@end
