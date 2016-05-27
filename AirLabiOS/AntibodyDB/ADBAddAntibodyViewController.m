//
//  ADBAddAntibodyViewController.m
// AirLab
//
//  Created by Raul Catena on 3/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddAntibodyViewController.h"
#import "ADBSpeciesSelectoinViewController.h"

@interface ADBAddAntibodyViewController ()

@property (nonatomic, strong) Protein *protein;
@property (nonatomic, strong) Species *host;
@property (nonatomic, strong) NSMutableArray *speciesReactive;
@property (nonatomic, strong) NSDictionary *prevInfo;
@property (nonatomic, strong) NSString *applicationsJson;

//@property (nonatomic, strong) Clone *editable;

@end

@implementation ADBAddAntibodyViewController

@synthesize clone = _clone;
@synthesize delegate = _delegate;
@synthesize antibodyName = _antibodyName;
@synthesize cloneName = _cloneName;
@synthesize targetButton = _targetButton;
@synthesize nueTargetLabel = _nueTargetLabel;
@synthesize nueTargetField = _nueTargetField;
@synthesize epitope = _epitope;
@synthesize speciesReactivityButton = _speciesReactivityButton;
@synthesize speciesHostButton = _speciesHostButton;
@synthesize polyclonalSwitch = _polyclonalSwitch;
@synthesize speciesReactive = _speciesReactive;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andProtein:(Protein *)protein andDict:(NSDictionary *)dict
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.protein = protein;
        self.prevInfo = dict;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andEditableClone:(Clone *)clone andDict:(NSDictionary *)dict
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.editable = clone;
        self.clone = clone;
        self.prevInfo = dict;
    }
    return self;
}

-(void)setFromPrevious{
    
    self.title = @"Edit antibody clone";
    
    if(_clone.protein){
        self.protein = _clone.protein;
        [self.targetButton setTitle:_clone.protein.proName forState:UIControlStateNormal];
        [self.targetButton setUserInteractionEnabled:NO];
        self.nueTargetField.hidden = YES;
    }
    
    self.cloneName.text = _clone.cloName;
    self.isotype.text = _clone.cloIsotype;
    
    if(_clone.speciesHost){
        self.host = _clone.speciesHost;
        [self didSelectSpecies:_host];
    }
    
    NSMutableArray *species = [NSMutableArray array];
    
    NSArray *indexes = [_clone.cloReactivity componentsSeparatedByString:@","];
    for (NSString *index in indexes) {
        NSArray *reuslt = [General searchDataBaseForClass:SPECIES_DB_CLASS withTerm:index inField:@"spcSpeciesId" sortBy:@"spcSpeciesId" ascending:YES inMOC:self.managedObjectContext];
        if (reuslt.count > 0) {
            [species addObject:reuslt.lastObject];
        }
    }
    
    if(species.count > 0){
        self.speciesReactive = species;
        [self didSelectSpeciesArray:_speciesReactive];
    }
    
    self.epitope.text = _clone.cloBindingRegion;
    
    self.polyclonalSwitch.on = _clone.cloIsPolyclonal.boolValue;
    self.phosphoSwitch.on = _clone.cloIsPhospho.boolValue;
    
    self.cloneName.text = _clone.cloName;
    
    self.antibodyName.text = [NSString stringWithFormat:@"anti-%@", _clone.protein.proName];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.speciesReactive = [NSMutableArray array];
    self.title = @"Add antibody clone";
    
    if (_protein) {
        self.clone.protein = _protein;
        [self.targetButton setTitle:_protein.proName forState:UIControlStateNormal];
        [self.targetButton setEnabled:NO];
        self.nueTargetField.hidden = YES;
        self.nueTargetLabel.hidden = YES;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(_clone)[self setFromPrevious];
}

-(void)done{

    if (!_host) {
        [General showOKAlertWithTitle:@"You must specify a host species" andMessage:nil delegate:self];
        return;
    }
    
    
    
    if (self.cloneName.text.length == 0) {
        [General showOKAlertWithTitle:@"You must specify a clone name" andMessage:nil delegate:self];
        return;
    }else{
        NSArray *check = [General searchDataBaseForClass:CLASS_CLONE withTerm:self.cloneName.text inField:@"cloName" sortBy:@"cloName" ascending:YES inMOC:self.managedObjectContext];
        if(check.count > 0){
            if (!_clone || ![self.cloneName.text isEqualToString:_clone.cloName]) {
                [General showOKAlertWithTitle:@"There is already a clone with the same name" andMessage:@"Please try another" delegate:self];
                return;
            }
            
        }
    }
    
    if (!self.protein) {
        if (!self.nueTargetField.text) {
            [General showOKAlertWithTitle:@"You must specify a target antigen/protein" andMessage:nil delegate:self];
            return;
        }
    }
    
    BOOL newProt = self.clone.protein? NO:YES;
    
    if (!_clone)self.clone = (Clone *)[General newObjectOfType:CLASS_CLONE saveContext:NO];
    
    [General doLinkForProperty:@"speciesHost" inObject:self.clone withReceiverKey:@"cloSpeciesHost" fromDonor:_host withPK:@"spcSpeciesId"];
    
    if (!self.protein) {
        Protein *protein;
        NSArray *proteins = [General searchDataBaseForClass:PROTEIN_DB_CLASS withTerm:self.nueTargetField.text inField:@"proName" sortBy:@"proName" ascending:YES inMOC:self.managedObjectContext];
        if (proteins.count > 0) {
            protein = proteins.lastObject;
        }else{
            protein = (Protein *)[General newObjectOfType:PROTEIN_DB_CLASS saveContext:NO];
        }
        
        protein.proName = self.nueTargetField.text;
        [General doLinkForProperty:@"protein" inObject:self.clone withReceiverKey:@"cloProteinId" fromDonor:protein withPK:@"proProteinId"];
    }else{
        [General doLinkForProperty:@"protein" inObject:self.clone withReceiverKey:@"cloProteinId" fromDonor:self.protein withPK:@"proProteinId"];
    }
    
    NSString *reactivity = @"";
    for (Species *species in self.speciesReactive) {
        reactivity = [reactivity stringByAppendingFormat:@"%@,", species.spcSpeciesId];
    }
    if (reactivity.length > 0) {
        reactivity = [reactivity stringByReplacingCharactersInRange:NSMakeRange(reactivity.length-1, 1) withString:@""];
    }
    self.clone.cloReactivity = reactivity;
    
    self.clone.cloName = self.cloneName.text;
    NSString *string = [self.cloneName.text stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    string = [string capitalizedString];
    self.clone.openBisCode = string;
    
    if (_applicationsJson)self.clone.cloApplication = _applicationsJson;
    
    _clone.cloIsotype = _isotype.text;
    _clone.cloBindingRegion = _epitope.text;
    _clone.cloIsPhospho = _phosphoSwitch.on? @"true":@"false";
    _clone.cloIsPolyclonal = _polyclonalSwitch.on? @"true":@"false";
    
    
    [[IPExporter getInstance]updateInfoForObject:_clone withBlock:nil];
    [self.delegate addAntibody:self withNewProtein:newProt];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    UITextField *textV = [alertView textFieldAtIndex:0];
    //TODO check clone name as above
    self.clone.cloName = textV.text;
    BOOL newProt = self.clone.protein? NO:YES;
    [self.delegate addAntibody:self withNewProtein:newProt];
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    UITextField *textV = [alertView textFieldAtIndex:0];
    return textV.text.length > 0? YES:NO;
}

-(IBAction)speciesSelector:(UIButton *)sender{
    BOOL multiSelector = [[NSNumber numberWithInt:sender.tag]boolValue];
    ADBSpeciesSelectoinViewController *species = [[ADBSpeciesSelectoinViewController alloc]initWithNibName:nil bundle:nil andMultiSelector:multiSelector];
    if(multiSelector)species.selection = self.speciesReactive;
    species.delegate = self;
    UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:species];
    
    [self showModalOrPopoverWithViewController:navCon withFrame:sender.frame];
}

-(IBAction)targetSelector:(UIButton *)sender{
    ADBTargetViewController *targets = [[ADBTargetViewController alloc]init];
    targets.delegate = self;
    UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:targets];
    [self showModalOrPopoverWithViewController:navCon withFrame:sender.frame];
}

