//
//  ADBTimersSingleton.m
// AirLab
//
//  Created by Raul Catena on 8/7/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBTimersSingleton.h"
#import "ADBTimers.h"

@interface ADBTimersSingleton()

@property (nonatomic, strong) NSMutableArray *otherTimers;

@end

@implementation ADBTimersSingleton



+(ADBTimersSingleton *)sharedInstance{
    static dispatch_once_t pred = 0;
    __strong static ADBTimersSingleton* _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
        
    });
    return _sharedObject;
}

-(void)initAll{
    if(_theCounters)return;
    else{
        _theCounters = [NSMutableArray array];
    }
    for (int x = 0; x<4; x++) {
        ADBTimers *timer = [[ADBTimers alloc]initWithTimer:x];
        [_theCounters addObject:timer];
    }
}

-(int)timeForTask:(NSString *)taskId{
    for (ADBTimerTask *task in _otherTimers) {
        if ([task.taskId isEqualToString:taskId]) {
            return [task timeMissing].intValue;
        }
    }
    return 0;
}

-(ADBTimerTask *)timerTaskWithCode:(NSString *)code{
    for (ADBTimerTask *task in _otherTimers) {
        if ([task.taskId hasPrefix:code]) {
            return task;
        }
    }
    return nil;
}

-(void)addExternalTimer:(ADBTimerTask *)timer{
    if (!_otherTimers) {
        self.otherTimers = [NSMutableArray array];
    }
    BOOL found = NO;
    for (ADBTimerTask *task in _otherTimers) {
        if ([task.taskId isEqualToString:timer.taskId]) {
            found = YES;
        }
    }
    if (!found) {
        [_otherTimers addObject:timer];
    }
}

-(void)removeFromLine:(ADBTimerTask *)timerTask{
    [_otherTimers removeObject:timerTask];
}

-(void)removeTimeForTask:(NSString *)taskId{
    for (ADBTimerTask *task in _otherTimers) {
        if ([task.taskId hasPrefix:taskId]) {
            [_otherTimers removeObject:task];
        }
    }
}

@end
