//
//  Object.h
//  AirLab
//
//  Created by Raul Catena on 8/14/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class File, Part, RecipeObject, ZGroupPerson;

@interface Object : NSManagedObject

@property (nonatomic, retain) NSString * catchedInfo;
@property (nonatomic, retain) NSString * classTag;
@property (nonatomic, retain) NSString * createdAt;
@property (nonatomic, retain) NSString * createdBy;
@property (nonatomic, retain) NSString * deleted;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * inactivatedAt;
@property (nonatomic, retain) NSString * inactivatedBy;
@property (nonatomic, retain) NSString * offlineId;
@property (nonatomic, retain) NSString * openBisCode;
@property (nonatomic, retain) NSString * openBisJSON;
@property (nonatomic, retain) NSString * openBisPermId;
@property (nonatomic, retain) NSString * zetAPI;
@property (nonatomic, retain) NSNumber * zetCounterDeletePost;
@property (nonatomic, retain) NSNumber * zetCounterPost;
@property (nonatomic, retain) NSString * zetDeleteAPI;
@property (nonatomic, retain) NSString * zetDeletePost;
@property (nonatomic, retain) NSString * zetPost;
@property (nonatomic, retain) NSString * objectPictureId;
@property (nonatomic, retain) ZGroupPerson *groupPerson;
@property (nonatomic, retain) ZGroupPerson *groupPersonInactivating;
@property (nonatomic, retain) NSSet *partss;
@property (nonatomic, retain) NSSet *recipeObjectsO;
@end

@interface Object (CoreDataGeneratedAccessors)

- (void)addPartssObject:(Part *)value;
- (void)removePartssObject:(Part *)value;
- (void)addPartss:(NSSet *)values;
- (void)removePartss:(NSSet *)values;

- (void)addRecipeObjectsOObject:(RecipeObject *)value;
- (void)removeRecipeObjectsOObject:(RecipeObject *)value;
- (void)addRecipeObjectsO:(NSSet *)values;
- (void)removeRecipeObjectsO:(NSSet *)values;

@end
