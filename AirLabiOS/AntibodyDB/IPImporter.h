//
//  IPImporter.h
//  iPorra
//
//  Created by Raul Catena on 1/15/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPLinkerOperation.h"
#import "IPSyncOperation.h"

@class User;

typedef void (^YBlock)();

@interface IPImporter : NSObject <LinkerOperationDelegate, SyncOperationDelegate>{
            
    dispatch_queue_t linkerQueue;
    
}

@property (nonatomic, strong) YBlock block;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, assign) int numberOfAPIsConsumed;
@property (nonatomic, strong) NSArray *currentCompleters;
@property (nonatomic, strong) User *currentUser;


-(void)downloadObject:(NSArray *)objectClasses atAPI:(NSString *)apiSuffix usingPK:(NSArray *)primaryKeys andPost:(NSString *)post erasingOld:(NSArray *)eraseOldBoolsArray withCompletionBlock:(void(^)())block;//0 is no unless first time, 1 is depending on date (1 day), 2 is always
//If I have downloaded from elsewhere
-(void)processDataDirectly:(NSData *)data_ toObjectClasses:(NSArray *)objectClasses usingPK:(NSArray *)primaryKeys erasingOld:(NSArray *)eraseOldBoolsArray withCompletionBlock:(void(^)())ablock;
+(IPImporter *)getInstance;

-(void)setAcompleter:(NSString *)className withBlock:(void(^)())block;
-(void)tryPairs;
-(NSString *)keyOfObject:(NSString *)object;

-(void)cancelAll;
- (void)saveContexts:(YBlock)ablock;


@end
