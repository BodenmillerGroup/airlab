//
//  IPSyncOperation.m
// AirLab
//
//  Created by Raul Catena on 6/14/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "IPSyncOperation.h"
#import <objc/runtime.h>

typedef void (^YBlock)();

@interface IPSyncOperation()

@property (nonatomic, strong) NSArray *objects;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSArray *primaryKeys;
@property (nonatomic, strong) NSArray *eraseOldBoolsArray;
@property (nonatomic, strong) YBlock block;
@property (nonatomic, strong) NSMutableArray *objectsInBatch;

@end

@implementation IPSyncOperation

-(NSManagedObjectContext *)managedObjectContext{
    if (!_managedObjectContext) {
        ADBAppDelegate *delegate = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
        _managedObjectContext = delegate.workerManagedObjectContext;
    }
    return _managedObjectContext;
}

- (void)saveContexts {
    [[self managedObjectContext] performBlock:^{
        NSError *childError = nil;
        if ([[self managedObjectContext] save:&childError]) {
            [[self managedObjectContext].parentContext performBlock:^{
                NSError *parentError = nil;
                if (![[self managedObjectContext].parentContext save:&parentError]) {
                    [[self managedObjectContext].parentContext rollback];
                    NSLog(@"Error saving parent %@", parentError);
                }
            }];
        } else {
            NSLog(@"Error saving child %@", childError);
        }
    }];
}

-(NSString *)keyOfObject:(NSString *)object{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"primaryKeys" ofType:@"plist"]];

    return [dict valueForKey:object];
}

//New methods consuming Slim API


-(BOOL)analyzeObject:(id)object forPropertyKey:(NSString *)key{
    
    NSArray *keys = [[[object entity] attributesByName] allKeys];
    if ([keys containsObject:key]) {
        return YES;
    }
    else
        return NO;
}


-(BOOL)analyzeFutureManagedObject:(NSString *)classOfObject forPropertyKey:(NSString *)key{
    
    id currentClass = NSClassFromString(classOfObject);
    
    while (currentClass) {//Important to loop through superclasses 
        NSString *propertyName;
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(currentClass, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];//stringWithCString:property_getName(property)];
            
            //With this code I can even learn the type of property, and could search for NSString etc
            //const char * type = property_getAttributes(property);
            //NSString *attr = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
            //const char *propType = getPropertyType(property);
            //            NSString *propertyName = [NSString stringWithCString:propName
            //                                                        encoding:[NSString defaultCStringEncoding]];
            //            NSString *propertyType = [NSString stringWithCString:propType
            //                                                        encoding:[NSString defaultCStringEncoding]];
            //NSLog(@"A prop %@ with atts %@", propertyName, attr);
            
            if ([key isEqualToString:propertyName]) {
                return YES;
            }
        }
        currentClass = [currentClass superclass];
    }
    
    return NO;
}

-(void)writeObjectOfType:(NSString *)className withJSONDictionary:(NSDictionary *)jsonDict andPK:(NSString *)primaryKey withHolder:(NSMutableArray *)holder{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:className];
    //NSLog(@"Will do the check for primary %@ if exists %@", primaryKey, [jsonDict valueForKey:primaryKey]);
    if([jsonDict valueForKey:primaryKey] == (id)[NSNull null]){
        NSLog(@"Void join table");
        return;
    }
    if ([self analyzeFutureManagedObject:className forPropertyKey:primaryKey]) {
        request.predicate = [NSPredicate predicateWithFormat:@"%K == %@", primaryKey, [jsonDict valueForKey:primaryKey]];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:[self keyOfObject:className] ascending:YES]];
        NSArray *array = [self.managedObjectContext executeFetchRequest:request error:nil];
        if (array.count > 1) {
            //[General showOKAlertWithTitle:[NSString stringWithFormat:@"Duplicate object of type %@", className] andMessage:[jsonDict valueForKey:primaryKey]];
            for (NSManagedObject *obj in array) {
                [self.managedObjectContext deleteObject:obj];
            }
            array= [NSArray array];
        }
        NSManagedObject *managedObject = nil;
        if (array.count == 1){
            managedObject = [array lastObject];
        }else{
            managedObject = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:self.managedObjectContext];
        }
        
        if(!_objectsInBatch)_objectsInBatch = [NSMutableArray array];
        
        for (NSManagedObject *obj in _objectsInBatch) {
            if ([self analyzeObject:obj forPropertyKey:primaryKey]) {
                if ([[obj valueForKey:primaryKey]isEqualToString:[jsonDict valueForKey:primaryKey]]) {
                    NSLog(@"Ya procesado  ______-----______%@ %@", className, [jsonDict valueForKey:primaryKey]);
                    return;
                }
            }
        }
        
        
        //This will avoid reflux updates
        if([(Object *)managedObject zetDeletePost].length > 0 || [(Object *)managedObject zetPost].length > 0 || managedObject.hasChanges == YES)return;
        
        
        for (NSString *key in jsonDict.allKeys) {
            if ([self analyzeObject:managedObject forPropertyKey:key]) {
                if ([jsonDict valueForKey:key] != (id)[NSNull null]) {
                    [managedObject setValue:[NSString stringWithFormat:@"%@",[jsonDict valueForKey:key]] forKey:key];//setValue:[jsonDict valueForKey:key] forKey:key];
                    //NSLog(@"succeded setting key %@ and value %@ in object %@", key, [jsonDict valueForKey:key], className);
                }else{
                    if (![key hasPrefix:@"zet"] ||![key isEqualToString:primaryKey]) {//Avoid setting nil what does not come from the server
                        [managedObject setValue:nil forKey:key];//Return nil values when NULL in database. But here we have to undo the link
                    }
                }
            }
        }
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            [General logError:error];
            NSLog(@"Ha habido error____________________________________________________%@", className);
            [self.managedObjectContext rollback];
            error = nil;
            [self.managedObjectContext save:&error];
            if (error)[General logError:error];
        }
        [_objectsInBatch addObject:managedObject];
    }
}

