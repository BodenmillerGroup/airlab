//
//  ADBMetalsViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/7/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMetalsViewController.h"
#import "ADBMetalPanelViewController.h"
#import "ADBAllInfoForAbViewController.h"

@interface ADBMetalsViewController ()

@property (nonatomic, strong) Panel *panel;
@property (nonatomic, strong) NSArray *everything;
@property (nonatomic, strong) NSMutableArray *related;
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, strong) NSString *searchTerm;

@end

@implementation ADBMetalsViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize selectedConjugates = _selectedConjugates;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPanel:(Panel *)panel
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _panel = panel;
        NSMutableArray *conjugates = [NSMutableArray arrayWithCapacity:panel.panelLabeledAntibodies.count];
        for (ZPanelLabeledAntibody *linker in _panel.panelLabeledAntibodies) {
            [conjugates addObject:linker.labeledAntibody];
        }
        _selectedConjugates = conjugates;
    }
    return self;
}

-(void)setArrayOfAll{
    NSMutableArray *majorArray = [NSMutableArray array];
    for (Tag *tag in _fetchedResultsController.fetchedObjects) {
        NSArray *array = [self getAntibodiesForTag:tag];
        [majorArray addObject:array];
    }
    _everything = majorArray;
}

-(void)addHelpers{
    UISegmentedControl *cont = [[UISegmentedControl alloc]initWithItems:@[@"Mouse", @"Human", @"All"]];
    [cont setSelectedSegmentIndex:2];
    cont.frame = CGRectMake(0, 0, 200, 20);
    cont.tintColor = [UIColor orangeColor];
    [cont addTarget:self action:@selector(filter:) forControlEvents:UIControlEventValueChanged];
    
    UITextField *field = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 100, 20)];
    field.delegate = self;
    [field addTarget:self action:@selector(searchAnAb:) forControlEvents:UIControlEventEditingChanged];
    field.backgroundColor = [UIColor whiteColor];
    field.clearButtonMode = UITextFieldViewModeAlways;
    
    UIBarButtonItem *sep = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    sep.width = 50.0f;
    
    self.navigationItem.rightBarButtonItems = @[self.navigationItem.rightBarButtonItem, sep, [[UIBarButtonItem alloc]initWithCustomView:cont], sep, [[UIBarButtonItem alloc]initWithCustomView:field]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Select antibodies";
    [self setTheTableviewWithStyle:UITableViewStylePlain];
    if (!self.navigationItem.rightBarButtonItems) {
        self.navigationItem.rightBarButtonItem.title = @"Done";
        
    }
    self.noAutorefresh = YES;
    [self addHelpers];
    [self setArrayOfAll];
}

-(void)filter:(UISegmentedControl *)sender{
   
    if(sender.selectedSegmentIndex == 2){
        //[sender setSelectedSegmentIndex:UISegmentedControlNoSegment];
        [self filterPanelOptions:@[
                                   [NSNumber numberWithBool:NO],
                                   [NSNumber numberWithBool:NO],
                                   [NSNumber numberWithBool:YES]
                                   ]];
        return;
    }
    [self filterPanelOptions:@[
                               [NSNumber numberWithBool:!(BOOL)sender.selectedSegmentIndex],
                               [NSNumber numberWithBool:(BOOL)sender.selectedSegmentIndex],
                               [NSNumber numberWithBool:NO],
                               ]];
}



-(void)filterPanelOptions:(NSArray *)options{
    _options = options;
    [self setArrayOfAll];
    [self.tableView reloadData];
}

-(void)searchAnAb:(UITextField *)field{
    _searchTerm = field.text;
    [self setArrayOfAll];
    [self.tableView reloadData];
}

