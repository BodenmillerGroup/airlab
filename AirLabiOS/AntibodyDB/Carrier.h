//
//  Carrier.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class Lot;

@interface Carrier : Object

@property (nonatomic, retain) NSString * carCarrierId;
@property (nonatomic, retain) NSString * carName;
@property (nonatomic, retain) NSSet *lots;
@end

@interface Carrier (CoreDataGeneratedAccessors)

- (void)addLotsObject:(Lot *)value;
- (void)removeLotsObject:(Lot *)value;
- (void)addLots:(NSSet *)values;
- (void)removeLots:(NSSet *)values;

@end
