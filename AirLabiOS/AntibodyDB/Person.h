//
//  Person.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class Group, ZGroupPerson;

@interface Person : Object

@property (nonatomic, retain) NSString * perEmail;
@property (nonatomic, retain) NSString * perLastname;
@property (nonatomic, retain) NSString * perName;
@property (nonatomic, retain) NSString * perPassword;
@property (nonatomic, retain) NSString * perPersonId;
@property (nonatomic, retain) NSNumber * zetIsCurrent;
@property (nonatomic, retain) NSSet *groupPersons;
@property (nonatomic, retain) NSSet *groups;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addGroupPersonsObject:(ZGroupPerson *)value;
- (void)removeGroupPersonsObject:(ZGroupPerson *)value;
- (void)addGroupPersons:(NSSet *)values;
- (void)removeGroupPersons:(NSSet *)values;

- (void)addGroupsObject:(Group *)value;
- (void)removeGroupsObject:(Group *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

@end
