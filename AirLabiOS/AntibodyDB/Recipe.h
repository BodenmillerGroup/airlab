//
//  Recipe.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class RecipeObject, Step;

@interface Recipe : Object

@property (nonatomic, retain) NSString * rcpPurpose;
@property (nonatomic, retain) NSString * rcpRecipeId;
@property (nonatomic, retain) NSString * rcpTitle;
@property (nonatomic, retain) NSNumber * zetAnchor;
@property (nonatomic, retain) NSNumber * zetSecondsLeft;
@property (nonatomic, retain) NSSet *recipeObjects;
@property (nonatomic, retain) NSSet *steps;
@end

@interface Recipe (CoreDataGeneratedAccessors)

- (void)addRecipeObjectsObject:(RecipeObject *)value;
- (void)removeRecipeObjectsObject:(RecipeObject *)value;
- (void)addRecipeObjects:(NSSet *)values;
- (void)removeRecipeObjects:(NSSet *)values;

- (void)addStepsObject:(Step *)value;
- (void)removeStepsObject:(Step *)value;
- (void)addSteps:(NSSet *)values;
- (void)removeSteps:(NSSet *)values;

@end
