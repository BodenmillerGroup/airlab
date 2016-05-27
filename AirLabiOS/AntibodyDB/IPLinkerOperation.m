//
//  IPLinkerOperation.m
//  iPorra
//
//  Created by Raul Catena on 2/3/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "IPLinkerOperation.h"
#import <objc/runtime.h>


@interface IPLinkerOperation()

@property (nonatomic, strong) NSString * childClass;
@property (nonatomic, strong) NSString * childFK;
@property (nonatomic, strong) NSString * parentClass;
@property (nonatomic, strong) NSString * propertyInChild;
@property (nonatomic, strong) NSDictionary *keysDictionary;


@end

@implementation IPLinkerOperation

@synthesize childClass = _childClass;
@synthesize childFK = _childFK;
@synthesize parentClass = _parentClass;
@synthesize propertyInChild = _propertyInChild;
@synthesize delegate;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize keysDictionary = _keysDictionary;

-(NSManagedObjectContext *)managedObjectContext{
    if (!_managedObjectContext) {
        ADBAppDelegate *del = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
        _managedObjectContext = del.workerManagedObjectContext;
    }
    return _managedObjectContext;
}

-(id)initWithChildClass:(NSString *)childClass childFK:(NSString *)childFK parentClass:(NSString *)parentClass propertyInChild:(NSString *)propertyInChild andManagedObjectContext:(NSManagedObjectContext *)moc andKeysDictionary:(NSDictionary *)dictionary{
    if (self = [super init]) {
        self.childClass = childClass;
        self.childFK = childFK;
        self.parentClass = parentClass;
        self.propertyInChild = propertyInChild;
        self.keysDictionary = dictionary;
        self.nameOfOp = [NSString stringWithFormat:@"%@+%@", childClass, parentClass];
    }
    return self;
}

-(NSString *)keyOfObject:(NSString *)object{
    if (!_keysDictionary) {
        self.keysDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"primaryKeys" ofType:@"plist"]];
    }
    return [_keysDictionary valueForKey:object];
}

//New methods consuming Slim API


-(BOOL)analyzeObject:(id)object forPropertyKey:(NSString *)key{
    id currentClass = [object class];
    NSString *propertyName;
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(currentClass, &outCount);
    for (i = 0; i < outCount; i++) {
    	objc_property_t property = properties[i];
    	propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];//stringWithCString:property_getName(property)];
    	//[self doSomethingCoolWithValue:[self valueForKey:propertyName]];
        //NSLog(@"property search %@ in %@", key, propertyName);
        if ([key isEqualToString:propertyName]) {
            //NSLog(@"found property %@", key);
            return YES;
        }
    }
    return NO;
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
        

-(void)main{
    @autoreleasepool {
        //DON'T DISPATCH TO ANOTHER QUEUE. WE ARE ALREADY IN ANOTHER QUEUE, THE ONE WE ADD THIS OBJECT TO
        
        //const char * name = [[NSString stringWithFormat:@"%@+%@", self.childClass, self.parentClass]UTF8String];
        //dispatch_queue_t aQueue = dispatch_queue_create(name, NULL);
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        if (!_managedObjectContext) {
            [self managedObjectContext];
        }

        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:self.parentClass];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:[self keyOfObject:self.parentClass] ascending:YES]];
        NSArray *arrayResults = [self.managedObjectContext executeFetchRequest:request error:nil];
  
        NSLog(@"Conectando %@-%@ %@-%@", _childClass, _childFK, _parentClass, _propertyInChild);
        NSFetchRequest *requestB = [NSFetchRequest fetchRequestWithEntityName:self.childClass];
        requestB.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:[self keyOfObject:self.childClass] ascending:YES]];
        NSArray *arrayResultsB = [_managedObjectContext executeFetchRequest:requestB error:nil];
        //NSLog(@"Will do parent %@ (%i) and child %@ (%i)", _parentClass, arrayResults.count, _childClass, arrayResultsB.count);
        NSMutableArray *removables = [NSMutableArray arrayWithArray:arrayResultsB];
        for (NSManagedObject *parent in arrayResults) {
            for (NSManagedObject *child in arrayResultsB) {
                
                
                if ([[child valueForKey:self.childFK]isEqualToString:[parent valueForKey:[self keyOfObject:self.parentClass]]]) {
                    if (![child valueForKey:self.propertyInChild]) {
                        [child setValue:parent forKey:self.propertyInChild];
                    }
                    
                    [removables removeObject:child];
                }
            }
            if (removables.count == 0) {
                break;
            }
        }

        [[NSUserDefaults standardUserDefaults]setValue:[NSDate date].description forKey:@"LAST_SYNC"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self.delegate linkerOperationFinished];
    
    }
}

@end
