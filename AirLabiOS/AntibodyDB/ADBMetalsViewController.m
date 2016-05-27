//
//  ADBMetalsViewController.m
// AirLab
//
//  Created by Raul Catena on 5/7/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMetalsViewController.h"
#import "ADBAllInfoForAbViewController.h"

@interface ADBMetalsViewController ()

@property (nonatomic, strong) NSArray *everything;
@property (nonatomic, strong) NSMutableArray *related;
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, strong) NSString *searchTerm;
@property (nonatomic, strong) NSMutableArray *theCells;
@property (nonatomic, strong) UISegmentedControl *speciesSelect;
@property (nonatomic, strong) UISegmentedControl *hideOverSelect;

@end

@implementation ADBMetalsViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize selectedConjugates = _selectedConjugates;
@synthesize panel = _panel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPanel:(Panel *)panel
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _panel = panel;

        NSMutableArray *conjugates = [NSMutableArray array];
        for (NSDictionary *dict in [General jsonStringToObject:_panel.panDetails]) {

            NSArray *array = [General searchDataBaseForClass:LABELEDANTIBODY_DB_CLASS withTerm:[dict valueForKey:@"plaLabeledAntibodyId" ] inField:@"labLabeledAntibodyId" sortBy:@"labLabeledAntibodyId" ascending:YES inMOC:self.managedObjectContext];

            if (array.count > 0) {
                [conjugates addObject:array.lastObject];
            }
                              
        }
        _selectedConjugates = conjugates;
    }
    return self;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self generateCellForTag:(Tag *)[_fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row] atIndex:(int)indexPath.row];
}

-(ADBMetalCellTableViewCell *)cellForTag:(Tag *)tag{
    
    ADBMetalCellTableViewCell *cell;
    for (ADBMetalCellTableViewCell *acell in _theCells) {
        if (acell.tagMetal == tag) {
            cell = acell;
        }
    }
    if (!cell) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ADBMetalCellTableViewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.delegate = self;
    }
    cell.antibodies = [_everything objectAtIndex:[_fetchedResultsController.fetchedObjects indexOfObject:tag]];
    cell.tagMetal = tag;
    [self setGrayColorInTableText:cell];
    
    return cell;
}

-(ADBMetalCellTableViewCell *)generateCellForTag:(Tag *)tag atIndex:(int)index{
    if (!_theCells)_theCells = [NSMutableArray arrayWithCapacity:_fetchedResultsController.fetchedObjects.count];
    ADBMetalCellTableViewCell *cell = [self cellForTag:tag];
    if(![_theCells containsObject:cell]){
        if (index<_theCells.count) {
            [_theCells insertObject:cell atIndex:index];
        }else{
            [_theCells addObject:cell];
        }
    }
    return cell;
}

-(void)addHelpers{
    self.speciesSelect = [[UISegmentedControl alloc]initWithItems:@[@"Mouse", @"Human", @"All"]];
    [self.speciesSelect setSelectedSegmentIndex:2];
    self.speciesSelect.frame = CGRectMake(0, 0, 200, 20);
    self.speciesSelect.tintColor = [UIColor orangeColor];
    [self.speciesSelect addTarget:self action:@selector(filter:) forControlEvents:UIControlEventValueChanged];
    
    self.hideOverSelect = [[UISegmentedControl alloc]initWithItems:@[@"Hide empty", @"All"]];
    [self.hideOverSelect setSelectedSegmentIndex:1];
    self.hideOverSelect.frame = CGRectMake(0, 0, 150, 20);
    self.hideOverSelect.tintColor = [UIColor orangeColor];
    [self.hideOverSelect addTarget:self action:@selector(filter:) forControlEvents:UIControlEventValueChanged];
    
    UITextField *field = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 100, 20)];
    field.delegate = self;
    [field addTarget:self action:@selector(searchAnAb:) forControlEvents:UIControlEventEditingChanged];
    field.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0f];
    field.clearButtonMode = UITextFieldViewModeAlways;
    
    UIBarButtonItem *sep = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    sep.width = 50.0f;
    
    self.navigationItem.rightBarButtonItems = @[self.navigationItem.rightBarButtonItem, sep, [[UIBarButtonItem alloc]initWithCustomView:self.speciesSelect], sep, [[UIBarButtonItem alloc]initWithCustomView:self.hideOverSelect], sep, [[UIBarButtonItem alloc]initWithCustomView:field]];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTheTableviewWithStyle:UITableViewStylePlain];
    self.tableView.tintColor = [UIColor orangeColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(next)];

    self.noAutorefresh = YES;
    [self addHelpers];
    
    _options = @[
                [NSNumber numberWithBool:NO],
                [NSNumber numberWithBool:NO],
                [NSNumber numberWithBool:YES],
                [NSNumber numberWithBool:YES]
                ];
    
    [self refreshAll];
}