-(void)next{
    if (!_selectedConjugates || _selectedConjugates.count == 0) {
        [General showOKAlertWithTitle:@"No antibodies selected" andMessage:@"Please select antibodies to continue"];
        return;
    }
    
    Panel *thePanel;
    if (!_panel) {
        thePanel = (Panel *)[General newObjectOfType:PANEL_DB_CLASS saveContext:NO];
    }else{
        thePanel = _panel;
    }
    
    NSMutableArray *arrayOfLinkers = thePanel.panelLabeledAntibodies.allObjects.mutableCopy;
    for(LabeledAntibody *lab in _selectedConjugates){
        
        bool found;
        ZPanelLabeledAntibody *linker;
        
        for (ZPanelLabeledAntibody *linfirst in arrayOfLinkers) {
            if ([_selectedConjugates containsObject:linfirst.labeledAntibody]) {
                linker = linfirst;
                found = YES;
                break;
            }
        }
        
        if (linker) {
            [arrayOfLinkers removeObject:linker];
            continue;
        }
        
        if (!linker) {
            linker = (ZPanelLabeledAntibody *)[General newObjectOfType:CLASS_ZPANELLABELEDANTIBODY saveContext:NO];
        }
        
        [General doLinkForProperty:@"labeledAntibody" inObject:linker withReceiverKey:@"plaLabeledAntibodyId" fromDonor:lab withPK:@"labLabeledAntibodyId"];
        [General doLinkForProperty:@"panel" inObject:linker withReceiverKey:@"plaPanelId" fromDonor:thePanel withPK:@"panPanelId"];
        
        if (linker.plaActualConc) {
            linker.plaActualConc = lab.labCytofStainingConc;
        }else{
            for (ZPanelLabeledAntibody *otherLink in lab.panelLabeledAntibodies) {
                if (otherLink == linker) {
                    continue;
                }
                if (otherLink.plaActualConc) {
                    //TODO find median value
                    linker.plaActualConc = otherLink.plaActualConc;
                    break;
                }
            }
        }
    }
    
    NSMutableArray *toRemove = [NSMutableArray array];
    
    for (ZPanelLabeledAntibody *linLast in thePanel.panelLabeledAntibodies) {
        if (![_selectedConjugates containsObject:linLast.labeledAntibody]) {
            [toRemove addObject:linLast];
        }
    }
    
    for (ZPanelLabeledAntibody *remove in toRemove) {
        remove.labeledAntibody = nil;
        remove.panel = nil;
        remove.plaPanelId = @"22222";
        if (remove.plaPanelLabeledAntibodyId) {
            [[IPExporter getInstance]updateInfoForObject:remove withBlock:nil];
        }else{
            [self.managedObjectContext deleteObject:remove];
        }
        //RCF here I will have to erase in DB
    }
    
    if (_panel) {
        [General saveContextAndRoll];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        ADBMetalPanelViewController *panelVC = [[ADBMetalPanelViewController alloc]initWithNibName:nil bundle:nil andPanel:thePanel];
        panelVC.delegate = self.delegate;
        
        [self.navigationController pushViewController:panelVC animated:YES];
    }
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:TAG_DB_CLASS];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tagMW" ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"tagIsMetal == 1"];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];//TODO add section name keypath with protein or epitope
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fetchedResultsController.fetchedObjects.count;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"PanelCell";
    
    ADBMetalCellTableViewCell *cell = (ADBMetalCellTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ADBMetalCellTableViewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    for (UIView *aSubview in cell.contentView.subviews) {
        if ([aSubview isMemberOfClass:[UIButton class]]) {
            [aSubview removeFromSuperview];
        }
    }
    
    Tag *tag = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.delegate = self;
    cell.antibodies = [_everything objectAtIndex:indexPath.row];
    cell.tagMetal = tag;
    [self setGrayColorInTableText:cell];

    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", tag.tagMW, tag.tagName];
    return cell;
}

-(void)didSelectConjugate:(LabeledAntibody *)conjugate{
    if (!_selectedConjugates) {
        self.selectedConjugates = [NSMutableArray array];
    }
    if ([_selectedConjugates containsObject:conjugate]) {
        [_selectedConjugates removeObject:conjugate];
    }else{
        [_selectedConjugates addObject:conjugate];
    }
    [self.tableView reloadData];
}

