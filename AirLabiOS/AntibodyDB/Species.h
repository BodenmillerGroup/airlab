//
//  Species.h
//  AirLab
//
//  Created by Raul Catena on 2/8/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class Clone;

@interface Species : Object

@property (nonatomic, retain) NSString * spcAcronym;
@property (nonatomic, retain) NSString * spcLinnaeus;
@property (nonatomic, retain) NSString * spcName;
@property (nonatomic, retain) NSString * spcProperAcronym;
@property (nonatomic, retain) NSString * spcSpeciesId;
@property (nonatomic, retain) NSSet *clonesIsHost;
@end

@interface Species (CoreDataGeneratedAccessors)

- (void)addClonesIsHostObject:(Clone *)value;
- (void)removeClonesIsHostObject:(Clone *)value;
- (void)addClonesIsHost:(NSSet *)values;
- (void)removeClonesIsHost:(NSSet *)values;

@end
