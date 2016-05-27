//
//  ADBAddConjugateViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 3/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddConjugateViewController.h"

@interface ADBAddConjugateViewController ()

@property (nonatomic, strong) Lot *lot;
@property (nonatomic, strong) Tag *tag;

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
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Add conjugate";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    // Do any additional setup after loading the view from its nib.
}

-(void)done{
    //TODO populate the lot
    self.conjugate = (LabeledAntibody *)[General newObjectOfType:LABELEDANTIBODY_DB_CLASS saveContext:NO];
    
    self.conjugate.labDateOfLabeling = self.datePicker.date.description;
    
    NSString *missing = @"";
    
    if(!self.lot){
        missing = [missing stringByAppendingString:@"Clone/Lot\n"];
    }else{
        [General doLinkForProperty:@"lot" inObject:_conjugate withReceiverKey:@"labLotId" fromDonor:_lot withPK:@"lotLotId"];
    }
    if(!self.tag){
        missing = [missing stringByAppendingString:@"Tag\n"];
    }else{
        [General doLinkForProperty:@"tag" inObject:_conjugate withReceiverKey:@"labTagId" fromDonor:_tag withPK:@"tagTagId"];
    }
    
    if(missing.length > 0){
        [General showOKAlertWithTitle:@"Information missing:" andMessage:nil];
        return;
    }
    
    self.conjugate.labConcentration = [NSString stringWithFormat:@"%.2f", self.concentration.value];
    
    NSMutableURLRequest *request = [General callToAPI:@"lastAntibodyForGroup" withPost:[NSString stringWithFormat:@"data={\"groupId\":\"%@\"}", [[ADBAccountManager sharedInstance]currentGroupPerson].group.grpGroupId]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (!error) {
            NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            if (result.intValue != 0) {
                self.conjugate.labBBTubeNumber = result;
                [General saveContextAndRoll];
                if (self.conjugate.labLabeledAntibodyId) {
                    [[IPExporter getInstance]updateInfoForObject:_conjugate withBlock:nil];
                }
            }
        }
    }];
    
    
    
    [General saveContextAndRoll];
    [self.delegate addConjugate:self];
}

-(void)concentrationChanged:(UISlider *)sender{
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

@end
