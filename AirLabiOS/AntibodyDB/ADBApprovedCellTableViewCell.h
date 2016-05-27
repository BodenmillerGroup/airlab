//
//  ADBApprovedCellTableViewCell.h
// AirLab
//
//  Created by Raul Catena on 6/14/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADBRequestedCell.h"

@protocol ApprovedCellProtocol <NSObject>

-(void)didOrder:(ComertialReagent *)reagent;

@end

@interface ADBApprovedCellTableViewCell : ADBRequestedCell

@end
