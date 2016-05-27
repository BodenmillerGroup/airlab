//
//  ADBTimersSingleton.h
//  AntibodyDB
//
//  Created by Raul Catena on 8/7/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADBTimerTask.h"

@interface ADBTimersSingleton : NSObject<TimeDelegate>
@property (nonatomic, strong) NSMutableArray *theCounters;
+(ADBTimersSingleton *)sharedInstance;
-(void)initAll;
-(void)addExternalTimer:(ADBTimerTask *)timer;
-(int)timeForTask:(NSString *)taskId;
-(void)removeTimeForTask:(NSString *)taskId;
-(ADBTimerTask *)timerTaskWithCode:(NSString *)code;
@end
