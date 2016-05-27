//
//  ZGroupPerson.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class CommentWall, Group, Object, Person, Plan, ReagentInstance, Tube;

@interface ZGroupPerson : Object

@property (nonatomic, retain) NSString * gpeErase;
@property (nonatomic, retain) NSString * gpeFinances;
@property (nonatomic, retain) NSString * gpeGroupId;
@property (nonatomic, retain) NSString * gpeGroupPersonId;
@property (nonatomic, retain) NSString * gpeOrders;
@property (nonatomic, retain) NSString * gpePersonId;
@property (nonatomic, retain) NSString * gpeRole;
@property (nonatomic, retain) NSString * gpeActiveInGroup;
@property (nonatomic, retain) NSString * gpeAllPanels;
@property (nonatomic, retain) NSNumber * zetIsCurrent;
@property (nonatomic, retain) NSSet *approvedOrders;
@property (nonatomic, retain) NSSet *commentWalls;
@property (nonatomic, retain) NSSet *finishedTubes;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) Object *inactivatedObjects;
@property (nonatomic, retain) NSSet *objects;
@property (nonatomic, retain) NSSet *orderedOrders;
@property (nonatomic, retain) Person *person;
@property (nonatomic, retain) NSSet *plans;
@property (nonatomic, retain) NSSet *receivedOrders;
@property (nonatomic, retain) NSSet *requestedOrders;
@end

@interface ZGroupPerson (CoreDataGeneratedAccessors)

- (void)addApprovedOrdersObject:(ReagentInstance *)value;
- (void)removeApprovedOrdersObject:(ReagentInstance *)value;
- (void)addApprovedOrders:(NSSet *)values;
- (void)removeApprovedOrders:(NSSet *)values;

- (void)addCommentWallsObject:(CommentWall *)value;
- (void)removeCommentWallsObject:(CommentWall *)value;
- (void)addCommentWalls:(NSSet *)values;
- (void)removeCommentWalls:(NSSet *)values;

- (void)addFinishedTubesObject:(Tube *)value;
- (void)removeFinishedTubesObject:(Tube *)value;
- (void)addFinishedTubes:(NSSet *)values;
- (void)removeFinishedTubes:(NSSet *)values;

- (void)addObjectsObject:(Object *)value;
- (void)removeObjectsObject:(Object *)value;
- (void)addObjects:(NSSet *)values;
- (void)removeObjects:(NSSet *)values;

- (void)addOrderedOrdersObject:(ReagentInstance *)value;
- (void)removeOrderedOrdersObject:(ReagentInstance *)value;
- (void)addOrderedOrders:(NSSet *)values;
- (void)removeOrderedOrders:(NSSet *)values;

- (void)addPlansObject:(Plan *)value;
- (void)removePlansObject:(Plan *)value;
- (void)addPlans:(NSSet *)values;
- (void)removePlans:(NSSet *)values;

- (void)addReceivedOrdersObject:(ReagentInstance *)value;
- (void)removeReceivedOrdersObject:(ReagentInstance *)value;
- (void)addReceivedOrders:(NSSet *)values;
- (void)removeReceivedOrders:(NSSet *)values;

- (void)addRequestedOrdersObject:(ReagentInstance *)value;
- (void)removeRequestedOrdersObject:(ReagentInstance *)value;
- (void)addRequestedOrders:(NSSet *)values;
- (void)removeRequestedOrders:(NSSet *)values;

@end
