//
//  ADBTimerTask.m
//  AirLab
//
//  Created by Raul Catena on 10/26/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBTimerTask.h"

@interface ADBTimerTask (){
    int time;
}

@property (nonatomic, strong) NSString * message;

@end

@implementation ADBTimerTask

-(id)initWithTime:(int)timeCount andMessage:(NSString *)message andId:(NSString *)taskId{
    self = [self init];
    if (self) {
        time = timeCount;
        self.message = message;
        self.taskId = taskId;
    }
    return self;
}

-(NSString *)timeMissing{
    NSLog(@"Returning %i", time);
    return [NSString stringWithFormat:@"%i", time];
}

-(void)substract{
    if (time <= 0) {
        [timer invalidate];
        [General showOKAlertWithTitle:@"Time is up" andMessage:_message];
        [self.delegate removeFromLine:self];
    }
    time--;
}
-(void)resume{
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(substract) userInfo:nil repeats:YES];
}
-(void)stop{
    [timer invalidate];
}
@end

