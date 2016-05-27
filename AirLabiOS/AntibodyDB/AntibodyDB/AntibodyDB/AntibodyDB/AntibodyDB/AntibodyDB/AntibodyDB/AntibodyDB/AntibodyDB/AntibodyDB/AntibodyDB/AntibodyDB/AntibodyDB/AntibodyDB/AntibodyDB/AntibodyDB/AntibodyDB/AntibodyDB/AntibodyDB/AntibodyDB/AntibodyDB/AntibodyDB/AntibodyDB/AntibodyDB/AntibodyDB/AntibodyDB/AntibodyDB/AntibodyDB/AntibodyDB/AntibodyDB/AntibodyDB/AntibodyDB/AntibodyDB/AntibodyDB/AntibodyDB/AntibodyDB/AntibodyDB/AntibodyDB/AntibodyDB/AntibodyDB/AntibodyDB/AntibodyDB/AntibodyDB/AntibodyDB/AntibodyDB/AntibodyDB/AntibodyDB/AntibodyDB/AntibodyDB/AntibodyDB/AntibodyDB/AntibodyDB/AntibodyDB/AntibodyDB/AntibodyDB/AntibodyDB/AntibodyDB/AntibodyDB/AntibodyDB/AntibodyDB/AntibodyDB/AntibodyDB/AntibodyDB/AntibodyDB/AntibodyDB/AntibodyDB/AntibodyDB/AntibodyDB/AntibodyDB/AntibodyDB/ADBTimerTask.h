//
//  ADBTimerTask.h
//  AirLab
//
//  Created by Raul Catena on 10/26/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADBTimerTask;
@protocol TimeDelegate <NSObject>

-(void)removeFromLine:(ADBTimerTask *)timerTask;

@end

@interface ADBTimerTask : NSObject{
    NSTimer *timer;
}


@property (nonatomic, strong) NSString *taskId;
@property (nonatomic, assign) id<TimeDelegate>delegate;

-(id)initWithTime:(int)timeCount andMessage:(NSString *)message andId:(NSString *)taskId;
-(void)stop;
-(void)resume;
-(NSString *)timeMissing;


@end
