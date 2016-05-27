//
//  ADBAddAntibodyViewController.m
//  AntibodyDB
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

@property (nonatomic, strong) Clone *editable;

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


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andProtein:(Protein *)protein
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.protein = protein;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andEditableClone:(Clone *)clone
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.editable = clone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.speciesReactive = [NSMutableArray array];
    
    if (_editable)self.title = @"Edit antibody clone";
    else self.title = @"Add antibody clone";
    
    if (_protein) {
        self.clone.protein = _protein;
        [self.targetButton setTitle:_protein.proName forState:UIControlStateNormal];
        [self.targetButton setEnabled:NO];
        self.nueTargetField.hidden = YES;
        self.nueTargetLabel.hidden = YES;
    }
    
    if(_editable){
        
        self.protein = _editable.protein;
        
        [self.targetButton setTitle:_editable.protein.proName forState:UIControlStateNormal];
        [self.targetButton setUserInteractionEnabled:NO];
        self.nueTargetField.hidden = YES;
        
        self.cloneName.text = _editable.cloName;
        self.isotype.text = _editable.cloIsotype;
        self.host = _editable.speciesHost;
        [self didSelectSpecies:_host];
        NSMutableArray *species = [NSMutableArray array];
        for (ZCloneSpeciesProtein *spc in _editable.cloneSpeciesProteins) {NSLog(@"1");
            [species addObject:spc.speciesProtein.species];
        }
        self.speciesReactive = species;
        [self didSelectSpeciesArray:_speciesReactive];
        self.speciesReactivityButton.userInteractionEnabled = NO;
        
        self.epitope.text = _editable.cloBindingRegion;
        
        self.polyclonalSwitch.on = _editable.cloIsPolyclonal.boolValue;
        self.phosphoSwitch.on = _editable.cloIsPhospho.boolValue;
        
        self.cloneName.text = _editable.cloName;
        
        self.antibodyName.text = [NSString stringWithFormat:@"anti-%@", _editable.protein.proName];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
}



-(void)done{
    
    
    
    if (!_host) {
        [General showOKAlertWithTitle:@"You must specify a host species"andMessage:nil];
        return;
    }
    
    
    
    if (self.cloneName.text.length == 0) {
        [General showOKAlertWithTitle:@"You must specify a clone name"andMessage:nil];
        return;
    }else{
        NSArray *check = [General searchDataBaseForClass:CLASS_CLONE withTerm:self.cloneName.text inField:@"cloName" sortBy:@"cloName" ascending:YES inMOC:self.managedObjectContext];
        if(check.count > 0){
            if (!_editable || ![self.cloneName.text isEqualToString:_editable.cloName]) {
                [General showOKAlertWithTitle:@"There is already a clone with the same name" andMessage:@"Please try another"];
                return;
            }
            
        }
    }
    
    if (!self.protein) {
        if (!self.nueTargetField.text) {
            [General showOKAlertWithTitle:@"You must specify a target antigen/protein" andMessage:nil];
            return;
        }
    }
    
    BOOL newProt = self.clone.protein? NO:YES;
    
    //Move this to end
    if (!_editable) {
        self.clone = (Clone *)[General newObjectOfType:CLASS_CLONE saveContext:NO];
    }else{
        self.clone = _editable;
    }
    
    
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
    
    if (self.speciesReactive.count > 0 && !_editable) {
        for (Species *species in self.speciesReactive) {
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:SPECIESPROTEIN_DB_CLASS];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sppSpeciesProteinId" ascending:YES]];
            request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                                     [NSPredicate predicateWithFormat:@"species == %@", species],
                                                                                     [NSPredicate predicateWithFormat:@"protein == %@", self.clone.protein],
                                                                                     ]];
            NSError *error;
            NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];if(error)[General logError:error];
            SpeciesProtein *speciesProt = nil;
            if (results.count > 0) {
                speciesProt = results.lastObject;
            }else{
                speciesProt = (SpeciesProtein *)[General newObjectOfType:SPECIESPROTEIN_DB_CLASS saveContext:NO];
            }
            
            
            [General doLinkForProperty:@"protein" inObject:speciesProt withReceiverKey:@"sppProteinId" fromDonor:self.clone.protein withPK:@"proProteinId"];
            [General doLinkForProperty:@"species" inObject:speciesProt withReceiverKey:@"sppSpeciesId" fromDonor:species withPK:@"spcSpeciesId"];
            
            ZCloneSpeciesProtein *cloneSPP = (ZCloneSpeciesProtein *)[General newObjectOfType:ZCLONESPECIESPROTEIN_DB_CLASS saveContext:YES];
            
            [General doLinkForProperty:@"clone" inObject:cloneSPP withReceiverKey:@"cspCloneId" fromDonor:self.clone withPK:@"cloCloneId"];
            [General doLinkForProperty:@"speciesProtein" inObject:cloneSPP withReceiverKey:@"cspSpeciesProteinId" fromDonor:speciesProt withPK:@"sppSpeciesProteinId"];
        }
    }
    
    self.clone.cloName = self.cloneName.text;
    NSString *string = [self.cloneName.text stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    string = [string capitalizedString];
    self.clone.openBisCode = string;
    
    _clone.cloIsotype = _isotype.text;
    _clone.cloBindingRegion = _epitope.text;
    _clone.cloIsPhospho = _phosphoSwitch.on? @"true":@"false";
    _clone.cloIsPolyclonal = _polyclonalSwitch.on? @"true":@"false";
    
    if (_editable) {
        [[IPExporter getInstance]updateInfoForObject:_clone withBlock:nil];
    }
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
    NSLog(@"passing %lul", (unsigned long)self.speciesReactive.count);
    species.delegate = self;
    UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:species];
    
    [self showModalOrPopoverWithViewController:navCon withFrame:sender.frame];
}

-(IBAction)targetSelector:(UIButton *)sender{
    ADBTargetViewController *targets = [[ADBTargetViewController alloc]init];
    targets.delegate = self;
    //targets.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:targets];
    
    [self showModalOrPopoverWithViewController:navCon withFrame:sender.frame];
}

#pragma mark Species Delegate

-(void)didSelectSpecies:(Species *)species{
    self.host = species;
    [self.speciesHostButton setTitle:[NSString stringWithFormat:@"%@ %@", species.spcName, species.spcAcronym] forState:UIControlStateNormal];
    [self dismissModalOrPopover];//TODO think to remove this, the effect is cool without closing for iPad
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
    [self dismissModalOrPopover];
    self.nueTargetField.hidden = YES;
    self.nueTargetLabel.hidden = YES;
    self.antibodyName.text = [NSString stringWithFormat:@"anti-%@", target.proName];
}


#pragma mark TextField delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField == self.nueTargetField){
        self.antibodyName.text = [NSString stringWithFormat:@"anti-%@", [self.nueTargetField.text stringByAppendingString:string]];
    }
    return YES;
}

@end
