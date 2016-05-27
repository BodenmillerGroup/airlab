//
//  ADBMetalCellTableViewCell.m
// AirLab
//
//  Created by Raul Catena on 5/8/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMetalCellTableViewCell.h"
#import "ADBAppDelegate.h"
#import "LabeledAntibody.h"
#import "ADBApplicationType.h"
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

-(void)addFlexiCloneToX:(float)x andY:(float)y{
    Panel *panel = [self.delegate whichPanel];
    NSDictionary *dict = [[General jsonStringToObject:panel.catchedInfo]valueForKey:@"sketch"];
    if (!dict)dict = [NSDictionary dictionary];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [button addTarget:self action:@selector(flexiButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    if([dict valueForKey:_tagMetal.tagTagId]){
       [button setTitle:[dict valueForKey:_tagMetal.tagTagId] forState:UIControlStateNormal];
    }
    
    [General addBorderToButton:button withColor:[UIColor grayColor]];
    
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        button.frame = CGRectMake( x*160, y*65, self.bounds.size.width - 180, 60);
    }else{
        button.frame = CGRectMake( x*160, y*65, 150, 60);
    }
    [self.buttonsView addSubview:button];
}

-(void)setTagMetal:(Tag *)tagMetal{
    _tagMetal = tagMetal;
    for (UIView *view in self.buttonsView.subviews) {
        [view removeFromSuperview];
    }
    
    self.tagLabel.text = [NSString stringWithFormat:@"%@\n%@", _tagMetal.tagMW, _tagMetal.tagName];

    int y = 0;
    int x = 0;
    
    for (int z = 0; z < antibodies.count + 1; z++){
        
        if (z == antibodies.count) {
            
            [self addFlexiCloneToX:x andY:y];
            return;
        }
        
        LabeledAntibody *antibody = [antibodies objectAtIndex:z];
        
        UIColor *color = [UIColor grayColor];
        if(antibody.tubFinishedBy.intValue != 0)
            color = [color colorByChangingAlphaTo:0.2];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([self.delegate isConjugateInPanel:antibody]) {
            button.backgroundColor = color;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            button.backgroundColor = [UIColor clearColor];
            [button setTitleColor:color forState:UIControlStateNormal];
        }
        
        button.titleLabel.numberOfLines = 3;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        
        
        [General addBorderToButton:button withColor:color];
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;

        [button setTitle:[[General showFullAntibodyName:antibody.lot.clone withSpecies:NO]stringByAppendingFormat:@" %@",antibody.lot.clone.cloIsPhospho.intValue > 0?antibody.lot.clone.cloBindingRegion:@""] forState:UIControlStateNormal];

        button.tag = [antibodies indexOfObject:antibody];
        
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            button.frame = CGRectMake( x*160, y*65, self.bounds.size.width - 180, 60);
        }else{
            button.frame = CGRectMake( x*160, y*65, 150, 60);
        }
        
        
        if ([self.delegate isRelated:antibody]) {
            button.layer.borderWidth = 10.0f;
            button.layer.borderColor = [UIColor purpleColor].CGColor;
        }
        
        float distance = 15;
        if (antibody.lot.clone.isHuman) {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(button.bounds.size.width - distance, 1, 14, 14)];
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
        if (antibody.lot.clone.isMouse) {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(button.bounds.size.width -distance, 1, 14, 14)];
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
        //Antibody conjugate number
        UILabel *number = [[UILabel alloc]initWithFrame:CGRectMake(3, 1, 50, 14)];
        number.text = antibody.labBBTubeNumber;
        number.textColor = color;
        number.font = [UIFont systemFontOfSize:11.5f];
        [button addSubview:number];
        
        
    
        UILabel *sMC = [[UILabel alloc]initWithFrame:CGRectMake(1, 45, 14, 14)];
        sMC.backgroundColor = [UIColor lightGrayColor];//[ADBApplicationType colorForFlow:[General jsonStringToObject:antibody.lot.clone.cloApplication]];
        sMC.text = @"F";
        sMC.textAlignment = NSTextAlignmentCenter;
        sMC.layer.cornerRadius = 7;
        sMC.textColor = [UIColor whiteColor];
        sMC.clipsToBounds = YES;
        sMC.font = [UIFont systemFontOfSize:10.0f];
        sMC.alpha = CGColorGetAlpha(color.CGColor);
        UIColor *acolor = [General colorForClone:antibody.lot.clone forApplication:0];
        if([General antibodyWorksForFlow:antibody.lot.clone]){
            [button addSubview:sMC];
            if(acolor)sMC.backgroundColor = acolor;
        }else{
            if(acolor){
                [button addSubview:sMC];
                sMC.backgroundColor = acolor;
            }
        }
        
        UILabel *iMC = [[UILabel alloc]initWithFrame:CGRectMake(16, 45, 14, 14)];
        iMC.backgroundColor = [UIColor lightGrayColor];//[ADBApplicationType colorForImaging:[General jsonStringToObject:antibody.lot.clone.cloApplication]];
        iMC.text = @"I";
        iMC.textAlignment = NSTextAlignmentCenter;
        iMC.layer.cornerRadius = 7;
        iMC.textColor = [UIColor whiteColor];
        iMC.clipsToBounds = YES;
        iMC.font = [UIFont systemFontOfSize:10.0f];
        iMC.alpha = CGColorGetAlpha(color.CGColor);
        UIColor *bcolor = [General colorForClone:antibody.lot.clone forApplication:1];
        if([General antibodyWorksForFlow:antibody.lot.clone]){
            [button addSubview:iMC];
            if(bcolor)iMC.backgroundColor = bcolor;
        }else{
            if(bcolor){
                [button addSubview:iMC];
                iMC.backgroundColor = bcolor;
            }
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
        
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            x = 0;
            y++;
            button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        }
        else{
            if (x > (int)floorf(self.buttonsView.bounds.size.width / 160.0f)-1) {
                x = 0;
                y++;
            }
        }
        
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

-(void)flexiButtonTapped:(UIButton *)sender{
    ADBFlexiCloneViewController *flexi = [[ADBFlexiCloneViewController alloc]init];
    flexi.delegate = self;
    ADBMasterViewController *controller = (ADBMasterViewController *)[self delegate];
    [controller showModalWithCancelButton:flexi fromVC:controller withPresentationStyle:UIModalPresentationPageSheet];
}
-(void)didSelectFlexiClone:(Clone *)clone from:(ADBMasterViewController *)controller{
    NSMutableDictionary *dict = [[General jsonStringToObject:[[self.delegate whichPanel]catchedInfo]]mutableCopy];
    if(!dict)dict = @{}.mutableCopy;
    if(![dict valueForKey:@"sketch"]){
        [dict setObject:@{}.mutableCopy forKey:@"sketch"];
    }else{
        [dict setObject:[[dict valueForKey:@"sketch"]mutableCopy] forKey:@"sketch"];
    }
    [dict setValue:[General showFullAntibodyName:clone withSpecies:NO] forKeyPath:[NSString stringWithFormat:@"sketch.%@", _tagMetal.tagTagId]];
    [[[self delegate]whichPanel]setCatchedInfo:[General jsonObjectToString:dict]];
    [[IPExporter getInstance]updateInfoForObject:[self.delegate whichPanel] withBlock:nil];
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self setTagMetal:_tagMetal];
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