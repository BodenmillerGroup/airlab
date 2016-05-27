//
//  ADBAccountManager.m
// AirLab
//
//  Created by Raul Catena on 5/20/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAccountManager.h"
#import "ADBLoginViewController.h"

@implementation ADBAccountManager

+(ADBAccountManager *)sharedInstance{
    static dispatch_once_t pred = 0;
    __strong static ADBAccountManager* _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

-(NSManagedObjectContext *)managedObjectContext{
    ADBAppDelegate *delegateApp = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
    return delegateApp.workerManagedObjectContext;
}

-(Person *)currentUser{
    NSArray *array = [General searchDataBaseForClass:PERSON_DB_CLASS withBOOL:YES inField:@"zetIsCurrent" sortBy:@"zetIsCurrent" ascending:YES inMOC:[self managedObjectContext]];
    return (Person *)array.lastObject;
}
-(ZGroupPerson *)currentGroupPerson{
    NSArray *array = [General searchDataBaseForClass:ZGROUPPERSON_DB_CLASS withBOOL:YES inField:@"zetIsCurrent" sortBy:@"zetIsCurrent" ascending:YES inMOC:[self managedObjectContext]];
    return (ZGroupPerson *)array.lastObject;
}
-(NSArray *)allGroupPersonOfCurrentPerson{
    NSArray *array = [General searchDataBaseForClass:ZGROUPPERSON_DB_CLASS withTerm:[(Person *)[self currentUser]perPersonId] inField:@"gpePersonId" sortBy:@"gpePersonId" ascending:YES inMOC:[self managedObjectContext]];
    return array;
}

-(NSArray *)allGroupMembers{
    NSArray *array = [General searchDataBaseForClass:ZGROUPPERSON_DB_CLASS withTerm:[(ZGroupPerson *)[self currentGroupPerson]gpeGroupId] inField:@"gpeGroupId" sortBy:@"gpePersonId" ascending:YES inMOC:[self managedObjectContext]];
    return array;
}

-(NSArray *)groupsOfCurrentPerson{
    return [self currentUser].groups.allObjects;
}

-(void)showLoginIfNecessary{
    if ([self currentGroupPerson]) {
        return;
    }
    
    __block ADBLoginViewController *login;
    [General iPhoneBlock:^{
        login = [[ADBLoginViewController alloc]initWithNibName:@"ADBLoginIPhone" bundle:nil];
    } iPadBlock:^{
        login = [[ADBLoginViewController alloc]init];
    }];
    
    UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:login];
    ADBAppDelegate *del = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
    [del.window.rootViewController presentViewController:navCon animated:YES completion:nil];
}

-(void)logOff{
    Person *current = [self currentUser];
    current.zetIsCurrent = [NSNumber numberWithBool:NO];
    ZGroupPerson *currGP = [self currentGroupPerson];
    currGP.zetIsCurrent = [NSNumber numberWithBool:NO];
    [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithInt:currGP.gpeGroupId.intValue] forKeyPath:@"lastGroup"];
    [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithInt:currGP.gpeGroupPersonId.intValue] forKeyPath:@"lastPerson"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    //NSArray *everything = [General searchDataBaseForClass:OBJECT_DB_CLASS sortBy:@"offlineId" ascending:YES inMOC:[self managedObjectContext]];
    //for(Object *obj in everything){
        //[[self managedObjectContext]deleteObject:obj];
    //}
    [[self managedObjectContext]save:nil];
    [self showLoginIfNecessary];
}

-(void)checkNeedErase{
    
    //Erase personal
    if ([self currentGroupPerson].gpeGroupPersonId.intValue != [[[NSUserDefaults standardUserDefaults]valueForKeyPath:@"lastPerson"]intValue]) {
        NSArray *everything = [General searchDataBaseForClass:OBJECT_DB_CLASS sortBy:@"offlineId" ascending:YES inMOC:[self managedObjectContext]];
        for(Object *obj in everything){
            if ([NSStringFromClass([obj class])isEqualToString:SCIENTIFICARTICLE_DB_CLASS] || [NSStringFromClass([obj class])isEqualToString:PLAN_DB_CLASS]){
                [[self managedObjectContext]deleteObject:obj];
            }
        }
    }
    
    //Erase Group
    if ([self currentGroupPerson].gpeGroupId.intValue != [[[NSUserDefaults standardUserDefaults]valueForKeyPath:@"lastGroup"]intValue]) {
        [[IPImporter getInstance]setCurrentCompleters:nil];
        
        NSArray *everything = [General searchDataBaseForClass:OBJECT_DB_CLASS sortBy:@"offlineId" ascending:YES inMOC:[self managedObjectContext]];
        for(Object *obj in everything){
            if ([NSStringFromClass([obj class])isEqualToString:PERSON_DB_CLASS] || [NSStringFromClass([obj class])isEqualToString:GROUP_DB_CLASS] || [NSStringFromClass([obj class])isEqualToString:ZGROUPPERSON_DB_CLASS] || [NSStringFromClass([obj class])isEqualToString:TAG_DB_CLASS] || [NSStringFromClass([obj class])isEqualToString:SPECIES_DB_CLASS] || [NSStringFromClass([obj class])isEqualToString:PROVIDER_DB_CLASS] ) {
                continue;
            }
            [[self managedObjectContext]deleteObject:obj];
        }
    }
}

