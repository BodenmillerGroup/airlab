//
//  IPExporter.m
//  iPorra
//
//  Created by Raul Catena on 1/27/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "IPExporter.h"
//#import "IPLogInViewController.h"

#define ATTEMPTS_SERVER 8

@interface IPExporter(){
    BOOL paused;
}

@property (nonatomic, strong) NSDictionary *keysDictionary;

@end

@implementation IPExporter

#pragma push up to server

+ (IPExporter *)getInstance {
    static dispatch_once_t pred = 0;
    __strong static IPExporter* _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

-(void)start{
    [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(tryNonUploaded) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(tryNonUploadedFiles) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(tryNonDeleted) userInfo:nil repeats:YES];
}

-(void)pause{
    paused = YES;
}

-(void)resume{
    paused = NO;
}

+(NSString *)apiForObject:(Object *)object{
    NSString *api;
    
    if (![object isKindOfClass:[Object class]]) {
        return nil;
    }
    
    NSString *type = NSStringFromClass([object class]);
    api = type.lowercaseString;
    
    return api;
}



-(void)processArrivedNewObject:(Object *)newObject withId:(int)theInt{
    NSDictionary *dict  = [[newObject entity]relationshipsByName];
    for(NSString *rel in dict.allKeys){
        id object = [newObject valueForKey:rel];
        
        if(object && [object isKindOfClass:[Object class]]){
            
            NSArray *atts = [[object entity]attributesByName].allKeys;
            for(NSString *att in atts){
                if ([[object valueForKey:att]isKindOfClass:[NSString class]]) {
                    if([[object valueForKey:att]isEqualToString:[newObject offlineId]]){
                        NSLog(@"OOOOOOOOOOOOOO------------------------------XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX %@", att);
                        if ([att hasPrefix:@"zet"])continue;
                        [object setValue:[NSString stringWithFormat:@"%i", theInt] forKey:att];
                        if([object valueForKey:[self keyOfObject:NSStringFromClass([object class])]])
                            [self updateInfoForObject:object withBlock:nil];
                        else
                            [self uploadInfoForNewObject:object withBlock:nil];
                    }
                }
                
            }
        }else if(![object class]){
            
        }else{
            NSMutableSet *sourceSet = [newObject mutableSetValueForKey:rel];
            for(Object *obj in sourceSet){
                NSLog(@"Soy un %@ %@ unido a %@ %i", NSStringFromClass([obj class]), [obj valueForKey:[[IPImporter getInstance]keyOfObject:NSStringFromClass([obj class])]], NSStringFromClass([newObject class]), theInt);
                NSArray *atts = [[obj entity]attributesByName].allKeys;
                for(NSString *att in atts){
                    if ([[obj valueForKey:att]isKindOfClass:[NSString class]]) {
                        if([[obj valueForKey:att]isEqualToString:[newObject offlineId]]){
                            NSLog(@"XXXXXXXXXX------------------------------XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
                            [obj setValue:[NSString stringWithFormat:@"%i", theInt] forKey:att];
                            if([obj valueForKey:[self keyOfObject:NSStringFromClass([obj class])]])
                                [self updateInfoForObject:obj withBlock:nil];
                            else [self uploadInfoForNewObject:obj withBlock:nil];
                        }
                    }
                }
            }
        }
    }
    [General saveContextAndRoll];
}

-(void)uploadInfoForNewObject:(Object *)newObject withBlock:(void(^)(NSURLResponse *, NSData *, NSError *))someBlock{
    
    if ([newObject valueForKey:[[IPImporter getInstance]keyOfObject:NSStringFromClass([newObject class])]]) {
        NSLog(@"Object %@ has id %@", NSStringFromClass([newObject class]), [[IPImporter getInstance]keyOfObject:NSStringFromClass([newObject class])]);
        return;
    }
    
    newObject.zetPost = nil;
    
    NSArray *keys = [[[newObject entity] attributesByName] allKeys];
    NSMutableArray *filteredKey = [NSMutableArray arrayWithCapacity:keys.count];
    for(NSString *akey in keys){
        if(![akey hasPrefix:@"zet"])[filteredKey addObject:akey];
    }
    //[keys removeObject:@"zetPost"];
    NSDictionary *dict = [newObject dictionaryWithValuesForKeys:filteredKey];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];if(error)[General logError:error];
    NSString *postString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSString *post = [NSString stringWithFormat:@"data=%@", postString];
    post = [post stringByReplacingOccurrencesOfString:@"&" withString:@""];//TODO, right UTF
    post = [post stringByReplacingOccurrencesOfString:@"?" withString:@""];
    
    post = [post stringByAppendingString:[NSString stringWithFormat:@"&%@", [[ADBAccountManager sharedInstance]postForGroup]]];
    
    newObject.zetAPI = [IPExporter apiForObject:newObject];
    newObject.zetPost = post;
    
    [General saveContextAndRoll];
    
}


-(void)updateInfoForObject:(Object *)object withBlock:(void(^)(NSURLResponse *, NSData *, NSError *))someBlock{
    if ([object valueForKey:[[IPImporter getInstance]keyOfObject:NSStringFromClass([object class])]]) {
        //NSLog(@"Object %@ has id %@ = %@", NSStringFromClass([object class]), [[IPImporter getInstance]keyOfObject:NSStringFromClass([object class])], [object valueForKey:[[IPImporter getInstance]keyOfObject:NSStringFromClass([object class])]]);
        //return;
    }
    
    object.zetPost = nil;
    
    NSArray *keys = [[[object entity] attributesByName] allKeys];
    NSMutableArray *filteredKey = [NSMutableArray arrayWithCapacity:keys.count];
    for(NSString *akey in keys){
        if(![akey hasPrefix:@"zet"])[filteredKey addObject:akey];
    }
    //[keys removeObject:@"zetPost"];

    NSDictionary *dict = [object dictionaryWithValuesForKeys:filteredKey];
    
    NSError *error;
        
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];if(error)[General logError:error];
    NSString *postString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSString *post = [NSString stringWithFormat:@"data=%@", postString];
    post = [post stringByReplacingOccurrencesOfString:@"&" withString:@""];//TODO, right UTF
    post = [post stringByReplacingOccurrencesOfString:@"?" withString:@""];
    post = [post stringByAppendingString:[NSString stringWithFormat:@"&%@", [[ADBAccountManager sharedInstance]postForGroup]]];
    object.zetPost = post;
    object.zetAPI = [NSString stringWithFormat:@"%@Update", [IPExporter apiForObject:object]];
    
    
    [General saveContextAndRoll];
}

