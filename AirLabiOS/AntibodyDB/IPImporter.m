//
//  IPImporter.m
//  iPorra
//
//  Created by Raul Catena on 1/15/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "IPImporter.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "Person.h"


@interface IPImporter(){
    BOOL priorityMode;
}

@property (nonatomic, strong) NSMutableArray *syncArray;
@property (nonatomic, assign) int count;
@property (nonatomic, strong) NSDictionary *keysDictionary;
@property (nonatomic, strong) NSDictionary *linkerOperationsDictionary;
@property (nonatomic, strong) NSMutableArray *objectsInBatch;
@property (nonatomic, strong) NSMutableArray *downLoadedMaterials;
@property (nonatomic, strong) YBlock lastblock;


@property (nonatomic, strong) NSMutableDictionary *completers;
@property (nonatomic, strong) NSMutableArray *operationArray;
@property (nonatomic, strong) NSMutableArray *ongoingCalls;

@end

@implementation IPImporter

@synthesize managedObjectContext = _managedObjectContext;
@synthesize operationQueue = _operationQueue;
@synthesize completers = _completers;
@synthesize currentCompleters = _currentCompleters;
@synthesize block;
@synthesize count;
@synthesize keysDictionary = _keysDictionary;
@synthesize linkerOperationsDictionary = _linkerOperationsDictionary;
@synthesize objectsInBatch = _objectsInBatch;
@synthesize downLoadedMaterials = _downLoadedMaterials;

@synthesize numberOfAPIsConsumed = _numberOfAPIsConsumed;
@synthesize currentUser = _currentUser;


- (void)saveContexts:(YBlock)ablock{
    NSLog(@"Saving contexts");
    [self.managedObjectContext performBlock:^{
        
        NSError *childError = nil;
        if ([_managedObjectContext save:&childError]) {
            [[self managedObjectContext].parentContext performBlock:^{
                NSError *parentError = nil;
                if (![[self managedObjectContext].parentContext save:&parentError]) {
                    [[self managedObjectContext].parentContext rollback];
                    NSLog(@"Error saving parent %@", parentError);
                }
                if(ablock){
                    NSLog(@"Now should do checks");
                    ablock();
                }
            }];
        } else {
            NSLog(@"Error saving child %@", childError);
            if(ablock)ablock();
        }
    }];
}

-(NSManagedObjectContext *)managedObjectContext{
    if (!_managedObjectContext) {
        ADBAppDelegate *delegate = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
        _managedObjectContext = delegate.workerManagedObjectContext;
    }
    return _managedObjectContext;
}

-(void)cancelAll{
    self.ongoingCalls = [NSMutableArray array];
    self.syncArray = [NSMutableArray array];
    self.operationArray = [NSMutableArray array];
    [_operationQueue cancelAllOperations];
    self.completers = [NSMutableDictionary dictionary];
    _numberOfAPIsConsumed = 0;
}

-(NSOperationQueue *)operationQueue{
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc]init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return _operationQueue;
}

+ (IPImporter *)getInstance {
    static dispatch_once_t pred = 0;
    __strong static IPImporter* _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    _sharedObject.count = 0;
    _sharedObject.objectsInBatch = [NSMutableArray array];
    
    return _sharedObject;
}

-(void)setAcompleter:(NSString *)className withBlock:(void(^)())block{
    NSLog(@"Setting a completer %@", className);
    count++;
    if (!_completers) {
        self.completers = [NSMutableDictionary dictionary];
    }
    if (![_completers valueForKey:className]) {
        [_completers setValue:[NSNumber numberWithBool:YES] forKey:className];
    }
    if ([_ongoingCalls containsObject:className]) {
        [_ongoingCalls removeObjectIdenticalTo:className];
    }
}

-(void)tryPairs{
    
    if (!_operationArray) {
        self.operationArray = [NSMutableArray array];
    }

    if (!_linkerOperationsDictionary) {
        self.linkerOperationsDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"linkOperations" ofType:@"plist"]];
    }
    for (NSString *completerItem in self.completers.allKeys) {
        for (NSString *secondItem in self.completers.allKeys) {
            NSString *operationName = [NSString stringWithFormat:@"%@+%@", completerItem, secondItem];
            //NSLog(@"Operation to test %@", operationName);
            for(IPLinkerOperation *op in _operationArray){
                if([op.nameOfOp isEqualToString:operationName]){
                    //NSLog(@"Found %@", operationName);
                    continue;
                }
            }

            NSArray *instructionSets = [_linkerOperationsDictionary objectForKey:operationName];
            if (instructionSets) {
                //NSLog(@"The name of the operation is %@", operationName);
                for (NSDictionary *instructionsForOperation in instructionSets) {
                    IPLinkerOperation *operation = [[IPLinkerOperation alloc]initWithChildClass:[instructionsForOperation valueForKey:@"childClass"] childFK:[instructionsForOperation valueForKey:@"childFK"] parentClass:[instructionsForOperation valueForKey:@"parentClass"] propertyInChild:[instructionsForOperation valueForKey:@"propertyInChild"] andManagedObjectContext:self.managedObjectContext andKeysDictionary:self.keysDictionary];
                    operation.delegate = self;
                    [_operationArray addObject:operation];
                }
            }
        }
    }
    NSLog(@"Calls left %i", _numberOfAPIsConsumed);
    if (_numberOfAPIsConsumed == 0) {
        if (_operationArray.count > 0){// && _operationQueue.operationCount == 0) {
            IPLinkerOperation *operation = [_operationArray lastObject];
            [_operationArray removeLastObject];
            if (_numberOfAPIsConsumed <= 1) {//There is no time to set it to 0 (setAcompleter call is called first and reaches here, before counter acts)
                [self.operationQueue addOperation:operation];
                NSLog(@"Started operation queue");
                [General startBarSpinner];
            }else{
                NSLog(@"Counter is %i", _numberOfAPIsConsumed);
            }
        }
    }
}

