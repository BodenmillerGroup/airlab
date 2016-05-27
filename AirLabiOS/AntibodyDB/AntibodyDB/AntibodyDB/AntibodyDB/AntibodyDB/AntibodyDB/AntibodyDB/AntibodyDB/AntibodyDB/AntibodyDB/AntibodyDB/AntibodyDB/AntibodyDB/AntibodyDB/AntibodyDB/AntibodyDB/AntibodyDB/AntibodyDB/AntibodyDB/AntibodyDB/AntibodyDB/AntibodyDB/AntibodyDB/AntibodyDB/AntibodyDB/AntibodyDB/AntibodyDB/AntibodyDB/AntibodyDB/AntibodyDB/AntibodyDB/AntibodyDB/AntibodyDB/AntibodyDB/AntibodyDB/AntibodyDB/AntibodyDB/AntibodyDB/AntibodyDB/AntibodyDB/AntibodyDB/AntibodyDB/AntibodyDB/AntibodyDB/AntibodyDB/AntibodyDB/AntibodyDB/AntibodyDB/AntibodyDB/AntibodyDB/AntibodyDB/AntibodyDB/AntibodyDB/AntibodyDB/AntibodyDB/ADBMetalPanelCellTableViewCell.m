//
//  ADBMetalPanelCellTableViewCell.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMetalPanelCellTableViewCell.h"


@implementation ADBMetalPanelCellTableViewCell

@synthesize linker = _linker;

-(void)layoutOfCell{
    LabeledAntibody *conjugate = _linker.labeledAntibody;
    
    [General iPhoneBlock:^{self.concentration.textAlignment = NSTextAlignmentRight;} iPadBlock:nil];
    
    NSString *prePhospho = @"";
    if (conjugate.lot.clone.cloIsPhospho.boolValue) {
        prePhospho = @"p-";
    }
    
    self.conjugateInfo.text = [NSString stringWithFormat:@"%@%@ - %@%@ (%@) Tube # %@", conjugate.tag.tagMW, conjugate.tag.tagName, prePhospho,conjugate.lot.clone.protein.proName, conjugate.lot.clone.cloName, conjugate.labBBTubeNumber];
    
    
    UIColor *color;
    
    if(conjugate.deleted.boolValue){
        color = [UIColor colorWithWhite:0.9 alpha:1];
    }else{
        if(conjugate.labCellsUsedForValidation.length > 0 || conjugate.lot.lotCellsValidation.length > 0 || conjugate.lot.validationExperiments.count > 0){
            NSArray *array = [General arrayOfValidationNotesForLot:conjugate.lot andConjugate:conjugate];
            color = [General colorForValidationNotesDictionaryArray:array];
        }else{
            color = [UIColor darkGrayColor];
        }
    }
    
    self.conjugateInfo.textColor = color;

    
    float microL = [self.delegate microLiterOfConjugate:_linker];
    self.concentration.text = [NSString stringWithFormat:@"Conc.: %@ ug/mL", conjugate.labConcentration];
    self.actualConcentration.text = [NSString stringWithFormat:@"Staining conc.: %@ ug/mL", _linker.plaActualConc];
    self.volumenToAdd.text = [NSString stringWithFormat:@"%.2f uL", microL];
    
    [[self actualConcentration]addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapActualConc:)]];
    [self.conjugateInfo addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)]];
}


-(void)longPress:(UITapGestureRecognizer *)sender{
    [self.delegate showInfoFor:self.tag];
}

-(void)tapActualConc:(UITapGestureRecognizer *)gesture{
    ADBKeyBoardViewController *keyB = [[ADBKeyBoardViewController alloc]init];
    keyB.zdelegate = self;
    [(ADBMasterViewController *)self.delegate showModalOrPopoverWithViewController:keyB withFrame:gesture.view.superview.frame];
}

-(void)sendNumber:(NSString *)number{
    _linker.plaActualConc = [NSString stringWithFormat:@"%.2f", number.floatValue];
    [(ADBMasterViewController *)self.delegate dismissModalOrPopover];
    [[(ADBMasterViewController *)self.delegate tableView]reloadData];
}

-(void)setLinker:(ZPanelLabeledAntibody *)linker{
    _linker = linker;
    [self layoutOfCell];
    
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
