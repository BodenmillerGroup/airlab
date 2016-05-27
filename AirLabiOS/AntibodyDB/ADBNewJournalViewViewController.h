//
//  ADBNewJournalViewViewController.h
//  AirLab
//
//  Created by Raul Catena on 7/3/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBPartViewCellTableViewCell.h"
#import "ADBUtilitiesViewController.h"
#import "ADBAllReagentsPickerViewController.h"
#import "ADBAllSamplesViewController.h"
#import "ADBPanelsViewController.h"
#import "ADBTemplaterViewController.h"
#import "ADBAddPanelToExpViewController.h"
#import "ADBSelectFileViewController.h"

@interface ADBNewJournalViewViewController : ADBMasterViewController<PartViewDelegate, Pintado, PlateGenerator, AddFileToPart, SelectedPanel, SelectedReagentInstance, SelectedSample, PanelToExp>

@property (nonatomic, strong) IBOutlet UIToolbar *optionsButton;
@property (nonatomic, weak) UITextView *currentTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andEnsayo:(Ensayo *)ensayo;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andLot:(Lot *)lot andConj:(LabeledAntibody *)conjugate;

@end
