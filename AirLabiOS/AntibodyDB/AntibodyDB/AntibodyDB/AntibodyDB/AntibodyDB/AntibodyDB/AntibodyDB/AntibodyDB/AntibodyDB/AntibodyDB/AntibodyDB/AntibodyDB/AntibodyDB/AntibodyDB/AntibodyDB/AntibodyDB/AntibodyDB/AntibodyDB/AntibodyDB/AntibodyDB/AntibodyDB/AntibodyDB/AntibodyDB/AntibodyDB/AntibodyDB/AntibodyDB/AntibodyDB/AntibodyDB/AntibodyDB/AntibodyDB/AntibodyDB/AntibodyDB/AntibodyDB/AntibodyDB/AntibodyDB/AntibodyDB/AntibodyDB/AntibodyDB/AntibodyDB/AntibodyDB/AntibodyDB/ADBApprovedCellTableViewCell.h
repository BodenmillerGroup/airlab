//
//  ADBApprovedCellTableViewCell.h
//  AntibodyDB
//
//  Created by Raul Catena on 6/14/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADBAlmacenCellTableViewCell.h"

@protocol ApprovedCellProtocol <NSObject>

-(void)didOrder:(ComertialReagent *)reagent;

@end

@interface ADBApprovedCellTableViewCell : ADBAlmacenCellTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *providerLabel;
@property (nonatomic, weak) IBOutlet UILabel *referenceLabel;

@property (nonatomic, weak) IBOutlet UILabel *stockLabel;
@property (nonatomic, weak) IBOutlet UILabel *stockNum;

@property (nonatomic, weak) IBOutlet UILabel *requestedLabel;
@property (nonatomic, weak) IBOutlet UILabel *requestedNum;

@property (nonatomic, weak) IBOutlet UILabel *orderedLabel;
@property (nonatomic, weak) IBOutlet UILabel *orderedNum;

@property (nonatomic, assign) id<ApprovedCellProtocol>delegate;
@property (nonatomic, weak) IBOutlet UIButton *markAsOrderedBut;
@property (nonatomic, weak) IBOutlet UIButton *materialZentrumBut;
@property (nonatomic, strong) ComertialReagent *reagent;

-(IBAction)markOrdered:(id)sender;
-(IBAction)materialZentrum:(id)sender;

@end
