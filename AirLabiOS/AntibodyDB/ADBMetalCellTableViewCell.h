//
//  ADBMetalCellTableViewCell.h
// AirLab
//
//  Created by Raul Catena on 5/8/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADBFlexiCloneViewController.h"

@protocol ConjugateSelected;
@class LabeledAntibody;
@class Tag;


@interface ADBMetalCellTableViewCell : UITableViewCell <FlexiClone>

@property (nonatomic, weak) IBOutlet UIView *buttonsView;
@property (nonatomic, weak) IBOutlet UILabel *tagLabel;
@property (nonatomic, strong) Tag *tagMetal;
@property (nonatomic, weak) id<ConjugateSelected>delegate;
@property (nonatomic, strong) NSArray *antibodies;
@property (nonatomic, strong) NSArray *buttons;

@end

@protocol ConjugateSelected <NSObject>

-(void)didSelectConjugate:(LabeledAntibody *)conjugate;
-(void)showInfoFor:(LabeledAntibody *)conjugate;
-(void)showRelatedFor:(LabeledAntibody *)conjugate;
-(BOOL)isConjugateInPanel:(LabeledAntibody *)conjugate;
-(BOOL)isRelated:(LabeledAntibody *)lab;
-(void)cleanCellForConjugates:(NSArray *)conjugates;
-(NSArray *)getAntibodiesForTag:(Tag *)tag;
-(Panel *)whichPanel;

@end
