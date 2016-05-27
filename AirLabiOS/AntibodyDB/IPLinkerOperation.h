//
//  IPLinkerOperation.h
//  iPorra
//
//  Created by Raul Catena on 2/3/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LinkerOperationDelegate;

@interface IPLinkerOperation : NSOperation

@property (nonatomic, assign) id<LinkerOperationDelegate>delegate;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSString *nameOfOp;

-(id)initWithChildClass:(NSString *)childClass childFK:(NSString *)childFK parentClass:(NSString *)parentClass propertyInChild:(NSString *)propertyInChild andManagedObjectContext:(NSManagedObjectContext *)moc andKeysDictionary:(NSDictionary *)dictionary;

@end

@protocol LinkerOperationDelegate <NSObject>

-(void)linkerOperationFinished;

@end