-(void)deleteInfoForObject:(Object *)object withBlock:(void(^)(NSURLResponse *, NSData *, NSError *))someBlock{
    if ([object valueForKey:[[IPImporter getInstance]keyOfObject:NSStringFromClass([object class])]]) {
        //NSLog(@"Object %@ has id %@ = %@", NSStringFromClass([object class]), [[IPImporter getInstance]keyOfObject:NSStringFromClass([object class])], [object valueForKey:[[IPImporter getInstance]keyOfObject:NSStringFromClass([object class])]]);
        //return;
    }
    
    object.zetDeletePost = nil;
    
    NSArray *keys = [[[object entity] attributesByName] allKeys];
    NSMutableArray *filteredKey = [NSMutableArray arrayWithCapacity:keys.count];
    for(NSString *akey in keys){
        if(![akey hasPrefix:@"zet"])[filteredKey addObject:akey];
    }
    //[keys removeObject:@"zetPost"];
    NSDictionary *dict = [object dictionaryWithValuesForKeys:filteredKey];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];if(error)[General logError:error];
    NSString *postString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSString *post = [NSString stringWithFormat:@"data=%@", postString];
    post = [post stringByReplacingOccurrencesOfString:@"&" withString:@""];//TODO, right UTF
    post = [post stringByReplacingOccurrencesOfString:@"?" withString:@""];
    post = [post stringByAppendingString:[NSString stringWithFormat:@"&%@", [[ADBAccountManager sharedInstance]postForGroup]]];
    object.zetDeletePost = post;
    object.zetDeleteAPI = [NSString stringWithFormat:@"%@Delete", [IPExporter apiForObject:object]];
    
    
    [General saveContextAndRoll];
}

