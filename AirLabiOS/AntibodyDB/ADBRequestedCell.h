//
//  ADBRequestedCell.h
// AirLab
//
//  Created by Raul Catena on 5/11/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADBAlmacenCellTableViewCell.h"

@protocol RequestedCellProtocol <NSObject>

-(void)didApproveRequest:(ComertialReagent *)reagent units:(int)units;
-(void)didRejectRequest:(ComertialReagent *)reagent;

@end

@interface ADBRequestedCell : ADBAlmacenCellTableViewCell

@property (nonatomic, weak) id<RequestedCellProtocol>delegate;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *providerLabel;
@property (nonatomic, weak) IBOutlet UILabel *referenceLabel;
@property (weak, nonatomic) IBOutlet UILabel *requesterInfo;
@property (weak, nonatomic) IBOutlet UILabel *purposeLabel;

@property (nonatomic, weak) IBOutlet UILabel *stockLabel;
@property (nonatomic, weak) IBOutlet UILabel *stockNum;

@property (nonatomic, weak) IBOutlet UILabel *requestedLabel;
@property (nonatomic, weak) IBOutlet UILabel *requestedNum;

@property (nonatomic, weak) IBOutlet UILabel *orderedLabel;
@property (nonatomic, weak) IBOutlet UILabel *orderedNum;

@property (nonatomic, weak) IBOutlet UIButton *orderBut;
@property (nonatomic, weak) IBOutlet UIStepper *stepper;

@property (nonatomic, strong) ComertialReagent *reagent;


-(IBAction)stepperChanged:(UIStepper *)sender;
-(int)unitsApproved;

@end
