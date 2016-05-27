//
//  File.h
//  AirLab
//
//  Created by Raul Catena on 8/14/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class Object, ZFilePart;

@interface File : Object

@property (nonatomic, retain) NSString * filExtension;
@property (nonatomic, retain) NSString * filFileId;
@property (nonatomic, retain) NSString * filHash;
@property (nonatomic, retain) NSString * filPartId;
@property (nonatomic, retain) NSString * filSize;
@property (nonatomic, retain) NSString * filURL;
@property (nonatomic, retain) NSData * zetData;
@property (nonatomic, retain) NSData * zetUploadData;
@property (nonatomic, retain) NSSet *fileparts;
@end

@interface File (CoreDataGeneratedAccessors)

- (void)addFilepartsObject:(ZFilePart *)value;
- (void)removeFilepartsObject:(ZFilePart *)value;
- (void)addFileparts:(NSSet *)values;
- (void)removeFileparts:(NSSet *)values;

@end
