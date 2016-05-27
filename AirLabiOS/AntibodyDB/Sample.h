//
//  Sample.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Tube.h"

@class ReagentInstance, Sample;

@interface Sample : Tube

@property (nonatomic, retain) NSString * samAmount;
@property (nonatomic, retain) NSString * samConcentration;
@property (nonatomic, retain) NSString * samData;
@property (nonatomic, retain) NSString * samName;
@property (nonatomic, retain) NSString * samParentId;
@property (nonatomic, retain) NSString * samReagentInstanceId;
@property (nonatomic, retain) NSString * samSampleId;
@property (nonatomic, retain) NSString * samType;
@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) Sample *parent;
@property (nonatomic, retain) ReagentInstance *reatentInstance;
@end

@interface Sample (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(Sample *)value;
- (void)removeChildrenObject:(Sample *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

@end
