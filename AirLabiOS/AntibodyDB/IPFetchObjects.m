//
//  IPFetchObjects.m
// AirLab
//
//  Created by Raul Catena on 5/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "IPFetchObjects.h"

typedef void (^YBlock)();


@interface IPFetchObjects()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *ongoingAPIs;
@property (nonatomic, assign) int completed;
@property (nonatomic, assign) int tasks;

@end

@implementation IPFetchObjects

@synthesize managedObjectContext = _managedObjectContext;

-(NSManagedObjectContext *)managedObjectContext{
    if (!_managedObjectContext) {
        ADBAppDelegate *delegate = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
        return delegate.managedObjectContext;
        NSPersistentStoreCoordinator *coordinator = delegate.persistentStoreCoordinator;
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc]init];
        context.persistentStoreCoordinator = coordinator;
        _managedObjectContext = context;
    }
    return _managedObjectContext;
}

+ (IPFetchObjects *)getInstance {
    static dispatch_once_t pred = 0;
    __strong static IPFetchObjects* _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    
    return _sharedObject;
}

-(BOOL)checkToAPIcenter:(NSString *)api{
    if (!_ongoingAPIs) {
        _ongoingAPIs = [NSMutableArray array];
    }
    if ([_ongoingAPIs containsObject:api]) {
        return YES;
    }
    [_ongoingAPIs addObject:api];
    _tasks++;
    if (_completed == -1)_completed = 0;
    [General barIndicatorWithPercentage:[self valueForProgress]];
    return NO;
}

-(float)valueForProgress{
    NSLog(@"TASKS %i", _tasks);NSLog(@"DONE %i", _completed);NSLog(@"VALUE %f", (float)_completed/(float)_tasks);
    return ((float)_completed/(float)_tasks);
}

-(void)reset{
    NSLog(@"TASKS %i", _tasks);NSLog(@"DONE %i", _completed);
    if(_ongoingAPIs.count == 0){
        _completed = -1;
        _tasks = 0;
    }
}

-(void)completedTask{
    _completed++;
}

-(void)removeApiFromCenter:(NSString *)api{
    if ([_ongoingAPIs containsObject:api]) {
        [_ongoingAPIs removeObjectIdenticalTo:api];
    }
}

