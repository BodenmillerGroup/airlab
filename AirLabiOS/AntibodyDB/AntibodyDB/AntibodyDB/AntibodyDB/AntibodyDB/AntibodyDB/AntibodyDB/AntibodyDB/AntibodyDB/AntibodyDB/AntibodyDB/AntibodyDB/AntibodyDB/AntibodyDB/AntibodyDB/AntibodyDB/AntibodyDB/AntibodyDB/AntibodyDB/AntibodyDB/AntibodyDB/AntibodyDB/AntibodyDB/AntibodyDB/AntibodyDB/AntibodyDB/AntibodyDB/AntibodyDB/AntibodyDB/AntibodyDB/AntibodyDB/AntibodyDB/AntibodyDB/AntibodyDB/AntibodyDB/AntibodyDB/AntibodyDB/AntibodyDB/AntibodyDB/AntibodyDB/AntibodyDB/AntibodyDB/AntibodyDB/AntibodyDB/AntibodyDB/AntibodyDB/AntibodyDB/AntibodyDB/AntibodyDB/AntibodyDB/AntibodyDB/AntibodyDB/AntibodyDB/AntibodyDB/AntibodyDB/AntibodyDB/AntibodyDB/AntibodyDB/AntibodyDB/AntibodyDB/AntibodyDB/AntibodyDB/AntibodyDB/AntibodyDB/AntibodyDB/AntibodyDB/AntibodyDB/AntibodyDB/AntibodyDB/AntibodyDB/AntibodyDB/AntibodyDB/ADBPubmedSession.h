//
//  ADBPubmedSession.h
//  AirLab
//
//  Created by Raul Catena on 10/26/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADBPubmedSession : NSObject

@property (nonatomic, retain) NSString *webEnv;
@property (nonatomic, retain) NSString *queryKey;

+(ADBPubmedSession *)sharedInstance;
-(void)reloadSession;
-(NSArray *)parseQuery:(NSData *)data;
-(NSArray *)parserTitles:(NSData *)data;
-(NSString *)parseAbstract:(NSData *)data;

@end
