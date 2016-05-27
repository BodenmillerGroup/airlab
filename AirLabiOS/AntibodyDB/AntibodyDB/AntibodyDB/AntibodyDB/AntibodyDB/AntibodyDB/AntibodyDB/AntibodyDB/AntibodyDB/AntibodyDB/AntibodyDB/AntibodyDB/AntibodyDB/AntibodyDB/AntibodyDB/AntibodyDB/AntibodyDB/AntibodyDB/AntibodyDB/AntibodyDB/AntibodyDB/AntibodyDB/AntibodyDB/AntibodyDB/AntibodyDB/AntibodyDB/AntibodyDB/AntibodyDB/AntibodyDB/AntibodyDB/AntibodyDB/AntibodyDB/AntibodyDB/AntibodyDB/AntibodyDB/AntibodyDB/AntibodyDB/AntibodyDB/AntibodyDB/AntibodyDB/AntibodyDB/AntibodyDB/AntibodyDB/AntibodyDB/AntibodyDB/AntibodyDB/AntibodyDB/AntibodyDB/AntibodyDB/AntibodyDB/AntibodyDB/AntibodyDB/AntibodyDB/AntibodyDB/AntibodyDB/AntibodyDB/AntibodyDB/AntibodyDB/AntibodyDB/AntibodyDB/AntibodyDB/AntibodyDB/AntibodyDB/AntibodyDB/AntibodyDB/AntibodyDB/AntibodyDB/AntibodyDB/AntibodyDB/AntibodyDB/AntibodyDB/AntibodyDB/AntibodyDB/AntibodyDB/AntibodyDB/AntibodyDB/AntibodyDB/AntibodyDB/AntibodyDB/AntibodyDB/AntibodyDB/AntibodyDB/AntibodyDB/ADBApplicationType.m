//
//  ADBApplicationType.m
//  AntibodyDB
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

@end
