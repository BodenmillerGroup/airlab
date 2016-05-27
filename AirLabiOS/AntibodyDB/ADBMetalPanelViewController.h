//
//  ADBMetalPanelViewController.h
// AirLab
//
//  Created by Raul Catena on 5/8/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMetalPanelCellTableViewCell.h"

@class Panel;

@protocol AddPanelDelegate <NSObject>

-(void)didAddPanel:(Panel *)panel;

@end

@interface ADBMetalPanelViewController : ADBMasterViewController<MetalPanelCellDelegate, KeyboardProtocol>

@property (nonatomic, strong) Panel *panel;
@property (nonatomic, strong) NSMutableArray *linkers;
@property (nonatomic, strong) id<AddPanelDelegate>delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPanel:(Panel *)panel;

@end
