//
//  ADBAlmacenCellTableViewCell.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/11/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADBAlmacenCellTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *providerLabel;
@property (nonatomic, weak) IBOutlet UILabel *referenceLabel;

@property (nonatomic, weak) IBOutlet UILabel *stockLabel;
@property (nonatomic, weak) IBOutlet UILabel *stockNum;

@property (nonatomic, weak) IBOutlet UILabel *requestedLabel;
@property (nonatomic, weak) IBOutlet UILabel *requestedNum;

@property (nonatomic, weak) IBOutlet UILabel *orderedLabel;
@property (nonatomic, weak) IBOutlet UILabel *orderedNum;

@property (nonatomic, strong) ReagentInstance *instance;

@end
