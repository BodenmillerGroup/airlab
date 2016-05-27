//
//  ADBAllCounters.m
//  AntibodyDB
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAllCounters.h"
#import "ADBTimers.h"
#import "ADBTimersSingleton.h"

@implementation ADBAllCounters



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.preferredContentSize = CGSizeMake(660, 500);
    self.title = @"Timers";
    int x = 0;
    int y = 0;
    int z = 0;
    [[ADBTimersSingleton sharedInstance]initAll];
    
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:scroll];
    
    for (ADBTimers *timer in [ADBTimersSingleton sharedInstance].theCounters) {
        [_allItems addObject:timer];
        [timer.view setFrame:CGRectMake(z * 311 + 20*(z+1), y * 232 + 20*(y+1), 311, 232)];
        [scroll addSubview:timer.view];
        
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            if (x%2 == 0) {
                z++;
            }else{
                y++;
                z=0;
            }
        }else{
            scroll.contentSize = CGSizeMake(scroll.contentSize.width, (x+1) * 311 + 20*(x+1));
            y++;
        }
        x++;
    }
}


@end
