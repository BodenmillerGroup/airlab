//
//  ADBMetalPanelViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/8/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddPanelViewController.h"
#import "ADBMetalPanelCellTableViewCell.h"

@class Panel;

@interface ADBMetalPanelViewController : ADBAddPanelViewController<MetalPanelCellDelegate>

@property (nonatomic, strong) Panel *panel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPanel:(Panel *)panel;

@end
