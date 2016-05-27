//
//  Clone.h
//  AirLab
//
//  Created by Raul Catena on 2/8/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class Lot, Protein, Species;

@interface Clone : Object

@property (nonatomic, retain) NSString * cloApplication;
@property (nonatomic, retain) NSString * cloBindingRegion;
@property (nonatomic, retain) NSString * cloCloneId;
@property (nonatomic, retain) NSString * cloEpitopeId;
@property (nonatomic, retain) NSString * cloIsotype;
@property (nonatomic, retain) NSString * cloIsPhospho;
@property (nonatomic, retain) NSString * cloIsPolyclonal;
@property (nonatomic, retain) NSString * cloName;
@property (nonatomic, retain) NSString * cloProteinId;
@property (nonatomic, retain) NSString * cloReactivity;
@property (nonatomic, retain) NSString * cloSpeciesHost;
@property (nonatomic, retain) NSSet *lots;
@property (nonatomic, retain) Protein *protein;
@property (nonatomic, retain) Species *speciesHost;
@end

@interface Clone (CoreDataGeneratedAccessors)

- (void)addLotsObject:(Lot *)value;
- (void)removeLotsObject:(Lot *)value;
- (void)addLots:(NSSet *)values;
- (void)removeLots:(NSSet *)values;

@end