-(void)defineApplications:(UIButton *)sender{
    ADBDefineApplicationsViewController *define = [[ADBDefineApplicationsViewController alloc]initWithNibName:nil bundle:nil andClone:_clone];
    define.delegate = self;
    [self showModalWithCancelButton:define fromVC:self withPresentationStyle:UIModalPresentationFormSheet];
}

#pragma mark Species Delegate

-(void)didSelectSpecies:(Species *)species{
    self.host = species;
    [self.speciesHostButton setTitle:[NSString stringWithFormat:@"%@ %@", species.spcName, species.spcAcronym] forState:UIControlStateNormal];
    [self dismissModalOrPopover];
}

-(void)didSelectSpeciesArray:(NSMutableArray *)speciesArray{
    self.speciesReactive = speciesArray;
    NSString *string = @"";
    for (Species *species in speciesArray) {
        string = [string stringByAppendingString:species.spcAcronym];
        string = [string stringByAppendingString:@" "];
    }
    [self.speciesReactivityButton setTitle:string forState:UIControlStateNormal];
    [self dismissModalOrPopover];
}

#pragma mark clone Delegate

-(void)didSelectTarget:(Protein *)target{
    self.protein = target;
    [self.targetButton setTitle:target.proName forState:UIControlStateNormal];
    self.nueTargetField.hidden = YES;
    self.nueTargetLabel.hidden = YES;
    self.antibodyName.text = [NSString stringWithFormat:@"anti-%@", target.proName];
    [self dismissModalOrPopover];
}

#pragma mark application definition delegate

-(void)doneDefiningApplicationsForClone:(Clone *)clone{
    [self doneDefiningApplicationsPreClone:clone.cloApplication];
}

-(void)doneDefiningApplicationsPreClone:(NSString *)appsJson{
    NSLog(@"The apps selected are %@", appsJson);
    self.applicationsJson = appsJson;
    
    NSMutableDictionary *notes = [General jsonStringToObject:appsJson];
    NSArray *titles = @[@"sMC", @"iMC", @"FC", @"IF", @"IHC"];
    NSString *apps = @"";
    for (int i = 0;i<5;i++) {
        if ([[notes valueForKey:[NSString stringWithFormat:@"%i", i]]boolValue] == YES) {
            apps = [apps stringByAppendingString:[titles objectAtIndex:i]];
            apps = [apps stringByAppendingString:@" | "];
        }
    }
    if(apps.length > 0){
        if(apps.length > 3)apps = [apps substringToIndex:apps.length - 2];
        [_appsButton setTitle:apps forState:UIControlStateNormal];
    }
    //[self dismissModalOrPopover];
}

#pragma mark TextField delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField == self.nueTargetField){
        self.antibodyName.text = [NSString stringWithFormat:@"anti-%@", [self.nueTargetField.text stringByAppendingString:string]];
    }
    return YES;
}

@end
