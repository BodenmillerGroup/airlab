//
//  ComertialReagent.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class Provider, ReagentInstance;

@interface ComertialReagent : Object

@property (nonatomic, retain) NSString * comComertialReagentId;
@property (nonatomic, retain) NSString * comName;
@property (nonatomic, retain) NSString * comProviderId;
@property (nonatomic, retain) NSString * comReference;
@property (nonatomic, retain) Provider *provider;
@property (nonatomic, retain) NSSet *reagentInstances;
@end

@interface ComertialReagent (CoreDataGeneratedAccessors)

- (void)addReagentInstancesObject:(ReagentInstance *)value;
- (void)removeReagentInstancesObject:(ReagentInstance *)value;
- (void)addReagentInstances:(NSSet *)values;
- (void)removeReagentInstances:(NSSet *)values;

@end
