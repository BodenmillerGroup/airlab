//
//  Provider.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class ComertialReagent, Lot;

@interface Provider : Object

@property (nonatomic, retain) NSString * proAcronym;
@property (nonatomic, retain) NSString * proName;
@property (nonatomic, retain) NSString * proProviderId;
@property (nonatomic, retain) NSSet *lots;
@property (nonatomic, retain) NSSet *reagents;
@end

@interface Provider (CoreDataGeneratedAccessors)

- (void)addLotsObject:(Lot *)value;
- (void)removeLotsObject:(Lot *)value;
- (void)addLots:(NSSet *)values;
- (void)removeLots:(NSSet *)values;

- (void)addReagentsObject:(ComertialReagent *)value;
- (void)removeReagentsObject:(ComertialReagent *)value;
- (void)addReagents:(NSSet *)values;
- (void)removeReagents:(NSSet *)values;

@end