-(void)processIncomingLoginData:(NSData *)data{
    
    __block int internalRefreshes = 0;
    [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[PERSON_DB_CLASS, ZGROUPPERSON_DB_CLASS, GROUP_DB_CLASS] usingPK:@[@"perPersonId", @"gpeGroupPersonId", @"grpGroupId"] erasingOld:@[[NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO]] withCompletionBlock:^{
        internalRefreshes++;
        if(internalRefreshes == 4){
            [[IPImporter getInstance]saveContexts:^{
                
                NSMutableDictionary *dictToReturn = [NSMutableDictionary dictionaryWithObject:data forKey:@"json"];
                
                NSError *error2;
                NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error2];
                if (error2)[General logError:error2];
                else{
                    NSDictionary *dict = arr.lastObject;
                    
                    NSArray *results = [General searchDataBaseForClass:PERSON_DB_CLASS withTerm:[dict valueForKey:@"perPersonId"] inField:@"perPersonId" sortBy:@"perPersonId" ascending:YES inMOC:[self managedObjectContext]];
                    Person *person = (Person *)results.lastObject;
                    if (person) {
                        person.zetIsCurrent = [NSNumber numberWithBool:YES];
                        
                        
                        if(person.groupPersons.count == 1){
                            if ([(ZGroupPerson *)[person.groupPersons anyObject]gpeRole].intValue != -1){
                                [(ZGroupPerson *)[person.groupPersons anyObject]setZetIsCurrent:[NSNumber numberWithBool:YES]];
                                
                                [self checkNeedErase];
                            }
                        }
                        [General saveContextAndRoll];
                        if(person.groupPersons.count == 0){
                            [dictToReturn setObject:[NSNumber numberWithInt:0] forKey:@"signal"];
                        }else if(person.groupPersons.count == 1){
                            if ([(ZGroupPerson *)person.groupPersons.allObjects.lastObject zetIsCurrent]) {
                                [dictToReturn setObject:[NSNumber numberWithInt:1] forKey:@"signal"];
                            }else{
                                [dictToReturn setObject:[NSNumber numberWithInt:2] forKey:@"signal"];
                            }
                        }else{
                            [dictToReturn setObject:[NSNumber numberWithInt:3] forKey:@"signal"];
                        }
                    }else{
                        [dictToReturn setObject:[NSNumber numberWithInt:-1] forKey:@"signal"];
                    }
                }
                [[NSNotificationCenter defaultCenter]postNotificationName:NSNC_LOGEDIN object:nil userInfo:dictToReturn];
            }];
        }
    }];
}

-(void)logInWithEmail:(NSString *)login andPassword:(NSString *)password{
    [[IPImporter getInstance]cancelAll];
    NSString *post = [General createDataPostWithDictionary:[NSDictionary dictionaryWithObjects:@[login, password] forKeys:@[@"email", @"password"]]];
    NSMutableURLRequest *request = [General callToAPI:@"login" withPost:post];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if(error){
            [General logError:error];
            [General noConnection:nil];
        }else{
            [General logData:data withHeader:@"Log in callback:"];
            if ([[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]isEqualToString:@"0"]) {
                [General showOKAlertWithTitle:@"Alert" andMessage:@"Wrong email address or password" delegate:nil];
                return;
            }
            if ([[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]isEqualToString:@"-1"]) {
                [General showOKAlertWithTitle:@"Alert" andMessage:@"You account has not yet been activated" delegate:nil];
                return;
            }
            
            NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            if (array.count > 0) {
                NSString *token = [[array objectAtIndex:0] valueForKey:TOKEN_PUBLIC_KEY];
                if (token) {
                    [[NSUserDefaults standardUserDefaults]setValue:token forKey:TOKEN_PUBLIC_KEY];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }else{
                    [General showOKAlertWithTitle:ERROR andMessage:@"There was an error with the server authentication" delegate:nil];
                    return;
                }
            }else{
                [General showOKAlertWithTitle:ERROR andMessage:@"There was an error with the server authentication" delegate:nil];
                return;
            }
            
            [self processIncomingLoginData:data];
        }
    }];
}

