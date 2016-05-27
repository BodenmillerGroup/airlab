//
//  ADBMetalPanelCellTableViewCell.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADBKeyBoardViewController.h"


@protocol MetalPanelCellDelegate <NSObject>

-(float)microLiterOfConjugate:(ZPanelLabeledAntibody *)linker;
-(void)showInfoFor:(int)tag;

@end

@interface ADBMetalPanelCellTableViewCell : UITableViewCell <KeyboardProtocol>

@property (weak, nonatomic) IBOutlet UILabel *volumenToAdd;
@property (weak, nonatomic) IBOutlet UILabel *actualConcentration;
@property (weak, nonatomic) IBOutlet UILabel *concentration;
@property (weak, nonatomic) IBOutlet UILabel *conjugateInfo;

@property (assign, nonatomic) id<MetalPanelCellDelegate>delegate;

@property (strong, nonatomic) ZPanelLabeledAntibody *linker;

//- (IBAction)stepperChanged:(UIStepper *)sender;

@end
