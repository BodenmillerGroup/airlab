//
//  Clone+Utilities.m
//  AirLab
//
//  Created by Raul Catena on 2/7/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import "Clone+Utilities.h"

@implementation Clone (Utilities)

-(NSArray *)speciesReactive{
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *index in [self.cloReactivity componentsSeparatedByString:@","]) {
        NSArray *results = [General searchDataBaseForClass:SPECIES_DB_CLASS withTerm:index inField:@"spcSpeciesId" sortBy:@"spcSpeciesId" ascending:YES inMOC:self.managedObjectContext];
        if (results.count > 0) {
            [array addObject:results.lastObject];
        }
    }
    
    return [NSArray arrayWithArray:array];
}

-(BOOL)isMouse{
    for (NSString *index in [self.cloReactivity componentsSeparatedByString:@","]) {
        if(index.intValue == 2)return YES;
//        NSArray *results = [General searchDataBaseForClass:SPECIES_DB_CLASS withTerm:index inField:@"spcSpeciesId" sortBy:@"spcSpeciesId" ascending:YES inMOC:self.managedObjectContext];
//        if (results.count > 0) {
//            if ([(Species *)results.lastObject spcSpeciesId].intValue == 2) {
//                return YES;
//            }
//        }
    }
    
    return NO;
}

-(BOOL)isHuman{
    for (NSString *index in [self.cloReactivity componentsSeparatedByString:@","]) {
        if(index.intValue == 4)return YES;
//        NSArray *results = [General searchDataBaseForClass:SPECIES_DB_CLASS withTerm:index inField:@"spcSpeciesId" sortBy:@"spcSpeciesId" ascending:YES inMOC:self.managedObjectContext];
//        if (results.count > 0) {
//            if ([(Species *)results.lastObject spcSpeciesId].intValue == 4) {
//                return YES;
//            }
//        }
    }
    
    return NO;
}

@end
