//
//  Tag.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"

@class LabeledAntibody;

@interface Tag : Object

@property (nonatomic, retain) NSString * tagEmission;
@property (nonatomic, retain) NSString * tagExcitation;
@property (nonatomic, retain) NSString * tagIsFluorphore;
@property (nonatomic, retain) NSString * tagIsMetal;
@property (nonatomic, retain) NSString * tagMW;
@property (nonatomic, retain) NSString * tagName;
@property (nonatomic, retain) NSString * tagTagId;
@property (nonatomic, retain) NSSet *labeledAntibodies;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addLabeledAntibodiesObject:(LabeledAntibody *)value;
- (void)removeLabeledAntibodiesObject:(LabeledAntibody *)value;
- (void)addLabeledAntibodies:(NSSet *)values;
- (void)removeLabeledAntibodies:(NSSet *)values;

@end
