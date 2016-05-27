//
//  ADBMetalPanelCellTableViewCell.m
// AirLab
//
//  Created by Raul Catena on 5/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMetalPanelCellTableViewCell.h"


@implementation ADBMetalPanelCellTableViewCell

@synthesize linker = _linker;

-(void)layoutOfCell{
    NSArray *arraySearch = [General searchDataBaseForClass:LABELEDANTIBODY_DB_CLASS withTerm:[_linker valueForKey:@"plaLabeledAntibodyId"] inField:@"labLabeledAntibodyId" sortBy:@"labLabeledAntibodyId" ascending:YES inMOC:[[IPImporter getInstance]managedObjectContext]];
    
    if (arraySearch.count > 0) {
        LabeledAntibody *conjugate = arraySearch.lastObject;
        [General iPhoneBlock:^{self.concentration.textAlignment = NSTextAlignmentRight;} iPadBlock:nil];
        
        self.conjugateInfo.text = [NSString stringWithFormat:@"%@%@ - %@\nTube # %@", conjugate.tag.tagMW, conjugate.tag.tagName, [General showFullAntibodyName:conjugate.lot.clone withSpecies:NO], conjugate.labBBTubeNumber];
        
        
        UIColor *color;
        
        if(conjugate.tubFinishedBy.intValue != 0){
            color = [UIColor colorWithWhite:0.9 alpha:1];
        }else{
            if(conjugate.labCellsUsedForValidation.length > 0 || conjugate.lot.lotCellsValidation.length > 0 || conjugate.lot.validationExperiments.count > 0){
                NSArray *array = [General jsonStringToObject:conjugate.lot.clone.catchedInfo];//[General arrayOfValidationNotesForLot:conjugate.lot andConjugate:conjugate];
                color = [General colorForValidationNotesDictionaryArray:array];
            }else{
                color = [UIColor darkGrayColor];
            }
        }
        
        if (conjugate.tubIsLow.intValue == 1) {
            if (conjugate.tubFinishedBy.intValue == 0)
                self.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:.3];
        }else{
            self.backgroundColor = [UIColor clearColor];
        }
        
        self.conjugateInfo.textColor = color;
        
        float microL = [self.delegate microLiterOfConjugate:_linker];
        self.concentration.text = [NSString stringWithFormat:@"Stock %@ ug/mL", conjugate.labConcentration];
        self.actualConcentration.text = [NSString stringWithFormat:@"Set [] %@ ug/mL", [_linker valueForKey:@"plaActualConc"]];
        
        
        //TODO propose a concentration
        /*NSArray *allPrevious = _linker.labeledAntibody.panelLabeledAntibodies.allObjects;
        NSArray *ordered = [allPrevious sortedArrayUsingComparator:^(NSDictionary * obj1, NSDictionary * obj2) {
            return [(NSString *)[obj1 objectForKey:@"plaActualConc"] compare:(NSString *)[obj2 objectForKey:@"plaActualConc"] options:NSNumericSearch];
        }];
        
        if([[_linker valueForKey:@"plaActualConc"]length] > 0)
            self.actualConcentration.text = [NSString stringWithFormat:@"Staining conc.: %@ ug/mL", [_linker valueForKey:@"plaActualConc"]];
        else{
            self.actualConcentration.text = @"Staining conc.: 0 ug/mL";
            for(ZPanelLabeledAntibody *item in ordered){
                if([[item valueForKey:@"plaActualConc"]length]>0){
                    self.actualConcentration.text = [NSString stringWithFormat:@"Staining conc.: %@ ug/mL", item.plaActualConc];
                    break;
                }
            }
        }*/
        
        
        self.volumenToAdd.text = [NSString stringWithFormat:@"%.2f uL", microL];
        
        [[self actualConcentration]addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapActualConc:)]];
        [self.conjugateInfo addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)]];
    }
    
    
}


-(void)longPress:(UITapGestureRecognizer *)sender{
    [self.delegate showInfoFor:(int)self.tag];
}

-(void)tapActualConc:(UITapGestureRecognizer *)gesture{
    if (_panel.createdBy.intValue != [[ADBAccountManager sharedInstance]currentGroupPerson].gpeGroupPersonId.intValue) {
        return;
    }
    ADBKeyBoardViewController *keyB = [[ADBKeyBoardViewController alloc]init];
    keyB.zdelegate = self;
    [(ADBMasterViewController *)self.delegate showModalOrPopoverWithViewController:keyB withFrame:gesture.view.superview.frame];
}

-(void)sendNumber:(NSString *)number{
    [_linker setValue:[NSString stringWithFormat:@"%.2f", number.floatValue] forKey:@"plaActualConc"];
    [(ADBMasterViewController *)self.delegate dismissModalOrPopover];
    [[(ADBMasterViewController *)self.delegate tableView]reloadData];
}

-(void)setLinker:(NSMutableDictionary *)linker{
    _linker = linker;
    [self layoutOfCell];
}

- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
