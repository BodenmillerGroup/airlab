//
//  ADBAddConjugateViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 3/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBTagsViewController.h"
#import "ADBCloneSelectorViewController.h"

@protocol AddConjugateProtocol;


@interface ADBAddConjugateViewController : ADBMasterViewController <SelectedTagProtocol, CloneSelected>

@property (nonatomic, strong) LabeledAntibody *conjugate;
@property (nonatomic, weak) id<AddConjugateProtocol>delegate;
@property (nonatomic, weak) IBOutlet UIButton *cloneLotSelector;
@property (nonatomic, weak) IBOutlet UIButton *tagSelector;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) IBOutlet UILabel *concLabel;
@property (weak, nonatomic) IBOutlet UISlider *concentration;

-(IBAction)selectTag:(UIButton *)sender;
-(IBAction)selectCloneAndLot:(UIButton *)sender;
-(IBAction)concentrationChanged:(UISlider *)sender;

@end

@protocol AddConjugateProtocol <NSObject>

-(void)addConjugate:(ADBAddConjugateViewController *)controller;

@end
