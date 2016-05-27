//
//  LabeledAntibody.h
//  AirLab
//
//  Created by Raul Catena on 2/8/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Tube.h"

@class Lot, Tag;

@interface LabeledAntibody : Tube

@property (nonatomic, retain) NSString * labBBTubeNumber;
@property (nonatomic, retain) NSString * labCellsUsedForValidation;
@property (nonatomic, retain) NSString * labConcentration;
@property (nonatomic, retain) NSString * labContributorId;
@property (nonatomic, retain) NSString * labCytobankLink;
@property (nonatomic, retain) NSString * labCytofStainingConc;
@property (nonatomic, retain) NSString * labDateOfLabeling;
@property (nonatomic, retain) NSString * labLabbookRef;
@property (nonatomic, retain) NSString * labLabeledAntibodyId;
@property (nonatomic, retain) NSString * labLotId;
@property (nonatomic, retain) NSString * labRelabeled;
@property (nonatomic, retain) NSString * labTagId;
@property (nonatomic, retain) NSString * labWorkingCondition;
@property (nonatomic, retain) Lot *lot;
@property (nonatomic, retain) Tag *tag;

@end
