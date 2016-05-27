//
//  ADBNotificationCenter.h
//  AirLab
//
//  Created by Raul Catena on 11/6/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ADBNotificationCenter : NSObject


-(int)unseenForRequest:(NSFetchRequest *)request;
-(int)unseenForArray:(NSArray *)array ofClass:(NSString *)aclass;

@end