-(void)refreshAll{
    self.filtered = [self getAntibodiesToProcess].mutableCopy;
    [self setArrayOfAll];
    [self.tableView reloadData];
}

-(NSArray *)getAntibodiesToProcess{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:LABELEDANTIBODY_DB_CLASS];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"labLabeledAntibodyId" ascending:YES]];
    
    if(_searchTerm.length > 0){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lot.clone.cloName contains [cd] %@", _searchTerm];
        NSPredicate *predicateB = [NSPredicate predicateWithFormat:@"lot.clone.protein.proName contains [cd] %@", _searchTerm];
        NSPredicate *or = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate, predicateB]];
        request.predicate = or;
    }
    NSError *error;
    NSArray *toReturn = [self.managedObjectContext executeFetchRequest:request error:&error];
    if(error)[General logError:error];
    return toReturn;
}

-(void)setArrayOfAll{
    NSMutableArray *majorArray = [NSMutableArray array];
    for (Tag *tag in _fetchedResultsController.fetchedObjects) {
        NSArray *array = [self getAntibodiesForTag:tag];
        [majorArray addObject:array];
    }
    _everything = majorArray;
}

-(NSArray *)getAntibodiesForTag:(Tag *)tag{
    
    NSMutableArray *finalList = [NSMutableArray array];
    
    if (_options && _options.count == 4) {
        for (LabeledAntibody *lab in self.filtered) {
            if (lab.tag != tag) {
                continue;
            }
            if([[_options objectAtIndex:2]boolValue]){
                [finalList addObject:lab];continue;
            }
            
            for (NSString *idSpecies in [lab.lot.clone.cloReactivity componentsSeparatedByString:@","]) {
                if ((idSpecies.intValue == 2  && [[_options objectAtIndex:0]boolValue]) || (idSpecies.intValue == 4  && [[_options objectAtIndex:1]boolValue])) {
                    [finalList addObject:lab];
                    break;
                }
            }
            if ([[_options objectAtIndex:3]boolValue] == NO) {
                if (lab.tubFinishedBy.intValue > 0) {
                    [finalList removeObject:lab];
                }
            }
        }
        
    }else{
        finalList = [NSMutableArray arrayWithArray:self.filtered];
    }
    return [NSArray arrayWithArray:finalList];
}

-(void)filter:(UISegmentedControl *)sender{

    [self filterPanelOptions:@[
                               [NSNumber numberWithBool:!(BOOL)self.speciesSelect.selectedSegmentIndex],
                               [NSNumber numberWithBool:(BOOL)self.speciesSelect.selectedSegmentIndex],
                               [NSNumber numberWithBool:NO],
                               [NSNumber numberWithBool:(BOOL)self.hideOverSelect.selectedSegmentIndex]
                               ]];
}


-(void)filterPanelOptions:(NSArray *)options{
    _options = options;
    [self refreshAll];
}

-(void)searchAnAb:(UITextField *)field{
    _searchTerm = field.text;
    [self refreshAll];
}

