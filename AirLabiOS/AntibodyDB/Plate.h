//
//  Plate.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class PlateWell;

@interface Plate : Object

@property (nonatomic, retain) NSString * plaColumns;
@property (nonatomic, retain) NSString * plaPlateId;
@property (nonatomic, retain) NSString * plaPlateName;
@property (nonatomic, retain) NSString * plaRows;
@property (nonatomic, retain) NSSet *wells;
@end

@interface Plate (CoreDataGeneratedAccessors)

- (void)addWellsObject:(PlateWell *)value;
- (void)removeWellsObject:(PlateWell *)value;
- (void)addWells:(NSSet *)values;
- (void)removeWells:(NSSet *)values;

@end
