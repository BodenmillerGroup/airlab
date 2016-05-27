//
//  ADBNotificationCenter.m
//  AirLab
//
//  Created by Raul Catena on 11/6/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBNotificationCenter.h"

@implementation ADBNotificationCenter

-(int)unseenForRequest:(NSFetchRequest *)request{
    NSError *error;
    NSArray *array = [[(ADBAppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext]executeFetchRequest:request error:&error];
    if(error)[General logError:error];
    int result = 0;
    for (Object *rei in array) {
        NSDate *dataA = [General getNSDateFromDescription:rei.createdAt];
        
        NSDate *dateB = [General getNSDateFromDescription:[[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"CHECKED_DASHBOARD_%@", request.predicate.predicateFormat]]];
        
        if ([dataA compare:dateB] == NSOrderedDescending) {
            result++;
        }/* else if ([dataA compare:dateB] == NSOrderedAscending) {
            NSLog(@"date1 is earlier than date2");
        } else {
            NSLog(@"dates are the same");
        }*/
    }
    return result;
}

-(int)unseenForArray:(NSArray *)array ofClass:(NSString *)aclass{
    int result = 0;
    for (Object *rei in array) {
        NSDate *dataA = [General getNSDateFromDescription:rei.createdAt];
        NSDate *dateB = [General getNSDateFromDescription:[[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"CHECKED_DASHBOARD_%@", aclass]]];
        
        if ([dataA compare:dateB] == NSOrderedDescending) {
            result++;
        } else if ([dataA compare:dateB] == NSOrderedAscending) {
        } else {
        }
    }
    return result;
}

@end
