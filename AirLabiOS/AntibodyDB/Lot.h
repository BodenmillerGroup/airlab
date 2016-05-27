//
//  Lot.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ReagentInstance.h"

@class Carrier, Clone, Ensayo, LabeledAntibody, Provider, ReagentInstance, ZLotEnsayo;

@interface Lot : ReagentInstance

@property (nonatomic, retain) NSString * lotBuffer;
@property (nonatomic, retain) NSString * lotCellsValidation;
@property (nonatomic, retain) NSString * lotCloneId;
@property (nonatomic, retain) NSString * lotConcentration;
@property (nonatomic, retain) NSString * lotConditions;
@property (nonatomic, retain) NSString * lotDataSheetLink;
@property (nonatomic, retain) NSString * lotExpirationDate;
@property (nonatomic, retain) NSString * lotHasCarrier;
@property (nonatomic, retain) NSString * lotLotId;
@property (nonatomic, retain) NSString * lotNumber;
@property (nonatomic, retain) NSString * lotProviderId;
@property (nonatomic, retain) NSString * lotReagentInstanceId;
@property (nonatomic, retain) NSNumber * zetConfirmed;
@property (nonatomic, retain) Carrier *carrier;
@property (nonatomic, retain) Clone *clone;
@property (nonatomic, retain) NSSet *labeledAntibodies;
@property (nonatomic, retain) NSSet *lotEnsayos;
@property (nonatomic, retain) Provider *provider;
@property (nonatomic, retain) ReagentInstance *reagentInstance;
@property (nonatomic, retain) NSSet *validationExperiments;
@end

@interface Lot (CoreDataGeneratedAccessors)

- (void)addLabeledAntibodiesObject:(LabeledAntibody *)value;
- (void)removeLabeledAntibodiesObject:(LabeledAntibody *)value;
- (void)addLabeledAntibodies:(NSSet *)values;
- (void)removeLabeledAntibodies:(NSSet *)values;

- (void)addLotEnsayosObject:(ZLotEnsayo *)value;
- (void)removeLotEnsayosObject:(ZLotEnsayo *)value;
- (void)addLotEnsayos:(NSSet *)values;
- (void)removeLotEnsayos:(NSSet *)values;

- (void)addValidationExperimentsObject:(Ensayo *)value;
- (void)removeValidationExperimentsObject:(Ensayo *)value;
- (void)addValidationExperiments:(NSSet *)values;
- (void)removeValidationExperiments:(NSSet *)values;

@end
