//
//  ADBItemInfoViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/10/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBRightControllerViewController.h"
#import "ADBPurchaseBoxViewController.h"

@class ADBShopParsers;

@interface ADBItemInfoViewController : ADBRightControllerViewController <PurchaseBoxProtocol>{
    ADBShopParsers *parserBrain;
}

@property (nonatomic, assign) BOOL isAntibody;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withUrl:(NSString *)url;

@end
