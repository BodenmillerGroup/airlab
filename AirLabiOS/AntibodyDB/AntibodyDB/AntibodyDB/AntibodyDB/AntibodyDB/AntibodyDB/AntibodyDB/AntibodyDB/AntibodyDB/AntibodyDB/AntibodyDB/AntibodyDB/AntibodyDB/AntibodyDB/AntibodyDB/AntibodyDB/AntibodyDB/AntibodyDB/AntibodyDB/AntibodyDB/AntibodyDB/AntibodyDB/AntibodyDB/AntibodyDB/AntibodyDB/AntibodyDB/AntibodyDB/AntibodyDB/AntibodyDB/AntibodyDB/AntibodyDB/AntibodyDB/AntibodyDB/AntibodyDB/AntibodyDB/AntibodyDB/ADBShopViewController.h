//
//  ADBShopViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/10/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBRightControllerViewController.h"

@class ADBShopParsers;

@interface ADBShopViewController : ADBRightControllerViewController{
    ADBShopParsers *parserBrain;
}

-(IBAction)searchBiocompare:(NSString *)searchString;

@end
