//
//  ADBAccountManager.h
// AirLab
//
//  Created by Raul Catena on 5/20/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface ADBAccountManager : NSObject

+(ADBAccountManager *)sharedInstance;
-(Person *)currentUser;
-(ZGroupPerson *)currentGroupPerson;
-(NSArray *)allGroupPersonOfCurrentPerson;
-(NSArray *)groupsOfCurrentPerson;
-(NSArray *)allGroupMembers;
-(void)logOff;
-(void)logInWithEmail:(NSString *)login andPassword:(NSString *)password;
-(void)createAccountWithEmail:(NSString *)login andPassword:(NSString *)password;
-(void)requestNewPassword:(NSString *)email;
-(void)addPersonGroup:(ZGroupPerson *)personGroup toObject:(Object *)object;
-(void)inactivateByPersonGroup:(ZGroupPerson *)personGroup toObject:(Object *)object;
-(void)showLoginIfNecessary;
-(void)acceptPersonGroup:(ZGroupPerson *)groupPerson;
-(void)removePersonGroup:(ZGroupPerson *)groupPerson;
-(NSString *)postForGroup;
-(void)checkNeedErase;
-(void)invite:(NSString *)email;

@end
