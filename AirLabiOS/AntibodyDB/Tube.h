//
//  Tube.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class Place, ZGroupPerson;

@interface Tube : Object

@property (nonatomic, retain) NSString * tubAmount;
@property (nonatomic, retain) NSString * tubIsLow;
@property (nonatomic, retain) NSString * tubPlaceId;
@property (nonatomic, retain) NSString * tubTubeId;
@property (nonatomic, retain) NSString * tubType;
@property (nonatomic, retain) NSString * tubVolume;
@property (nonatomic, retain) NSString * tubVolumeInit;
@property (nonatomic, retain) NSString * tubFinishedBy;
@property (nonatomic, retain) NSString * tubFinishedAt;
@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) ZGroupPerson *finisher;

@end