-(void)next{
    if (!_selectedConjugates || _selectedConjugates.count == 0) {
        [General showOKAlertWithTitle:@"No antibodies selected" andMessage:@"Please select antibodies to continue" delegate:self];
        return;
    }
    
    NSArray *previous;
    if (_panel && _panel.panDetails) {
        previous = [General jsonStringToObject:_panel.panDetails];
    }
    
    if (!_panel) {
        _panel = (Panel *)[General newObjectOfType:PANEL_DB_CLASS saveContext:NO];
    }
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSMutableArray *cleanupArray = [NSMutableArray array];
    for (LabeledAntibody *lab in _selectedConjugates) {
        if (![cleanupArray containsObject:lab]) {
            [cleanupArray addObject:lab];
        }
    }
    _selectedConjugates = cleanupArray;
    
    for (LabeledAntibody *lab in _selectedConjugates) {
        NSString *conc = @"2";
        if (previous) {
            for (NSDictionary *dic in previous) {
                if ([[dic valueForKey:@"plaLabeledAntibodyId"]intValue] == lab.labLabeledAntibodyId.intValue) {
                    conc = [dic valueForKey:@"plaActualConc"];
                }
            }
        }
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:
                                                                @[lab.labLabeledAntibodyId, conc]
                                                               forKeys:
                                                                @[@"plaLabeledAntibodyId", @"plaActualConc"]
                                    
                                    ];
        [array addObject:dictionary];
    }
    _panel.panDetails = [General jsonObjectToString:array];
    
    if(previous)[[IPExporter getInstance]updateInfoForObject:_panel withBlock:nil];
    else [[IPExporter getInstance]uploadNewObject:_panel withBlock:nil];
    
    [self done];
}

-(void)done{
    if (!_panel.panName) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Name this panel" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
        [alertController addAction:cancel];
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *handler){
            _panel.panName = [(UITextField *)[alertController.textFields objectAtIndex:0]text];
            [[IPExporter getInstance]updateInfoForObject:_panel withBlock:nil];
            ADBMetalPanelViewController *metalP = [[ADBMetalPanelViewController alloc]initWithNibName:nil bundle:nil andPanel:_panel];
            ADBMasterViewController *presenter = (ADBMasterViewController *)self.delegate;
            [presenter dismissViewControllerAnimated:YES completion:^{
                [presenter showModalWithCancelButton:metalP fromVC:presenter withPresentationStyle:UIModalPresentationPageSheet];
            }];
        }];
        yes.enabled = NO;
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = @"Name this panel";
             [textField addTarget:self action:@selector(enableOKButtonForTextField) forControlEvents:UIControlEventEditingChanged];
         }];
        [alertController addAction:yes];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }else{
        [self.navigationController popViewControllerAnimated:YES];
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


-(void)didSelectConjugate:(LabeledAntibody *)conjugate{
    if (!_selectedConjugates) {
        self.selectedConjugates = [NSMutableArray array];
    }
    if ([_selectedConjugates containsObject:conjugate]) {
        [_selectedConjugates removeObject:conjugate];
    }else{
        [_selectedConjugates addObject:conjugate];
    }
    NSInteger index = [_fetchedResultsController.fetchedObjects indexOfObject:conjugate.tag];
    ADBMetalCellTableViewCell *cell = (ADBMetalCellTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell setTagMetal:conjugate.tag];
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
        [General showOKAlertWithTitle:@"Related conjugates" andMessage:string delegate:self];
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

-(Panel *)whichPanel{
    return _panel;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Tag *tag = (Tag *)[_fetchedResultsController objectAtIndexPath:indexPath];
    NSArray *antibodies = [self getAntibodiesForTag:tag];
    int integ = (int)antibodies.count + 1;
    int rows = ceilf((float)integ/4.0f);
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        rows = ceilf((float)integ/1.0f);
    }
    return MAX(75.0f,10.0f + 65.0f*rows);
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:_fetchedResultsController.fetchedObjects.count];
    for (Tag *tag in _fetchedResultsController.fetchedObjects) {
        if (![array containsObject:tag.tagMW]) {
            [array addObject:tag.tagMW];
        }
    }
    return [NSArray arrayWithArray:array];
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    for (Tag *tag in _fetchedResultsController.fetchedObjects) {
        if ([tag.tagMW isEqualToString:title]) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_fetchedResultsController.fetchedObjects indexOfObject:tag] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    return 1;
}


@end