//
//  ADBShopParsers.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/10/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADBShopParsers : NSObject

-(NSArray *)parseData:(NSData *)data;
-(NSArray *)parseCategoryData:(NSData *)data;
-(NSArray *)parseProduct:(NSData *)data;
-(NSArray *)parseDataForProduct:(NSData *)data;

@end
