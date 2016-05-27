//
//  Protein.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class Clone, SpeciesProtein;

@interface Protein : Object

@property (nonatomic, retain) NSString * proDescription;
@property (nonatomic, retain) NSString * proKd;
@property (nonatomic, retain) NSString * proName;
@property (nonatomic, retain) NSString * proNcbiGeneID;
@property (nonatomic, retain) NSString * proProteinId;
@property (nonatomic, retain) NSString * proSwissDBID;
@property (nonatomic, retain) NSSet *clones;
@property (nonatomic, retain) NSSet *speciesProtein;
@end

@interface Protein (CoreDataGeneratedAccessors)

- (void)addClonesObject:(Clone *)value;
- (void)removeClonesObject:(Clone *)value;
- (void)addClones:(NSSet *)values;
- (void)removeClones:(NSSet *)values;

- (void)addSpeciesProteinObject:(SpeciesProtein *)value;
- (void)removeSpeciesProteinObject:(SpeciesProtein *)value;
- (void)addSpeciesProtein:(NSSet *)values;
- (void)removeSpeciesProtein:(NSSet *)values;

@end