-(void)invite:(NSString *)email{
    NSString *post = [General createDataPostWithDictionary:[NSDictionary dictionaryWithObjects:@[email] forKeys:@[@"email"]]];
    post = [post stringByAppendingString:[NSString stringWithFormat:@"&%@", [[ADBAccountManager sharedInstance]postForGroup]]];
    NSLog(@"Post is %@", post);
    NSMutableURLRequest *request = [General callToAPI:@"invite" withPost:post];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (error) {
            [General noConnection:nil];
        }else{
            [General showOKAlertWithTitle:@"Invitation sent" andMessage:nil delegate:nil];
            [General logData:data withHeader:@"data:"];
        }
    }];
}

-(void)createAccountWithEmail:(NSString *)login andPassword:(NSString *)password{
    NSString *post = [General createDataPostWithDictionary:[NSDictionary dictionaryWithObjects:@[login, password] forKeys:@[@"email", @"password"]]];
    NSMutableURLRequest *request = [General callToAPI:@"person" withPost:post];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        NSMutableDictionary *dictToReturn = [NSMutableDictionary dictionary];
        if(error){
            [General noConnection:nil];
            [General logError:error];
        }else{
            if ([[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]intValue] == -1) {

                [dictToReturn setObject:[NSNumber numberWithInt:0] forKey:@"signal"];
            }else if([[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]intValue] == -2){//beta
                [dictToReturn setObject:[NSNumber numberWithInt:-2] forKey:@"signal"];
            }else{
                [dictToReturn setObject:[NSNumber numberWithInt:1] forKey:@"signal"];
            }
    
            [[NSNotificationCenter defaultCenter]postNotificationName:@"NSNC_CREATED" object:nil userInfo:[NSDictionary dictionaryWithDictionary:dictToReturn]];
        }
    }];
}
-(void)requestNewPassword:(NSString *)email{
    //NSString *post = [General createDataPostWithDictionary:[NSDictionary dictionaryWithObjects:@[email] forKeys:@[@"email"]]];
    NSMutableURLRequest *request = [General callToGetAPIWithSuffix:[NSString stringWithFormat:@"person/password/%@", email]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if(error)[General logError:error];
        else{
            [General showOKAlertWithTitle:@"Email sent" andMessage:@"You will get an email with your new password" delegate:nil];
            NSLog(@"This is the data obtained %@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        }
    }];
}

-(void)addPersonGroup:(ZGroupPerson *)personGroup toObject:(Object *)object{
    if(!object.groupPerson)object.groupPerson = personGroup;
    if(!object.createdBy)object.createdBy = personGroup.gpeGroupPersonId;
    if(!object.createdAt)object.createdAt = [NSDate date].description;
    if (!object.groupId)object.groupId = personGroup.group.grpGroupId;
    object.zetPost = @"PlaceholderPost";
    //[[IPExporter getInstance] uploadInfoForNewObject:object withBlock:nil];
    //TODO add post to update
}

-(void)inactivateByPersonGroup:(ZGroupPerson *)personGroup toObject:(Object *)object{
    if(!object.groupPersonInactivating)object.groupPersonInactivating = personGroup;
    if(!object.inactivatedBy)object.inactivatedBy = personGroup.gpeGroupPersonId;
    if(!object.inactivatedAt)object.inactivatedAt = [NSDate date].description;
    //TODO add post to update
}

-(void)acceptPersonGroup:(ZGroupPerson *)groupPerson{
    groupPerson.gpeRole = @"10";
    [General saveContextAndRoll];
    [[IPExporter getInstance]updateInfoForObject:groupPerson withBlock:^(NSURLResponse *response, NSData *data, NSError *error){
        
    }];
}

-(void)removePersonGroup:(ZGroupPerson *)groupPerson{
    groupPerson.gpeRole = @"-1";
    [General saveContextAndRoll];
    [[IPExporter getInstance]updateInfoForObject:groupPerson withBlock:^(NSURLResponse *response, NSData *data, NSError *error){
        
    }];
}

-(NSString *)postForGroup{
    return [NSString stringWithFormat:@"dataCrud={\"groupId\":\"%@\",\"perPersonId\":\"%@\",\"linkerFlag\":\"%@\",\"token\":\"%@\"}", [[ADBAccountManager sharedInstance]currentGroupPerson].gpeGroupId, [[ADBAccountManager sharedInstance]currentUser].perPersonId, [[ADBAccountManager sharedInstance]currentGroupPerson].gpeGroupPersonId, [[NSUserDefaults standardUserDefaults]valueForKeyPath:@"TOKEN_PUBLIC_KEY"]];
}

@end
