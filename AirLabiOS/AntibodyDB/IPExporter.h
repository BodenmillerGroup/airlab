//
//  IPExporter.h
//  iPorra
//
//  Created by Raul Catena on 1/27/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Porra;
@class User;
@class UserPorra;
@class Guess;
@class Object;

@interface IPExporter : NSObject

-(void)delayedPushOfObjectTypes:(NSString *)type withSortDescriptorKey:(NSString *)sort withBlock:(void(^)(NSURLResponse *, NSData *, NSError *))someBlock;
-(void)aTestBlock:(void(^)(NSString *))someBlock;
-(void)uploadInfoForNewObject:(Object *)newObject withBlock:(void(^)(NSURLResponse *, NSData *, NSError *))someBlock;
-(void)uploadNewObject:(Object *)newObject withBlock:(void(^)(NSURLResponse *, NSData *, NSError *))someBlock;
-(void)updateInfoForObject:(Object *)object withBlock:(void(^)(NSURLResponse *, NSData *, NSError *))someBlock;
-(void)updateObject:(Object *)newObject withBlock:(void(^)(NSURLResponse *, NSData *, NSError *))someBlock;
-(void)deleteObject:(Object *)object withBlock:(void(^)(NSURLResponse *, NSData *, NSError *))someBlock;
-(void)intialDeleteObject:(Object *)object;

+(IPExporter *)getInstance;
-(void)start;

-(void)pause;
-(void)resume;

@end