-(void)updateDBAndConsolidateAndStopIndicator{
    [General stopBarSpinner];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"UPDATE_SUBSCRIPTION" object:nil];
    //dispatch_async(dispatch_get_main_queue(), ^{[(AppDelegate *)[[UIApplication sharedApplication]delegate]resetMOC];});
    ////CFRunLoopRunInMode((CFStringRef)NSDefaultRunLoopMode, 1, NO);
}

-(void)syncOperationFinishedWithCompleter:(NSString *)completer andProcessedObjects:(NSMutableArray *)processed andBlock:(void (^)())ablock{
    if(ablock)dispatch_async(dispatch_get_main_queue(), ablock);
    [self saveContexts:^{
        _numberOfAPIsConsumed--;
        self.objectsInBatch = processed;
        [self setAcompleter:completer withBlock:nil];
        
        IPFetchObjects *fetcher = [IPFetchObjects getInstance];
        [fetcher completedTask];
        dispatch_async(dispatch_get_main_queue(), ^{[General barIndicatorWithPercentage:[fetcher valueForProgress]];});
        
        
        IPSyncOperation *operation = [_syncArray lastObject];
        [_syncArray removeLastObject];
        [self.operationQueue addOperation:operation];
        
        if (_numberOfAPIsConsumed == 0) {
            [General stopBarSpinner];
            [self tryPairs];
        }
    }];
    
}

-(void)linkerOperationFinished{
    [self saveContexts:^{
        IPLinkerOperation *operation = [_operationArray lastObject];
        [_operationArray removeLastObject];
        [self.operationQueue addOperation:operation];
        
        NSLog(@"Operation queu is %lu and operation count %lu", (unsigned long)_operationArray.count, (unsigned long)_operationQueue.operationCount);
        if (_operationQueue.operationCount == 1) {
            
            IPFetchObjects *fetcher = [IPFetchObjects getInstance];
            [fetcher reset];
            
            [self updateDBAndConsolidateAndStopIndicator];
            
            if (block) {
                NSLog(@"Habemus block_________________?");
                if (block != _lastblock) {
                    _lastblock = block;
                    dispatch_async(dispatch_get_main_queue(), block);
                }
                //block();
            }else{
                NSLog(@"No habemus block________________XXXXX");
            }
        }
    }];
}


-(NSString *)keyOfObject:(NSString *)object{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"primaryKeys" ofType:@"plist"]];
    
    return [dict valueForKey:object];
}

-(void)processDataDirectly:(NSData *)data_ toObjectClasses:(NSArray *)objectClasses usingPK:(NSArray *)primaryKeys erasingOld:(NSArray *)eraseOldBoolsArray withCompletionBlock:(void(^)())ablock{
    
    if (!_ongoingCalls) {
        _ongoingCalls = [NSMutableArray array];
    }
    for (NSString *objectC in objectClasses) {
        if ([_ongoingCalls containsObject:objectC]) {
            return;
        }
        [_ongoingCalls addObject:objectC];
    }
    
    _numberOfAPIsConsumed = _numberOfAPIsConsumed + (int)objectClasses.count;
    self.block = ablock;
    //IPSyncOperation *operation = [[IPSyncOperation alloc]initWithData:data_ toObjectClasses:objectClasses usingPK:primaryKeys erasingOld:eraseOldBoolsArray withCompletionBlock:ablock];
    if(!data_)return;
    NSError *error;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data_ options:NSJSONReadingMutableContainers error:&error];
    if(!array || ![NSStringFromClass([NSArray class]) containsString:@"Array"])return;
    if (error) {
        [General logError:error];
    }else{
        IPSyncOperation *operation = [[IPSyncOperation alloc]initWithObjects:array toObjectClasses:objectClasses usingPK:primaryKeys erasingOld:eraseOldBoolsArray withCompletionBlock:ablock];
        operation.delegate = self;
        if (!_syncArray) {
            _syncArray = [NSMutableArray array];
        }
        if (_syncArray.count == 0) {
            [self.operationQueue addOperation:operation];
        }else
            [_syncArray addObject:operation];
        
        [General startBarSpinner];
    }
}


-(void)downloadObject:(NSArray *)objectClasses atAPI:(NSString *)apiSuffix usingPK:(NSArray *)primaryKeys andPost:(NSString *)post erasingOld:(NSArray *)eraseOldBoolsArray withCompletionBlock:(void(^)())ablock{
    
    if(priorityMode)return;
    
    self.block = ablock;
    
    if (!apiSuffix) {//This is for the case where I only call for linking all again
        for (NSString *class in objectClasses) {
            [self setAcompleter:class withBlock:nil];
        }
        return;
    }
    
    NSMutableURLRequest *request;
    if (post) {
        request = [General callToAPI:apiSuffix withPost:post];
        request.HTTPMethod = @"POST";
    }else{
        request = [General callToGetAPI:apiSuffix];
    }
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response_, NSData *data_, NSError *error_){
        if (!error_) {
            
            [self processDataDirectly:data_ toObjectClasses:objectClasses usingPK:primaryKeys erasingOld:eraseOldBoolsArray withCompletionBlock:ablock];
            
            _numberOfAPIsConsumed--;
            NSLog(@"number of APIS %i in call back", self.numberOfAPIsConsumed);
            
        }else{
            if(block)block();
        }
    }];
}


@end
