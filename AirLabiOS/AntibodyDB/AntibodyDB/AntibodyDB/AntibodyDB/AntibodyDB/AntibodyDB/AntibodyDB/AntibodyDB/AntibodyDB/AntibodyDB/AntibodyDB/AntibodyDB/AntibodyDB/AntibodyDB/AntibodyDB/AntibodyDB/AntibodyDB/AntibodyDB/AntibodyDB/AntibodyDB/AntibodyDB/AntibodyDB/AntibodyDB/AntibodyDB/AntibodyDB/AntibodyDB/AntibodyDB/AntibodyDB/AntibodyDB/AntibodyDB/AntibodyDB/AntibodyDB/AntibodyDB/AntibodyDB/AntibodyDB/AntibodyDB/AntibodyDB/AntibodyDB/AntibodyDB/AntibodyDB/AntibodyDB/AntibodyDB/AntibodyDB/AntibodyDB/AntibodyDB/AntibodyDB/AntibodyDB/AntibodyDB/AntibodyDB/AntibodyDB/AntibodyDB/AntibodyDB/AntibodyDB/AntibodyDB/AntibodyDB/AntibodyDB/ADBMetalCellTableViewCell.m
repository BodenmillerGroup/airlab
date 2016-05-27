//
//  ADBMetalCellTableViewCell.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/8/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMetalCellTableViewCell.h"
#import "ADBAppDelegate.h"
#import "LabeledAntibody.h"
#import "Lot.h"
#import "Protein.h"
#import "Clone.h"

@implementation ADBMetalCellTableViewCell

@synthesize delegate;
@synthesize tagMetal = _tagMetal;
@synthesize antibodies;


-(NSManagedObjectContext *)managedObjectContext{
    ADBAppDelegate *appDelegate = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
    return appDelegate.managedObjectContext;
}

