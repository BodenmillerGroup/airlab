//
//  Panel.h
//  AirLab
//
//  Created by Raul Catena on 2/8/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"


@interface Panel : Object

@property (nonatomic, retain) NSString * panDetails;
@property (nonatomic, retain) NSString * panName;
@property (nonatomic, retain) NSString * panPanelId;
@property (nonatomic, retain) NSNumber * zetIsOwn;

@end
