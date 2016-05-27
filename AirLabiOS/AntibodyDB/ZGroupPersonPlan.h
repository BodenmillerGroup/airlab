//
//  ZGroupPersonPlan.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"


@interface ZGroupPersonPlan : Object

@property (nonatomic, retain) NSString * gppGroupPersonId;
@property (nonatomic, retain) NSString * gppGroupPersonPlanId;
@property (nonatomic, retain) NSString * gppPlanId;

@end
