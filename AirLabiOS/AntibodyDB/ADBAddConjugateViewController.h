//
//  ADBAddConjugateViewController.h
// AirLab
//
//  Created by Raul Catena on 3/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBTagsViewController.h"
#import "ADBCloneSelectorViewController.h"
#import "ADBPeopleSelectorViewController.h"

@protocol AddConjugateProtocol;


@interface ADBAddConjugateViewController : ADBMasterViewController <SelectedTagProtocol, CloneSelected, PeopleSelected>

@property (nonatomic, strong) LabeledAntibody *conjugate;
@property (nonatomic, weak) id<AddConjugateProtocol>delegate;
@property (nonatomic, weak) IBOutlet UIButton *cloneLotSelector;
@property (nonatomic, weak) IBOutlet UIButton *tagSelector;
@property (nonatomic, weak) IBOutlet UIButton *personSelector;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) IBOutlet UILabel *concLabel;
@property (weak, nonatomic) IBOutlet UISlider *concentration;

-(IBAction)selectTag:(UIButton *)sender;
-(IBAction)selectPerson:(UIButton *)sender;
-(IBAction)selectCloneAndLot:(UIButton *)sender;
-(IBAction)concentrationChanged:(UISlider *)sender;
-(void)didSelectLot:(Lot *)lot;

@end

@protocol AddConjugateProtocol <NSObject>

-(void)addConjugate:(ADBAddConjugateViewController *)controller;

@end
