//
//  Place.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class Place, Tube;

@interface Place : Object

@property (nonatomic, retain) NSString * plaColumns;
@property (nonatomic, retain) NSString * plaName;
@property (nonatomic, retain) NSString * plaParentId;
@property (nonatomic, retain) NSString * plaPlaceId;
@property (nonatomic, retain) NSString * plaRows;
@property (nonatomic, retain) NSString * plaSelves;
@property (nonatomic, retain) NSString * plaType;
@property (nonatomic, retain) NSString * plaX;
@property (nonatomic, retain) NSString * plaY;
@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) Place *parent;
@property (nonatomic, retain) NSSet *tubes;
@end

@interface Place (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(Place *)value;
- (void)removeChildrenObject:(Place *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

- (void)addTubesObject:(Tube *)value;
- (void)removeTubesObject:(Tube *)value;
- (void)addTubes:(NSSet *)values;
- (void)removeTubes:(NSSet *)values;

@end