-(void)showInfoFor:(LabeledAntibody *)conjugate{
    ADBAllInfoForAbViewController *info = [[ADBAllInfoForAbViewController alloc]initWithNibName:nil bundle:nil andConjugate:conjugate];
    [self showModalWithCancelButton:info fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
}

-(void)showRelatedFor:(LabeledAntibody *)conjugate{
    if (_related.count > 0 && [_related containsObject:conjugate]) {
        [_related removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    _related = [NSMutableArray array];
    for (Tag *tag in _fetchedResultsController.fetchedObjects) {
        NSArray *arrayAbs = [self getAntibodiesForTag:tag];
        for (LabeledAntibody *lab in arrayAbs) {
            if (lab == conjugate) {
                //continue;
            }
            if (conjugate.lot.clone.cloCloneId.intValue == lab.lot.clone.cloCloneId.intValue) {
                [_related addObject:lab];
            }
            if (conjugate.lot.clone.protein.proProteinId.intValue == lab.lot.clone.protein.proProteinId.intValue) {
                [_related addObject:lab];
            }
        }
    }
    NSString *string = @"";
    for (LabeledAntibody *lab in _related) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"%@ %@ - %@%@\n",
                                                lab.lot.clone.protein.proName,
                                                lab.lot.clone.cloName,
                                                lab.tag.tagMW,
                                                lab.tag.tagName]];
    }
    if (string.length > 0)
    [General showOKAlertWithTitle:@"Related conjugates" andMessage:string];
    [self.tableView reloadData];
}

-(BOOL)isRelated:(LabeledAntibody *)lab{
    if ([_related containsObject:lab]) {
        return YES;
    }
    return NO;
}

-(BOOL)isConjugateInPanel:(LabeledAntibody *)conjugate{
    if ([_selectedConjugates containsObject:conjugate]) {
        return YES;
    }else{
        return NO;
    }
}

-(void)cleanCellForConjugates:(NSArray *)conjugates{
    if (!_selectedConjugates) {
        return;
    }
    for (LabeledAntibody *labeled in conjugates) {
        if ([_selectedConjugates containsObject:labeled]) {
            [_selectedConjugates removeObject:labeled];
        }
    }
}

-(NSArray *)getAntibodiesForTag:(Tag *)tag{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:LABELEDANTIBODY_DB_CLASS];
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"labLabeledAntibodyId" ascending:YES]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"tag == %@", tag];
    if(_searchTerm.length > 0){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lot.clone.cloName contains [cd] %@", _searchTerm];
        NSPredicate *predicateB = [NSPredicate predicateWithFormat:@"lot.clone.protein.proName contains [cd] %@", _searchTerm];
        NSPredicate *or = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate, predicateB]];
        request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[or, request.predicate]];
    }
    NSError *error;
    NSArray *antibodies = [self.managedObjectContext executeFetchRequest:request error:&error];
    
     NSMutableArray *finalList = [NSMutableArray array];
    
    if (_options && _options.count == 3) {
        for (LabeledAntibody *lab in antibodies) {
            
            if([[_options objectAtIndex:2]boolValue]){[finalList addObject:lab];continue;}
            
            for (ZCloneSpeciesProtein *linker in lab.lot.clone.cloneSpeciesProteins) {
                
                if([linker.speciesProtein.species.spcName isEqualToString:@"Mouse"] && [[_options objectAtIndex:0]boolValue]){
                    [finalList addObject:lab];
                    break;
                }
                if([linker.speciesProtein.species.spcName isEqualToString:@"Human"] && [[_options objectAtIndex:1]boolValue]){
                    [finalList addObject:lab];
                    break;
                }
            }
        }
        
    }else{
        finalList = [NSMutableArray arrayWithArray:antibodies];
    }
    
    if (error)[General logError:error];
    return [NSArray arrayWithArray:finalList];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Tag *tag = (Tag *)[_fetchedResultsController objectAtIndexPath:indexPath];
    NSArray *antibodies = [self getAntibodiesForTag:tag];
    int integ = (int)antibodies.count;
    int rows = ceilf((float)integ/4.0f);
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        rows = ceilf((float)integ/1.0f);
    }
    return MAX(55.0f,10.0f + 45.0f*rows);
}


@end