-(void)logErrorInServer:(Object *)object{
    object.zetCounterPost = nil;

    NSString *post = [NSString stringWithFormat:@"api=%@&post=%@", object.zetAPI, object.zetPost];
    NSMutableURLRequest *request = [General callToAPI:@"recordError" withPost:post];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data_, NSError *error_){
        //At this point need not keep tracking
    }];
    [General saveContextAndRoll];
}

-(void)uploadNewObject:(Object *)newObject withBlock:(void(^)(NSURLResponse *, NSData *, NSError *))someBlock{
    
    [self uploadInfoForNewObject:newObject withBlock:nil];
    NSLog(@"Upload at API %@___________\n with Post: '%@'", newObject.zetAPI, newObject.zetPost);
    if (newObject.zetAPI == nil) {
        //newObject.zetPost = nil;
        //return;
    }
    
    NSMutableURLRequest *request = [General callToAPI:newObject.zetAPI withPost:newObject.zetPost];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data_, NSError *error_){
        if (!error_) {
            //NSLog(@"Let ________    %@ ______%@", [[NSString alloc]initWithData:data_ encoding:NSUTF8StringEncoding], newObject.zetAPI);
            //NSLog(@"The raw response %@ for %@", [[NSString alloc]initWithData:data_ encoding:NSUTF8StringEncoding], NSStringFromClass([newObject class]));
            int theInt = [[NSString alloc]initWithData:data_ encoding:NSUTF8StringEncoding].intValue;
            NSLog(@"The response %i for %@", theInt, NSStringFromClass([newObject class]));
            if (theInt < 100000000 && theInt != 0) {
                newObject.zetAPI = nil;
                newObject.zetPost = nil;
                [newObject setValue:[NSString stringWithFormat:@"%i", theInt] forKey:[[IPImporter getInstance]keyOfObject:NSStringFromClass([newObject class])]];
                
                [self processArrivedNewObject:newObject withId:theInt];
                
                [General saveContextAndRoll];
            }
            if (theInt == 0) {
                if(!newObject.zetCounterPost)newObject.zetCounterPost = [NSNumber numberWithBool:0];
                newObject.zetCounterPost = [NSNumber numberWithInt:newObject.zetCounterPost.intValue + 1];
                if (newObject.zetCounterPost.intValue > ATTEMPTS_SERVER) {
                    [self logErrorInServer:newObject];
                    newObject.zetPost = nil;
                }
            }
            if(someBlock)someBlock(nil, nil, nil);
        }else{
            [General logError:error_];
        }
    }];
}

