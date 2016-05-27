//
//  Plan.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class Ensayo, ZGroupPerson;

@interface Plan : Object

@property (nonatomic, retain) NSString * plnFinalDate;
@property (nonatomic, retain) NSString * plnPlanId;
@property (nonatomic, retain) NSString * plnTitle;
@property (nonatomic, retain) NSSet *ensayos;
@property (nonatomic, retain) NSSet *groupPersons;
@end

@interface Plan (CoreDataGeneratedAccessors)

- (void)addEnsayosObject:(Ensayo *)value;
- (void)removeEnsayosObject:(Ensayo *)value;
- (void)addEnsayos:(NSSet *)values;
- (void)removeEnsayos:(NSSet *)values;

- (void)addGroupPersonsObject:(ZGroupPerson *)value;
- (void)removeGroupPersonsObject:(ZGroupPerson *)value;
- (void)addGroupPersons:(NSSet *)values;
- (void)removeGroupPersons:(NSSet *)values;

@end
