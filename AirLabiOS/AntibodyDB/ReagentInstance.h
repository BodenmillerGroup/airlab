//
//  ReagentInstance.h
//  AirLab
//
//  Created by Raul Catena on 2/9/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Tube.h"

@class ComertialReagent, Lot, Sample, ZGroupPerson;

@interface ReagentInstance : Tube

@property (nonatomic, retain) NSString * reiComertialReagentId;
@property (nonatomic, retain) NSString * reiOrderedAt;
@property (nonatomic, retain) NSString * reiOrderedBy;
@property (nonatomic, retain) NSString * reiReagentInstanceId;
@property (nonatomic, retain) NSString * reiApprovedAt;
@property (nonatomic, retain) NSString * reiApprovedBy;
@property (nonatomic, retain) NSString * reiReceivedAt;
@property (nonatomic, retain) NSString * reiReceivedBy;
@property (nonatomic, retain) NSString * reiRequestedAt;
@property (nonatomic, retain) NSString * reiRequestedBy;
@property (nonatomic, retain) NSString * reiStatus;
@property (nonatomic, retain) NSString * reiPurpose;
//@property (nonatomic, retain) NSString * reilotLotId;
//@property (nonatomic, retain) NSString * reilotCellsValidation;
//@property (nonatomic, retain) NSString * reilotCloneId;
//@property (nonatomic, retain) NSString * reilotConcentration;
//@property (nonatomic, retain) NSString * reilotDataSheetLink;
//@property (nonatomic, retain) NSString * reiExpirationDate;
//@property (nonatomic, retain) NSString * reilotNumber;
//@property (nonatomic, retain) NSString * reilotProviderId;
//@property (nonatomic, retain) NSString * reilotReagentInstanceId;
@property (nonatomic, retain) ZGroupPerson *approver;
@property (nonatomic, retain) ComertialReagent *comertialReagent;
@property (nonatomic, retain) Lot *lot;
@property (nonatomic, retain) ZGroupPerson *orderer;
@property (nonatomic, retain) ZGroupPerson *receiver;
@property (nonatomic, retain) ZGroupPerson *requester;
@property (nonatomic, retain) NSSet *samples;
@end

@interface ReagentInstance (CoreDataGeneratedAccessors)

- (void)addSamplesObject:(Sample *)value;
- (void)removeSamplesObject:(Sample *)value;
- (void)addSamples:(NSSet *)values;
- (void)removeSamples:(NSSet *)values;

@end
