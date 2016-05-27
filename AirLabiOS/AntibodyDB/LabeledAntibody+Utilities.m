//
//  LabeledAntibody+Utilities.m
// AirLab
//
//  Created by Raul Catena on 8/6/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "LabeledAntibody+Utilities.h"

@implementation LabeledAntibody (Utilities)
-(Protein *)protein{
    return self.lot.clone.protein;
}
@end
