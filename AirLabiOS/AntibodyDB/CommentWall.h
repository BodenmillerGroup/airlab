//
//  CommentWall.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class CommentWall;

@interface CommentWall : Object

@property (nonatomic, retain) NSString * cwlComment;
@property (nonatomic, retain) NSString * cwlCommentWallId;
@property (nonatomic, retain) NSString * cwlParentId;
@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) CommentWall *parent;
@end

@interface CommentWall (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(CommentWall *)value;
- (void)removeChildrenObject:(CommentWall *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

@end
