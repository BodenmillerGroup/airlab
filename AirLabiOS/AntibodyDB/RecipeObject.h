//
//  RecipeObject.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class Object, Recipe;

@interface RecipeObject : Object

@property (nonatomic, retain) NSString * rcmObjectId;
@property (nonatomic, retain) NSString * rcmObjectType;
@property (nonatomic, retain) NSString * rcmRecipeId;
@property (nonatomic, retain) NSString * rcmRecipeObjectId;
@property (nonatomic, retain) Object *object;
@property (nonatomic, retain) Recipe *recipe;

@end
