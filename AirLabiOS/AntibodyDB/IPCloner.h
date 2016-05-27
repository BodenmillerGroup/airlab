//
//  IPCloner.h
// AirLab
//
//  Created by Raul Catena on 5/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPCloner : NSObject

+(NSManagedObject *)deepClone:(NSManagedObject *)source inContext:(NSManagedObjectContext *)context;
+(Object *)clone:(NSManagedObject *)source inContext:(NSManagedObjectContext *)context;

@end
