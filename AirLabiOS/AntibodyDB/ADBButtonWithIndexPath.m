//
//  ADBButtonWithIndexPath.m
// AirLab
//
//  Created by Raul Catena on 6/24/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBButtonWithIndexPath.h"

@interface ADBButtonWithIndexPath()


@end

@implementation ADBButtonWithIndexPath

- (id)initWithFrame:(CGRect)frame andIndexPath:(NSIndexPath *)ip
{
    self = [super initWithFrame:frame];
    if (self) {
        self.indexPath = ip;
    }
    return self;
}

@end
