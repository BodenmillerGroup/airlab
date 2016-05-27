//
//  ReagentInstace+Utilities.m
//  AirLab
//
//  Created by Raul Catena on 7/13/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import "ReagentInstance+Utilities.h"

@implementation ReagentInstance (Utilities)

-(NSString *)status{
    NSString *toReturn = @"";
    if([self.reiStatus isEqualToString:@"stock"])toReturn = @"In Stock";
    if([self.reiStatus isEqualToString:@"requested"])toReturn = @"Requested";
    if([self.reiStatus isEqualToString:@"rejected"])toReturn = @"Rejected";
    if([self.reiStatus isEqualToString:@"approved"])toReturn = @"Approved";
    if([self.reiStatus isEqualToString:@"ordered"])toReturn = @"Ordered";
    if([self.reiStatus isEqualToString:@"finished"])toReturn = @"Finished";
    
    return toReturn;
}

-(UIColor *)statusColor{
    UIColor *toReturn = [UIColor blackColor];
    if([self.reiStatus isEqualToString:@"stock"])toReturn = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
    if([self.reiStatus isEqualToString:@"requested"])toReturn = [UIColor colorWithRed:0 green:0 blue:1 alpha:1];
    if([self.reiStatus isEqualToString:@"rejected"])toReturn = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    if([self.reiStatus isEqualToString:@"approved"])toReturn = [UIColor colorWithRed:1 green:0 blue:1 alpha:1];
    if([self.reiStatus isEqualToString:@"ordered"])toReturn = [UIColor colorWithRed:0 green:1 blue:1 alpha:1];
    if([self.reiStatus isEqualToString:@"finished"])toReturn = [UIColor colorWithRed:1 green:0. blue:0 alpha:1];
    return toReturn;
}

@end
