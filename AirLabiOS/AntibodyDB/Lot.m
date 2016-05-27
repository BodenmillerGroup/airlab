//
//  Lot.m
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "Lot.h"
#import "Carrier.h"
#import "Clone.h"
#import "Ensayo.h"
#import "LabeledAntibody.h"
#import "Provider.h"
#import "ReagentInstance.h"
#import "ZLotEnsayo.h"


@implementation Lot

@dynamic lotBuffer;
@dynamic lotCellsValidation;
@dynamic lotCloneId;
@dynamic lotConcentration;
@dynamic lotConditions;
@dynamic lotDataSheetLink;
@dynamic lotExpirationDate;
@dynamic lotHasCarrier;
@dynamic lotLotId;
@dynamic lotNumber;
@dynamic lotProviderId;
@dynamic zetConfirmed;
@dynamic lotReagentInstanceId;
@dynamic carrier;
@dynamic clone;
@dynamic labeledAntibodies;
@dynamic lotEnsayos;
@dynamic provider;
@dynamic reagentInstance;
@dynamic validationExperiments;

@end
