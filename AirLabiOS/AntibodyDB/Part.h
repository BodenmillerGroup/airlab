//
//  Part.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class Ensayo, Object, ZFilePart;

@interface Part : Object

@property (nonatomic, retain) NSString * prtClosedAt;
@property (nonatomic, retain) NSString * prtEnsayoId;
@property (nonatomic, retain) NSString * prtFileXtension;
@property (nonatomic, retain) NSString * prtPartId;
@property (nonatomic, retain) NSString * prtPosition;
@property (nonatomic, retain) NSString * prtText;
@property (nonatomic, retain) NSString * prtTitle;
@property (nonatomic, retain) NSString * prtType;
@property (nonatomic, retain) NSNumber * zetUnscrolled;
@property (nonatomic, retain) Ensayo *ensayo;
@property (nonatomic, retain) NSSet *fileparts;
@property (nonatomic, retain) NSSet *objects;
@end

@interface Part (CoreDataGeneratedAccessors)

- (void)addFilepartsObject:(ZFilePart *)value;
- (void)removeFilepartsObject:(ZFilePart *)value;
- (void)addFileparts:(NSSet *)values;
- (void)removeFileparts:(NSSet *)values;

- (void)addObjectsObject:(Object *)value;
- (void)removeObjectsObject:(Object *)value;
- (void)addObjects:(NSSet *)values;
- (void)removeObjects:(NSSet *)values;

@end
