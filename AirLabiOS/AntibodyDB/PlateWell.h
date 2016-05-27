//
//  PlateWell.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class Plate;

@interface PlateWell : Object

@property (nonatomic, retain) NSString * pwlPlateId;
@property (nonatomic, retain) NSString * pwlPlatewellId;
@property (nonatomic, retain) NSString * pwlPosition;
@property (nonatomic, retain) NSString * pwlText;
@property (nonatomic, retain) Plate *plate;

@end
