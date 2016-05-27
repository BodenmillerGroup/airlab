//
//  ADBAddConjugateViewController.m
// AirLab
//
//  Created by Raul Catena on 3/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddConjugateViewController.h"

@interface ADBAddConjugateViewController ()

@property (nonatomic, strong) Lot *lot;
@property (nonatomic, strong) Tag *tag;
@property (nonatomic, strong) ZGroupPerson *labeler;

@end

@implementation ADBAddConjugateViewController

@synthesize conjugate = _conjugate;
@synthesize delegate = _delegate;
@synthesize cloneLotSelector = _cloneLotSelector;
@synthesize tagSelector = _tagSelector;
@synthesize datePicker = _datePicker;
@synthesize concLabel = _concLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.labeler = [ADBAccountManager sharedInstance].currentGroupPerson;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Add conjugate";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [self.personSelector setTitle:[[ADBAccountManager sharedInstance].currentGroupPerson person].perName forState:UIControlStateNormal];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(_lot)[self didSelectLot:_lot];
}

-(void)done{
    //TODO populate the lot
    
    NSString *missing = @"";
    
    if(!self.lot){
        missing = [missing stringByAppendingString:@"Clone/Lot\n"];
    }
    if(!self.tag){
        missing = [missing stringByAppendingString:@"Tag\n"];
    }
    if(missing.length > 0){
        [General showOKAlertWithTitle:@"Information missing:" andMessage:nil delegate:self];
        return;
    }
    
    self.conjugate = (LabeledAntibody *)[General newObjectOfType:LABELEDANTIBODY_DB_CLASS saveContext:NO];
    self.conjugate.labDateOfLabeling = self.datePicker.date.description;
    self.conjugate.labConcentration = [NSString stringWithFormat:@"%.2f", self.concentration.value];
    self.conjugate.labContributorId = self.labeler.person.perPersonId;
    [General doLinkForProperty:@"tag" inObject:_conjugate withReceiverKey:@"labTagId" fromDonor:_tag withPK:@"tagTagId"];
    [General doLinkForProperty:@"lot" inObject:_conjugate withReceiverKey:@"labLotId" fromDonor:_lot withPK:@"reiReagentInstanceId"];
    
    [General saveContextAndRoll];
    [self.delegate addConjugate:self];
}

-(void)concentrationChanged:(UISlider *)sender{
    int sobra = (int)sender.value%10;
    float value;
    if (sobra == 0) {
        value = (int)sender.value;
    }else{
        value = floorf(sender.value-sobra);
    }
    sender.value = value;
    self.concLabel.text = [NSString stringWithFormat:@"%.2f ug/mL", sender.value];
}

-(void)selectTag:(UIButton *)sender{
    ADBTagsViewController *tags = [[ADBTagsViewController alloc]init];
    tags.delegate = self;
    tags.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:tags];
    
    [self showModalOrPopoverWithViewController:navCon withFrame:sender.frame];
}

-(void)selectCloneAndLot:(UIButton *)sender{
    ADBCloneSelectorViewController *tags = [[ADBCloneSelectorViewController alloc]init];
    tags.delegate = self;
    //tags.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:tags];
    [self showModalOrPopoverWithViewController:navCon withFrame:sender.frame];
}

-(void)selectPerson:(UIButton *)sender{
    ADBPeopleSelectorViewController *selectP = [[ADBPeopleSelectorViewController alloc]init];
    selectP.delegate = self;
    selectP.unique = YES;
    [self showModalWithCancelButton:selectP fromVC:self withPresentationStyle:UIModalPresentationCurrentContext];
}

-(void)cancel{
    [self dismissModalOrPopover];
}

#pragma TagDelegate

-(void)didSelectTag:(Tag *)aTag{
    self.tag = aTag;
    NSString *string;
    if (aTag.tagIsMetal.boolValue) {
        string = [NSString stringWithFormat:@"%@%@", aTag.tagMW, aTag.tagName];
    }else{
        string = aTag.tagName;
    }
    [self.tagSelector setTitle:string forState:UIControlStateNormal];
    [self dismissModalOrPopover];
}

#pragma Clone and lot delegate

-(void)didSelectClone:(Clone *)clone{
    //self.conjugate.lot = clone.l
}

-(void)didSelectLot:(Lot *)lot{
    self.lot = lot;
    [self.cloneLotSelector setTitle:[NSString stringWithFormat:@"%@ %@", lot.clone.cloName, lot.lotNumber] forState:UIControlStateNormal];
    [self dismissModalOrPopover];
}

-(void)didSelectPeople:(NSArray *)people{
    self.labeler = people.lastObject;
    [self.personSelector setTitle:[(ZGroupPerson *)people.lastObject person].perName forState:UIControlStateNormal];
    [self dismissModalOrPopover];
}

@end
