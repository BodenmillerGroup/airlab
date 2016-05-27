//
//  Step.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class Recipe;

@interface Step : Object

@property (nonatomic, retain) NSString * stpPosition;
@property (nonatomic, retain) NSString * stpRecipId;
@property (nonatomic, retain) NSString * stpStepId;
@property (nonatomic, retain) NSString * stpText;
@property (nonatomic, retain) NSString * stpTime;
@property (nonatomic, retain) Recipe *recipe;

@end
