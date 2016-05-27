//
//  ZFilePart.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class File, Part;

@interface ZFilePart : Object

@property (nonatomic, retain) NSString * fptFileId;
@property (nonatomic, retain) NSString * fptFilePartId;
@property (nonatomic, retain) NSString * fptPartId;
@property (nonatomic, retain) File *file;
@property (nonatomic, retain) Part *part;

@end
