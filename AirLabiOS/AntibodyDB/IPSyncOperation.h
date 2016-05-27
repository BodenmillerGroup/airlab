//
//  IPSyncOperation.h
// AirLab
//
//  Created by Raul Catena on 6/14/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SyncOperationDelegate <NSObject>

-(void)syncOperationFinishedWithCompleter:(NSString *)completer andProcessedObjects:(NSMutableArray *)processed andBlock:(void(^)())ablock;

@end

@interface IPSyncOperation : NSOperation

@property (nonatomic, assign) id<SyncOperationDelegate>delegate;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSArray *objectClasses;

-(id)initWithObjects:(NSArray *)objects toObjectClasses:(NSArray *)objectClasses usingPK:(NSArray *)primaryKeys erasingOld:(NSArray *)eraseOldBoolsArray withCompletionBlock:(void(^)())ablock;

@end


