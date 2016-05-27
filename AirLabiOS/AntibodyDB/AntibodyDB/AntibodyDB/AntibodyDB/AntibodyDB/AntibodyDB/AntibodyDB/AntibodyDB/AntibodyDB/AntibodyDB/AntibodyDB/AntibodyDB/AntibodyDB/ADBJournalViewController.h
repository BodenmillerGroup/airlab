//
//  ADBJournalViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 6/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBPartView.h"
#import "ADBTemplaterViewController.h"
#import "ADBSelectFileViewController.h"
#import "ADBPanelsViewController.h"
#import "ADBAllReagentsPickerViewController.h"
#import "ADBAllSamplesViewController.h"
#import "ADBAddPanelToExpViewController.h"


@interface ADBJournalViewController : ADBMasterViewController<PartViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, PartViewDelegate, PlateGenerator, AddFileToPart, SelectedPanel, SelectedReagentInstance, SelectedSample, PanelToExp>

@property (nonatomic, weak) IBOutlet UIScrollView *canvas;
@property (nonatomic, weak) IBOutlet UIToolbar *optionsButton;
@property (nonatomic, weak) UITextView *currentTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andEnsayo:(Ensayo *)ensayo;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andLot:(Lot *)lot andConj:(LabeledAntibody *)conjugate;

@end