-(void)setTagMetal:(Tag *)tagMetal{
    _tagMetal = tagMetal;
    //NSArray *antibodies = [self.delegate getAntibodiesForTag:_tagMetal];
    
    __block int y = 0;
    __block int x = 0;
        NSLog(@"0");
    for (LabeledAntibody *antibody in antibodies) {
        BOOL human = NO;
        BOOL mouse = NO;
        for (ZCloneSpeciesProtein *linker in antibody.lot.clone.cloneSpeciesProteins) {
            if([linker.speciesProtein.species.spcName isEqualToString:@"Human"])human = YES;
            if([linker.speciesProtein.species.spcName isEqualToString:@"Mouse"])mouse = YES;
            if (human == YES && mouse == YES) {
                break;
            }
        }
        NSLog(@"1");
        UIColor *color;
        if(antibody.labCellsUsedForValidation.length > 0 || antibody.lot.lotCellsValidation.length > 0 || antibody.lot.validationExperiments.count > 0){
            NSArray *array = [General arrayOfValidationNotesForLot:antibody.lot andConjugate:antibody];
            color = [General colorForValidationNotesDictionaryArray:array];
            //color = [UIColor colorWithRed:0 green:0.4 blue:0 alpha:1];
        }else{
            color = [UIColor grayColor];
        }
                NSLog(@"2");
        if(antibody.deleted.boolValue)
            color = [color colorByChangingAlphaTo:0.2];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([self.delegate isConjugateInPanel:antibody]) {
            button.backgroundColor = color;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            button.backgroundColor = [UIColor clearColor];
            [button setTitleColor:color forState:UIControlStateNormal];
        }
        
        
        
        button.titleLabel.numberOfLines = 2;
        button.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        
        
        [General addBorderToButton:button withColor:color];
        
        button.titleLabel.lineBreakMode = NSLineBreakByClipping;
        [button setTitle:[NSString stringWithFormat:@"%@ | %@", antibody.lot.clone.protein.proName, antibody.lot.clone.cloName] forState:UIControlStateNormal];
        if (antibody.lot.clone.cloIsPhospho.boolValue) {
            [button setTitle:[NSString stringWithFormat:@"p-%@", button.titleLabel.text] forState:UIControlStateNormal];
        }
        button.tag = [antibodies indexOfObject:antibody];
        
        [General iPhoneBlock:^{
            button.frame = CGRectMake( x*160, y*45, self.bounds.size.width - 180, 40);
        } iPadBlock:^{
            button.frame = CGRectMake( x*160, y*45, 150, 40);
        }];
        
        if ([self.delegate isRelated:antibody]) {
            button.layer.borderWidth = 10.0f;
            button.layer.borderColor = [UIColor purpleColor].CGColor;
        }
        
        float distance = 15;
        if (human == YES) {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(button.bounds.size.width - distance, 25, 14, 14)];
            label.text = @" H";
            label.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
            label.textColor = color;
            label.clipsToBounds = YES;
            label.layer.borderColor = color.CGColor;
            label.layer.borderWidth = 1.0f;
            label.font = [UIFont systemFontOfSize:10.0f];
            label.layer.cornerRadius = label.bounds.size.width/2;
            [button addSubview:label];
            distance = distance + 15.0f;
        }
        if (mouse == YES) {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(button.bounds.size.width -distance, 25, 14, 14)];
            label.text = @" M";
            label.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
            label.textColor = color;
            label.clipsToBounds = YES;
            label.layer.borderColor = color.CGColor;
            label.layer.borderWidth = 1.0f;
            label.font = [UIFont systemFontOfSize:10.0f];
            label.layer.cornerRadius = label.bounds.size.width/2;
            [button addSubview:label];
        }
        button.clipsToBounds = YES;
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        UITapGestureRecognizer *tapThrice = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapThrice:)];//
        tapThrice.numberOfTouchesRequired = 2;
        [button addGestureRecognizer:tapThrice];
        
        UILongPressGestureRecognizer *longP = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        [button addGestureRecognizer:longP];
        
        UISwipeGestureRecognizer *swipeLeftRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tripleTap:)];
        [swipeLeftRight setDirection:(UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft )];
        [button addGestureRecognizer:swipeLeftRight];
        
        x++;
        
        [General iPhoneBlock:^{
            x = 0;
            y++;
            button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        } iPadBlock:^{
            if (x > (int)floorf(self.buttonsView.bounds.size.width / 160.f)-1) {
                x = 0;
                y++;
            }
        }];
        //if (x>3){
        
        [self.buttonsView addSubview:button];
    }
    
}

- (void)awakeFromNib
{
    
}

-(void)buttonTapped:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    
    NSArray *antibodiesArray = [self.delegate getAntibodiesForTag:_tagMetal];
    LabeledAntibody *labeled = (LabeledAntibody *)[antibodiesArray objectAtIndex:sender.tag];
    if (![self.delegate isConjugateInPanel:labeled]) {
        [self.delegate cleanCellForConjugates:antibodiesArray];
    }
    [self.delegate didSelectConjugate:labeled];
}

-(void)tapThrice:(UITapGestureRecognizer *)sender{
    UIButton *button = (UIButton *)sender.view;
    if (!button.selected) {
        button.selected = YES;
    }
    
    NSArray *antibodiesArray = [self.delegate getAntibodiesForTag:_tagMetal];
    LabeledAntibody *labeled = (LabeledAntibody *)[antibodiesArray objectAtIndex:button.tag];
    [self.delegate didSelectConjugate:labeled];
}

-(void)longPress:(UILongPressGestureRecognizer *)sender{
    UIButton *button = (UIButton *)sender.view;
    NSArray *antibodiesArray = [self.delegate getAntibodiesForTag:_tagMetal];
    LabeledAntibody *labeled = (LabeledAntibody *)[antibodiesArray objectAtIndex:button.tag];
    [self.delegate showInfoFor:labeled];
}

-(void)tripleTap:(UISwipeGestureRecognizer *)sender{
    UIButton *button = (UIButton *)sender.view;
    NSArray *antibodiesArray = [self.delegate getAntibodiesForTag:_tagMetal];
    LabeledAntibody *labeled = (LabeledAntibody *)[antibodiesArray objectAtIndex:button.tag];
    [self.delegate showRelatedFor:labeled];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
