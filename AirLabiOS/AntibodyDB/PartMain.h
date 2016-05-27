//
//  PartMain.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"


@interface PartMain : Object

@property (nonatomic, retain) NSString * prmObjectId;
@property (nonatomic, retain) NSString * prmObjectType;
@property (nonatomic, retain) NSString * prmPartId;
@property (nonatomic, retain) NSString * prmPartMainId;

@end