-(void)updateObject:(Object *)object withBlock:(void(^)(NSURLResponse *, NSData *, NSError *))someBlock{
    [self updateInfoForObject:object withBlock:nil];
    NSLog(@"update at API %@______//////_____\n with Post: %@", object.zetAPI, object.zetPost);
    
    NSMutableURLRequest *request = [General callToAPI:object.zetAPI withPost:object.zetPost];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data_, NSError *error_){
        if (!error_) {
            //NSLog(@"Let ________    %@ ______%@", [[NSString alloc]initWithData:data_ encoding:NSUTF8StringEncoding], object.zetAPI);
            //NSLog(@"The raw response %@ for %@", [[NSString alloc]initWithData:data_ encoding:NSUTF8StringEncoding], NSStringFromClass([object class]));
            int theInt = [[NSString alloc]initWithData:data_ encoding:NSUTF8StringEncoding].intValue;
            NSLog(@"The response for update %i for '%@'", theInt, NSStringFromClass([object class]));
            if (theInt == 1) {
                object.zetAPI = nil;
                object.zetPost = nil;
                
                [General saveContextAndRoll];
                
                [self processArrivedNewObject:object withId:[[object valueForKey:[[IPImporter getInstance]keyOfObject:NSStringFromClass([object class])]]intValue]];
            }
            if (theInt == 0) {
                if(!object.zetCounterPost)object.zetCounterPost = [NSNumber numberWithBool:0];
                object.zetCounterPost = [NSNumber numberWithInt:object.zetCounterPost.intValue + 1];
                if (object.zetCounterPost.intValue > ATTEMPTS_SERVER) {
                    [self logErrorInServer:object];
                    object.zetPost = nil;
                }
            }
        }else{
            [General logError:error_];
        }
    }];
}

-(void)intialDeleteObject:(Object *)object{
    if (![object valueForKey:[self keyOfObject:NSStringFromClass([object class])]]) {
        [[(ADBAppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext] deleteObject:object];
    }else
        [[IPExporter getInstance]deleteObject:object withBlock:nil];
}

-(void)deleteObject:(Object *)object withBlock:(void(^)(NSURLResponse *, NSData *, NSError *))someBlock{
    [self deleteInfoForObject:object withBlock:nil];
    NSLog(@"delete at API %@______//////_____\n with Post: %@", object.zetDeleteAPI, object.zetDeletePost);
    
    NSMutableURLRequest *request = [General callToAPI:object.zetDeleteAPI withPost:object.zetDeletePost];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data_, NSError *error_){
        if (!error_) {
            //NSLog(@"Let ________    %@ ______%@", [[NSString alloc]initWithData:data_ encoding:NSUTF8StringEncoding], object.zetAPI);
            //NSLog(@"The raw response %@ for %@", [[NSString alloc]initWithData:data_ encoding:NSUTF8StringEncoding], NSStringFromClass([object class]));
            int theInt = [[NSString alloc]initWithData:data_ encoding:NSUTF8StringEncoding].intValue;
            NSLog(@"The response for delete %i for '%@'", theInt, NSStringFromClass([object class]));
            if (theInt == 1) {
                object.zetDeleteAPI = nil;
                object.zetDeletePost = nil;
                //Not sure I want to actually delete them
                object.deleted = @"1";
                
                /////RCF harcoding
                if (![object isMemberOfClass:[LabeledAntibody class]]) {
                    [[(ADBAppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext]deleteObject:object];
                }
                [General saveContextAndRoll];
            }
            if (theInt == 0) {
                if(!object.zetCounterDeletePost)object.zetCounterDeletePost = [NSNumber numberWithBool:0];
                object.zetCounterDeletePost = [NSNumber numberWithInt:object.zetCounterDeletePost.intValue + 1];
                if (object.zetCounterDeletePost.intValue > ATTEMPTS_SERVER) {
                    [self logErrorInServer:object];
                    object.zetDeletePost = nil;
                }
            }
        }else{
            [General logError:error_];
        }
    }];
}

-(void)delayedPushOfObjectTypes:(NSString *)type withSortDescriptorKey:(NSString *)sort withBlock:(void(^)(NSURLResponse *, NSData *, NSError *))someBlock{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:type];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:sort ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"zetPost != nil"];
    NSManagedObjectContext *context = [(ADBAppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
    NSArray *remaining = [context executeFetchRequest:request error:nil];
    for (Object * remainingObject in remaining) {
        NSMutableURLRequest *request = [General callToAPI:remainingObject.zetAPI withPost:remainingObject.zetPost];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data_, NSError *error_){
            if (!error_) {
                if ([[[NSString alloc]initWithData:data_ encoding:NSUTF8StringEncoding]isEqualToString:@"1"]) {
                    remainingObject.zetAPI = nil;
                    remainingObject.zetPost = nil;
                }
            }
        }];
    }
}

