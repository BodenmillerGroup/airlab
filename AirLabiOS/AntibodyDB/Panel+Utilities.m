//
//  Panel+Panel_Utilities.m
//  AirLab
//
//  Created by Raul Catena on 6/4/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import "Panel+Utilities.h"

@implementation Panel (Utilities)


-(NSNumber *)isOwn{
//    if (!self.zetIsOwn) {
//        BOOL theBool = NO;
//        if (self.createdBy.intValue == [[ADBAccountManager sharedInstance]currentGroupPerson].gpeGroupPersonId.intValue) {
//            theBool = YES;
//        }
//        self.zetIsOwn = [NSNumber numberWithInteger:self.panPanelId.intValue];
//        [General saveContextAndRoll];
//    }
//    return self.zetIsOwn;
    
    
    
    BOOL theBool = NO;
    if (self.createdBy.intValue == [[ADBAccountManager sharedInstance]currentGroupPerson].gpeGroupPersonId.intValue) {
        theBool = YES;
    }
    self.zetIsOwn = [NSNumber numberWithBool:theBool];
    [General saveContextAndRoll];
    return self.zetIsOwn;
}

@end
