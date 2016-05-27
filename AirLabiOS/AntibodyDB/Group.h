//
//  Group.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class Person, ZGroupPerson;

@interface Group : Object

@property (nonatomic, retain) NSString * grpCoordinates;
@property (nonatomic, retain) NSString * grpGroupId;
@property (nonatomic, retain) NSString * grpInstitution;
@property (nonatomic, retain) NSString * grpName;
@property (nonatomic, retain) NSString * grpUrl;
@property (nonatomic, retain) NSString * grpAcceptRequests;
@property (nonatomic, retain) NSSet *groupPersons;
@property (nonatomic, retain) NSSet *persons;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addGroupPersonsObject:(ZGroupPerson *)value;
- (void)removeGroupPersonsObject:(ZGroupPerson *)value;
- (void)addGroupPersons:(NSSet *)values;
- (void)removeGroupPersons:(NSSet *)values;

- (void)addPersonsObject:(Person *)value;
- (void)removePersonsObject:(Person *)value;
- (void)addPersons:(NSSet *)values;
- (void)removePersons:(NSSet *)values;

@end
