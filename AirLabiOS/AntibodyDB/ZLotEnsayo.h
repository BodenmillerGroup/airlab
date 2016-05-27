//
//  ZLotEnsayo.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class Ensayo, Lot;

@interface ZLotEnsayo : Object

@property (nonatomic, retain) NSString * lenEnsayoId;
@property (nonatomic, retain) NSString * lenLotEnsayoId;
@property (nonatomic, retain) NSString * lenLotId;
@property (nonatomic, retain) Ensayo *ensayo;
@property (nonatomic, retain) Lot *lot;

@end
