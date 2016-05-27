//
//  ADBSector.m
//  AirLab
//
//  Created by Raul Catena on 11/3/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBSector.h"

@implementation ADBSector

@synthesize minValue, maxValue, midValue, sector;

- (NSString *) description {
    return [NSString stringWithFormat:@"%i | %f, %f, %f", self.sector, self.minValue, self.midValue, self.maxValue];
}

@end