-(NSString *)keyOfObject:(NSString *)object{
    if (!_keysDictionary) {
        self.keysDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"primaryKeys" ofType:@"plist"]];
    }
    return [_keysDictionary valueForKey:object];
}

-(void)tryNonUploaded{
    if (paused) {
        return;
    }
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable)return;
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:OBJECT_DB_CLASS];
    //request.fetchLimit = 10;
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"zetAPI" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"zetPost != nil"];
    //request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                           //[NSPredicate predicateWithFormat:@"zetPost != nil"],
                                                                            //[NSPredicate predicateWithFormat:@"zetAPI contains[cd] %@", @"Update"]
                                                                           //]];
    NSManagedObjectContext *context = [(ADBAppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
    NSArray *remaining = [context executeFetchRequest:request error:nil];
    NSLog(@"Trying unrefreshed object %lu", (unsigned long)remaining.count);
    NSString *classFirst;
    for (Object * remainingObject in remaining) {

        if (!classFirst) {
            classFirst = NSStringFromClass([remainingObject class]);
        }
        if (![remainingObject isMemberOfClass:NSClassFromString(classFirst)]) {
            continue;
        }
        NSString *class = NSStringFromClass([remainingObject class]);
        NSString *pk = [self keyOfObject:class];
        if([remainingObject valueForKey:pk]){
            [self updateObject:remainingObject withBlock:nil];
        }else{
            [self uploadNewObject:remainingObject withBlock:nil];
        }
    }
}

-(void)tryNonDeleted{
    if (paused) {
        return;
    }
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable)return;
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:OBJECT_DB_CLASS];
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"zetDeleteAPI" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"zetDeletePost != nil"];

    NSManagedObjectContext *context = [(ADBAppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
    NSArray *remaining = [context executeFetchRequest:request error:nil];
    NSLog(@"Trying undeleted object %lu", (unsigned long)remaining.count);
    NSString *classFirst;
    for (Object * remainingObject in remaining) {
        
        if (!classFirst) {
            classFirst = NSStringFromClass([remainingObject class]);
        }
        if (![remainingObject isMemberOfClass:NSClassFromString(classFirst)]) {
            continue;
        }
        NSString *class = NSStringFromClass([remainingObject class]);
        NSString *pk = [self keyOfObject:class];
        if([remainingObject valueForKey:pk]){
            [self deleteObject:remainingObject withBlock:nil];
        }else{
            remainingObject.zetDeleteAPI = nil;
            remainingObject.zetDeletePost = nil;
            [General saveContextAndRoll];
        }
    }
}

-(void)tryNonUploadedFiles{
    if (paused) {
        return;
    }
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable)return;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:FILE_DB_CLASS];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"zetUploadData" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"zetUploadData != nil"];

    NSManagedObjectContext *context = [(ADBAppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
    NSArray *remaining = [context executeFetchRequest:request error:nil];
    NSLog(@"Trying unrefreshed File %lu", (unsigned long)remaining.count);
    
    for (File * remainingObject in remaining) {
        
        NSMutableURLRequest *request = [General photoUpload:remainingObject.zetUploadData withName:remainingObject.filHash];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response_, NSData *data_, NSError *error_){
            NSLog(@"Response is___PHOTO___ %@", [[NSString alloc]initWithData:data_ encoding:NSUTF8StringEncoding]);
            if (data_ && [[[NSString alloc]initWithData:data_ encoding:NSUTF8StringEncoding]intValue] == 1) {
                remainingObject.zetUploadData = nil;
                [General saveContextAndRoll];
            }
        }];
    }
}

-(void)aTestBlock:(void(^)(NSString *))someBlock{
    someBlock(@"Hola");
}

@end
