//
//  Ensayo.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class Lot, Part, Plan, ZLotEnsayo;

@interface Ensayo : Object

@property (nonatomic, retain) NSString * enyConclusions;
@property (nonatomic, retain) NSString * enyEnsayoId;
@property (nonatomic, retain) NSString * enyHypothesis;
@property (nonatomic, retain) NSString * enyPlanId;
@property (nonatomic, retain) NSString * enyPurpose;
@property (nonatomic, retain) NSString * enyTitle;
@property (nonatomic, retain) NSString * enyTubeValidatedId;
@property (nonatomic, retain) NSSet *lotEnsayos;
@property (nonatomic, retain) NSSet *parts;
@property (nonatomic, retain) Plan *plan;
@property (nonatomic, retain) Lot *tubeValidated;
@end

@interface Ensayo (CoreDataGeneratedAccessors)

- (void)addLotEnsayosObject:(ZLotEnsayo *)value;
- (void)removeLotEnsayosObject:(ZLotEnsayo *)value;
- (void)addLotEnsayos:(NSSet *)values;
- (void)removeLotEnsayos:(NSSet *)values;

- (void)addPartsObject:(Part *)value;
- (void)removePartsObject:(Part *)value;
- (void)addParts:(NSSet *)values;
- (void)removeParts:(NSSet *)values;

@end