-(id)initWithData:(NSData *)data_ toObjectClasses:(NSArray *)objectClasses usingPK:(NSArray *)primaryKeys erasingOld:(NSArray *)eraseOldBoolsArray withCompletionBlock:(void(^)())ablock{
    self = [self init];
    if (self) {
        self.data = data_;
        self.objectClasses = objectClasses;
        self.primaryKeys = primaryKeys;
        self.eraseOldBoolsArray = eraseOldBoolsArray;
        self.block = ablock;
    }
    return self;
}

-(id)initWithObjects:(NSArray *)objects toObjectClasses:(NSArray *)objectClasses usingPK:(NSArray *)primaryKeys erasingOld:(NSArray *)eraseOldBoolsArray withCompletionBlock:(void(^)())ablock{
    self = [self init];
    if (self) {
        self.objects = objects;
        self.objectClasses = objectClasses;
        self.primaryKeys = primaryKeys;
        self.eraseOldBoolsArray = eraseOldBoolsArray;
        self.block = ablock;
        [self managedObjectContext];
    }
    return self;
}

-(void)main{
    @autoreleasepool {

        //NSArray *sessions = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:nil];
        
        NSString *raw = [[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
        
        if ([raw isEqualToString:@"ERROR_USER"]) {
            [[ADBAccountManager sharedInstance]logOff];
            //Call the Login/// This needs to have View controller as delegate
        }
        //NSLog(@"Object dicts for %@ are %i %@", objectClasses, sessions.count, sessions);
        
        for (int x = 0; x < _objectClasses.count; x++) {
            //Check whether the JSON has the object in question. This will avoid deleting and writing.
            BOOL jsonHadObject = NO;
            for (NSDictionary *dict in _objects) {
                if ([dict valueForKey:[_primaryKeys objectAtIndex:x]]) {
                    jsonHadObject = YES;
                    break;
                }
            }
           
            //Erase All previous
            NSFetchRequest *requestOfAll = [NSFetchRequest fetchRequestWithEntityName:[_objectClasses objectAtIndex:x]];
            requestOfAll.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:[_primaryKeys objectAtIndex:x] ascending:YES]];
            NSMutableArray *allObjectsOfAType = [[self.managedObjectContext executeFetchRequest:requestOfAll error:nil]mutableCopy];
            //Delete all previous
            NSMutableArray *toRemove = [NSMutableArray array];
            for (NSManagedObject *managedObject in allObjectsOfAType) {
                BOOL found = NO;
                
                if (_objects.count == 0 || !jsonHadObject){
                    found = YES;//This will avoid losses when a MO type is passed for creating conexions only (not expected in Json return
                }
                for (NSDictionary *diction in _objects) {
                    if ([[managedObject valueForKey:[_primaryKeys objectAtIndex:x]]isEqualToString:[diction valueForKey:[_primaryKeys objectAtIndex:x]]]) {
                        found = YES;
                        break;
                    }
                }
                if (found == NO) {
                    if (![[_objectClasses objectAtIndex:x]isEqualToString:NSStringFromClass([Person class])]) {//RCF An specific
                        if ([[_eraseOldBoolsArray objectAtIndex:x]boolValue]) {
                            NSLog(@"Will add %@", [_objectClasses objectAtIndex:x]);
                            if (![managedObject valueForKey:@"zetPost"]) {
                                [toRemove addObject:managedObject];
                            }
                        }
                    }
                }
            }
            for (NSManagedObject *removable in toRemove) {
                NSLog(@"DELETING________________________________________________%@", NSStringFromClass([removable class]));
                [self.managedObjectContext deleteObject:removable];
            }
            
            if (_objects.count > 0 && jsonHadObject) {
                for (NSDictionary *dict in _objects) {
                    //NSLog(@"Analizing dict and will created obj of type %@", [_objectClasses objectAtIndex:x]);
                    [self writeObjectOfType:[_objectClasses objectAtIndex:x] withJSONDictionary:dict andPK:[_primaryKeys objectAtIndex:x] withHolder:allObjectsOfAType];
                }
            }
            [self.delegate syncOperationFinishedWithCompleter:[_objectClasses objectAtIndex:x] andProcessedObjects:_objectsInBatch andBlock:self.block];
        }
    }
}

@end


