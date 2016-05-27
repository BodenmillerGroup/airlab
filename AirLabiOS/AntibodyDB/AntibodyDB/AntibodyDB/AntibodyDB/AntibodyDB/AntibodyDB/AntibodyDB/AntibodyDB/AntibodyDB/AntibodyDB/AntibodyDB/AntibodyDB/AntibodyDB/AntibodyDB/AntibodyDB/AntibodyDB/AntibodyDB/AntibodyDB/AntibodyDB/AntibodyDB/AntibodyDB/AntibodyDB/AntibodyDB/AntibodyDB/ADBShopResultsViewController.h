//
//  ADBShopResultsViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/10/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBRightControllerViewController.h"

@class ADBShopParsers;

@interface ADBShopResultsViewController : ADBRightControllerViewController{
    ADBShopParsers *parserBrain;
}

@property (nonatomic, strong) NSString *urlCat;
@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) NSArray *catResults;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)url;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andResults:(NSArray *)results;
-(void)searchBiocompare:(UITextField *)searchField;

@end
