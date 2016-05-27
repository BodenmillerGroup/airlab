//
//  ADBApplicationType.m
// AirLab
//
//  Created by Raul Catena on 10/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBApplicationType.h"

@implementation ADBApplicationType

+(NSString *)applicationForInt:(int)integer{
    NSString *toRet;
    switch (integer) {
        case 0:
            toRet = @"CyTOF";
            break;
        case 1:
            toRet = @"CyTOF-i";
            break;
        case 2:
            toRet = @"Flow Cytometry";
            break;
        case 3:
            toRet = @"IF";
            break;
        case 4:
            toRet = @"IHC";
            break;
            
        default:
            toRet = @"";
            break;
    }
    return toRet;
}

+(NSNumber *)worksForFlow:(NSDictionary *)dictionary{
    if ([dictionary valueForKey:@"0"]) {
        return [NSNumber numberWithBool:[[dictionary valueForKey:@"0"]boolValue]];
    }
    if ([dictionary valueForKey:@"2"]) {
        return [NSNumber numberWithBool:[[dictionary valueForKey:@"2"]boolValue]];
    }
    return nil;
}

+(NSNumber *)worksForImaging:(NSDictionary *)dictionary{
    if ([dictionary valueForKey:@"1"]) {
        return [NSNumber numberWithBool:[[dictionary valueForKey:@"1"]boolValue]];
    }
    if ([dictionary valueForKey:@"3"]) {
        return [NSNumber numberWithBool:[[dictionary valueForKey:@"3"]boolValue]];
    }
    if ([dictionary valueForKey:@"4"]) {
        return [NSNumber numberWithBool:[[dictionary valueForKey:@"4"]boolValue]];
    }
    return nil;
}

+(NSNumber *)worksForApplication:(int)applicationCode dict:(NSDictionary *)dict orJsonString:(NSString *)jsonString{
    NSDictionary *theDict;
    if (dict) {
        theDict = dict;
    }else{
        theDict = [General jsonStringToObject:jsonString];
    }
    if ([theDict valueForKey:[NSString stringWithFormat:@"%i", applicationCode]]) {
        return [theDict valueForKey:[NSString stringWithFormat:@"%i", applicationCode]];
    }
   
    return nil;
}

+(UIColor *)colorForFlow:(NSDictionary *)dictionary{
    if ([dictionary valueForKey:@"0"]) {
        BOOL boolValue = [[dictionary valueForKey:@"0"]boolValue];
        return !boolValue?[UIColor redColor]:[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
    }
    if ([dictionary valueForKey:@"2"]) {
        BOOL boolValue = [[dictionary valueForKey:@"2"]boolValue];
        return !boolValue?[UIColor redColor]:[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
    }
    return [UIColor lightGrayColor];
}

+(UIColor *)colorForImaging:(NSDictionary *)dictionary{
    if ([dictionary valueForKey:@"1"]) {
        BOOL boolValue = [[dictionary valueForKey:@"1"]boolValue];
        return !boolValue?[UIColor redColor]:[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
    }
    if ([dictionary valueForKey:@"3"]) {
        BOOL boolValue = [[dictionary valueForKey:@"3"]boolValue];
        return !boolValue?[UIColor redColor]:[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
    }
    if ([dictionary valueForKey:@"4"]) {
        BOOL boolValue = [[dictionary valueForKey:@"4"]boolValue];
        return !boolValue?[UIColor redColor]:[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
    }
    return [UIColor lightGrayColor];
}

+(UIColor *)colorForApplication:(int)applicationCode dict:(NSDictionary *)dict orJsonString:(NSString *)jsonString{
    NSDictionary *theDict;
    if (dict) {
        theDict = dict;
    }else{
        theDict = [General jsonStringToObject:jsonString];
    }
    if ([theDict valueForKey:[NSString stringWithFormat:@"%i", applicationCode]]) {
        BOOL boolValue = [[NSDictionary valueForKey:[NSString stringWithFormat:@"%i", applicationCode]]boolValue];
        return !boolValue?[UIColor redColor]:[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
    }
    
    return [UIColor lightGrayColor];
}


@end