-(void)addProviderssFromServerWithBlock:(YBlock)block{
    NSString *api = @"getAllProviders";
    NSMutableURLRequest *request = [General callToGetAPIWithSuffix:api];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[PROVIDER_DB_CLASS] usingPK:@[@"proProviderId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}

-(void)addPeopleFromLabFromServerWithBlock:(YBlock)block{
    NSString *api =[NSString stringWithFormat:@"getPeopleInGroup/%@", [[ADBAccountManager sharedInstance]currentGroupPerson].gpeGroupId];
    NSMutableURLRequest *request = [General callToGetAPIWithSuffix:api];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[GROUP_DB_CLASS, PERSON_DB_CLASS, ZGROUPPERSON_DB_CLASS] usingPK:@[@"grpGroupId",@"perPersonId",@"gpeGroupPersonId"] erasingOld:@[[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}
-(void)addTagsFromServerWithBlock:(YBlock)block{
    NSString *api = @"getAllTags";
    NSMutableURLRequest *request = [General callToGetAPIWithSuffix:api];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[TAG_DB_CLASS] usingPK:@[@"tagTagId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}
-(void)addSpeciesFromServerWithBlock:(YBlock)block{
    NSString *api = @"getAllSpecies";
    NSMutableURLRequest *request = [General callToGetAPIWithSuffix:api];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[SPECIES_DB_CLASS] usingPK:@[@"spcSpeciesId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}
-(void)addProteinsFromServerWithBlock:(YBlock)block{
    NSString *api = @"getAllProteinsForGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[PROTEIN_DB_CLASS] usingPK:@[@"proProteinId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}
-(void)addClonesFromServerWithBlock:(YBlock)block{
    NSString *api = @"getAllClonesForGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[CLASS_CLONE] usingPK:@[@"cloCloneId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}
-(void)addLostFromServerWithBlock:(YBlock)block{
    NSString *api = @"getAllLotsForGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[LOT_DB_CLASS] usingPK:@[@"reiReagentInstanceId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}
-(void)addConjugatesFromServerWithBlock:(YBlock)block{
    NSString *api = @"getAllLabeledAntibodiesForGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[LABELEDANTIBODY_DB_CLASS] usingPK:@[@"labLabeledAntibodyId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}
-(void)addPanelsFromServerWithBlock:(YBlock)block{
    NSString *api = @"getAllPanelsForGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[PANEL_DB_CLASS] usingPK:@[@"panPanelId"] erasingOld:@[[NSNumber numberWithBool:YES]] withCompletionBlock:block];
        }
    }];
}

//RCF
-(void)addReagentInstancesFromServerWithBlock:(YBlock)block{
    NSString *api = @"getAllReagentInstancesForGroup";
     NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
   
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[REAGENTINSTANCE_DB_CLASS] usingPK:@[@"reiReagentInstanceId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}

//RCF
-(void)addComertialReagentsFromServerWithBlock:(YBlock)block{
    NSString *api = @"getAllComertialReagentsForGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[COMERTIALREAGENT_DB_CLASS] usingPK:@[@"comComertialReagentId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}
-(void)addScientificArticlesForGroupFromServerWithBlock:(YBlock)block{
    NSString *api = @"getAllScientificArticlesForGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[SCIENTIFICARTICLE_DB_CLASS] usingPK:@[@"sciScientificArticleId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}

-(void)addScientificArticlesForPersonFromServerWithBlock:(YBlock)block{
    NSString *api = @"getAllScientificArticlesForPerson";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[SCIENTIFICARTICLE_DB_CLASS] usingPK:@[@"sciScientificArticleId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}

-(void)addRecetasFromServerWithBlock:(YBlock)block{
    NSString *api = @"getAllRecipesForGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[RECIPE_DB_CLASS] usingPK:@[@"rcpRecipeId"] erasingOld:@[[NSNumber numberWithBool:YES]] withCompletionBlock:block];
        }
    }];
}

//RCF may need to remove
-(void)addStepsFromServerWithBlock:(YBlock)block{
    NSString *api = @"getAllStepsForGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[STEP_DB_CLASS] usingPK:@[@"stpStepId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}

-(void)addSamplesFromServerWithBlock:(YBlock)block{
    NSString *api = @"getAllSamplesForGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[SAMPLE_DB_CLASS] usingPK:@[@"samSampleId"] erasingOld:@[[NSNumber numberWithBool:YES]] withCompletionBlock:block];
        }
    }];
}

-(void)addPlansForServerWithBlock:(YBlock)block{
    NSString *api = @"getAllPlansForPersonGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[PLAN_DB_CLASS] usingPK:@[@"plnPlanId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}

-(void)addEnsayosForServerWithBlock:(YBlock)block{
    NSString *api = @"getAllEnsayosForPersonGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[ENSAYO_DB_CLASS] usingPK:@[@"enyEnsayoId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}

-(void)addPartsForServerWithBlock:(YBlock)block{
    NSString *api = @"getAllPartsForGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[PART_DB_CLASS] usingPK:@[@"prtPartId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}

-(void)addLotEnsayosForServerWithBlock:(YBlock)block{
    NSString *api = @"getAllZLotEnsayosForGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[ZLOTENSAYO_DB_CLASS] usingPK:@[@"lenLotEnsayoId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}

-(void)addFilesForServerWithBlock:(YBlock)block{
    NSString *api = @"getAllFilesForPersonGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[FILE_DB_CLASS] usingPK:@[@"filFileId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}

-(void)addFilesForGroupServerWithBlock:(YBlock)block{
    NSString *api = @"getAllFilesForGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[FILE_DB_CLASS] usingPK:@[@"filFileId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}

-(void)addFilePartsForServerWithBlock:(YBlock)block{
    NSString *api = @"getAllFilePartsForPersonGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[ZFILEPART_DB_CLASS] usingPK:@[@"fptFilePartId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}

-(void)addPlacesForServerWithBlock:(YBlock)block{
    NSString *api = @"getAllPlacesForGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[PLACE_DB_CLASS] usingPK:@[@"plaPlaceId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}

-(void)addPlatesForServerWithBlock:(YBlock)block{
    NSString *api = @"getAllPlatesForGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[@"Plate"] usingPK:@[@"plaPlateId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}

-(void)addPlateWellsForServerWithBlock:(YBlock)block{
    NSString *api = @"getAllPlateWellsForGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[@"PlateWell"] usingPK:@[@"pwlPlatewellId"] erasingOld:@[[NSNumber numberWithBool:NO]] withCompletionBlock:block];
        }
    }];
}

-(void)addCommentWallsForServerWithBlock:(YBlock)block{
    NSString *api = @"getAllCommentWallsForGroup";
    NSMutableURLRequest *request = [General callToAPI:api withPost:[[ADBAccountManager sharedInstance] postForGroup]];
    if ([self checkToAPIcenter:api])return;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self removeApiFromCenter:api];
        if(error)[General logError:error];
        else{
            [[IPImporter getInstance]processDataDirectly:data toObjectClasses:@[@"CommentWall"] usingPK:@[@"cwlCommentWallId"] erasingOld:@[[NSNumber numberWithBool:YES]] withCompletionBlock:block];
        }
    }];
}


@end
