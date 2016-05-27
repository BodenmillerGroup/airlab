//
//  ADBApplicationType.h
// AirLab
//
//  Created by Raul Catena on 10/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADBApplicationType : NSObject

+(NSString *)applicationForInt:(int)integer;
+(NSNumber *)worksForFlow:(NSDictionary *)dictionary;
+(NSNumber *)worksForImaging:(NSDictionary *)dictionary;
+(NSNumber *)worksForApplication:(int)applicationCode dict:(NSDictionary *)dict orJsonString:(NSString *)jsonString;
+(UIColor *)colorForFlow:(NSDictionary *)dictionary;
+(UIColor *)colorForImaging:(NSDictionary *)dictionary;
+(UIColor *)colorForApplication:(int)applicationCode dict:(NSDictionary *)dict orJsonString:(NSString *)jsonString;

@end
