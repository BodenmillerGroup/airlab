//
//  ADBAllInfoForAbViewController.m
// AirLab
//
//  Created by Raul Catena on 7/7/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAllInfoForAbViewController.h"
#import "ADBInfoCommertialViewController.h"
#import "ADBJournalViewController.h"
#import "ADBApplicationType.h"

@interface ADBAllInfoForAbViewController ()

@property (nonatomic, strong) LabeledAntibody *conjugate;
@property (nonatomic, strong) Lot *lot;
@property (nonatomic, strong) NSString *currentValidation;
@property (nonatomic, strong) NSMutableArray *validationNotes;
@property (nonatomic, strong) NSDictionary *editable;

@end

@implementation ADBAllInfoForAbViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andConjugate:(LabeledAntibody *)conjugate
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.conjugate = conjugate;
        self.lot = _conjugate.lot;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andLot:(Lot *)lot
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.lot = lot;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTheTableviewWithStyle:UITableViewStyleGrouped];
    
    UIBarButtonItem *validationButton = [[UIBarButtonItem alloc]initWithTitle:@"+ note" style:UIBarButtonItemStyleDone target:self action:@selector(addValidation:)];
    UIBarButtonItem *applicationsButton = [[UIBarButtonItem alloc]initWithTitle:@"setApplications" style:UIBarButtonItemStyleDone target:self action:@selector(addApplications:)];
    self.navigationItem.rightBarButtonItems = @[validationButton, applicationsButton];
    
    self.validationNotes = [[General jsonStringToObject:_lot.clone.catchedInfo]mutableCopy];//[NSMutableArray arrayWithArray:[General arrayOfValidationNotesForLot:_lot andConjugate:_conjugate]];
    
    [[IPFetchObjects getInstance]addLotEnsayosForServerWithBlock:^{[self.tableView reloadData];}];
}

-(void)addValidation:(UIBarButtonItem *)sender{
    
    ADBValidationBoxViewController *validator = [[ADBValidationBoxViewController alloc]init];
    validator.delegate = self;
    UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:validator];
    self.popover = [[UIPopoverController alloc]initWithContentViewController:navCon];
    [self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [validator.cellLine becomeFirstResponder];
}

-(void)addApplications:(UIBarButtonItem *)sender{
    ADBDefineApplicationsViewController *define = [[ADBDefineApplicationsViewController alloc]initWithNibName:nil bundle:nil andClone:self.lot.clone];
    UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:define];
    define.delegate = self;
    [self showModalOrPopoverWithViewController:navCon withFrame:CGRectMake(self.view.bounds.size.width, 0, 2, 2)];
}

-(void)doneDefiningApplicationsForClone:(Clone *)clone{
    [[IPExporter getInstance]updateInfoForObject:self.lot.clone withBlock:nil];
    [self dismissModalOrPopover];
}

-(void)saveSubroutine{
//    NSError *error;
//    if (_conjugate) {
//        _conjugate.labCellsUsedForValidation = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:_validationNotes options:NSJSONWritingPrettyPrinted error:&error] encoding:NSUTF8StringEncoding];
//        [[IPExporter getInstance]updateInfoForObject:_conjugate withBlock:nil];
//        
//    }else{
//        _lot.lotCellsValidation = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:_validationNotes options:NSJSONWritingPrettyPrinted error:&error] encoding:NSUTF8StringEncoding];
//        [[IPExporter getInstance]updateInfoForObject:_lot withBlock:nil];
//    }
//    if (error)[General logError:error];
//    [self refreshTable];
//    [self dismissModalOrPopover];
    
    _lot.clone.catchedInfo = [General jsonObjectToString:_validationNotes];
    [[IPExporter getInstance]updateInfoForObject:_lot.clone withBlock:nil];

    [self refreshTable];
    [self dismissModalOrPopover];
}

-(void)didAddValidationNote:(NSDictionary *)jsonDic{
    [self.validationNotes addObject:jsonDic];
    [self saveSubroutine];
}

-(void)didModifyValidationNote:(NSDictionary *)jsonDic{
    [_validationNotes removeObject:_editable];
    [_validationNotes addObject:jsonDic];
    [self saveSubroutine];
}

-(void)addValidationExp:(UIBarButtonItem *)sender{
    
    ADBJournalViewController *journal = [[ADBJournalViewController alloc]initWithNibName:nil bundle:nil andLot:_lot andConj:_conjugate];
    [self showModalWithCancelButton:journal fromVC:self withPresentationStyle:UIModalPresentationFullScreen];
}

-(void)textViewDidChange:(UITextView *)textView{
    _currentValidation = textView.text;
}

-(void)saveValidation{
    if (_conjugate) {
        if (_conjugate.labCellsUsedForValidation.length != 0) {
            _conjugate.labCellsUsedForValidation = [_conjugate.labCellsUsedForValidation stringByAppendingString:@"|"];
        }
        _conjugate.labCellsUsedForValidation = [_conjugate.labCellsUsedForValidation stringByAppendingString:_currentValidation];
        [[IPExporter getInstance]updateInfoForObject:_conjugate withBlock:nil];
        [self.popover dismissPopoverAnimated:YES];
        [self.tableView reloadData];
    }else{
        if (_lot.lotCellsValidation.length != 0) {
            _lot.lotCellsValidation = [_lot.lotCellsValidation stringByAppendingString:@"|"];
        }
        _lot.lotCellsValidation = [_lot.lotCellsValidation stringByAppendingString:_currentValidation];
        [[IPExporter getInstance]updateInfoForObject:_lot withBlock:nil];
        [self.popover dismissPopoverAnimated:YES];
        [self.tableView reloadData];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return (_conjugate)?6:5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int rows = 0;
    
    switch (section) {
        case 0:{
            if (_conjugate) {
                rows = 6;
            }else{
                rows = 0;
            }
        }
            
            break;
        case 1:
            rows = 6;
            break;
        case 2:
            rows = 8;
            break;
        case 3:
            rows = 2;
            break;
            
        case 4:
            rows = _validationNotes.count;
            break;
        case 5:{
            if(_lot.lotEnsayos.count > 0)rows += _lot.validationExperiments.allObjects.count;
            for (ZLotEnsayo *linker in _lot.lotEnsayos) {
                if(linker.ensayo)rows++;
            }
        }
            
            break;
        default:
            break;
    }
    
    return rows;
}

-(void)setProteinCells:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Protein Name";
            cell.detailTextLabel.text = self.lot.clone.protein.proName;
            break;
        case 1:
            cell.textLabel.text = @"Description";
            cell.detailTextLabel.text = self.lot.clone.protein.proDescription;
            break;
            
        default:
            break;
    }
}

-(void)setCloneCells:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Clone name";
            cell.detailTextLabel.text = self.lot.clone.cloName;
            break;
        case 1:
            cell.textLabel.text = @"Host";
            cell.detailTextLabel.text = self.lot.clone.speciesHost.spcName;
            break;
        case 2:{
            cell.textLabel.text = @"Specifities";
            NSString *specificities = @"";
            for (NSString *species in [self.lot.clone.cloReactivity componentsSeparatedByString:@","]) {
                NSArray *results = [General searchDataBaseForClass:SPECIES_DB_CLASS withTerm:species inField:@"spcSpeciesId" sortBy:@"spcSpeciesId" ascending:YES inMOC:self.managedObjectContext];
                if (results.count > 0) {
                    Species *spec = results.lastObject;
                    specificities = [specificities stringByAppendingString:[NSString stringWithFormat:@"%@ (%@), ", spec.spcName, spec.spcAcronym]];
                }
                
                
            }
            cell.detailTextLabel.text = specificities;
        }
            break;
        case 3:
            cell.textLabel.text = @"Polyclonal";
            cell.detailTextLabel.text = self.lot.clone.cloIsPolyclonal;
            break;
        case 4:
            cell.textLabel.text = @"Phosphoprotein";
            cell.detailTextLabel.text = self.lot.clone.cloIsPhospho;
            break;
        case 5:
            cell.textLabel.text = @"Isotype";
            cell.detailTextLabel.text = self.lot.clone.cloIsotype;
            break;
        case 6:
            cell.textLabel.text = @"Epitope";
            cell.detailTextLabel.text = self.lot.clone.cloBindingRegion;
            break;
        case 7:
            cell.textLabel.text = @"More info...";
            break;
        default:
            break;
    }
}


-(void)setLotCells:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Amount";
            cell.detailTextLabel.text = self.lot.lotConcentration;
            break;
        case 1:
            cell.textLabel.text = @"Link to Technical data sheet";
            cell.detailTextLabel.text = self.lot.lotDataSheetLink;
            break;
        case 2:
            cell.textLabel.text = @"Lot Number";
            cell.detailTextLabel.text = self.lot.lotNumber;
            break;
        case 3:
            cell.textLabel.text = @"Expiration date";
            cell.detailTextLabel.text = [General getDateFromDescription:self.lot.lotExpirationDate];
            break;
        case 4:
            cell.textLabel.text = @"Provider";
            cell.detailTextLabel.text = self.lot.provider.proName;
            break;
        case 5:
            cell.textLabel.text = @"Order Number";
            cell.detailTextLabel.text = self.lot.comertialReagent.comReference;
            break;
        default:
            break;
    }
}

-(void)setConjugateCells:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Labeled by";
            cell.detailTextLabel.text = [[(ZGroupPerson *)[[General searchDataBaseForClass:ZGROUPPERSON_DB_CLASS withTerm:_conjugate.labContributorId inField:@"gpePersonId" sortBy:@"gpePersonId" ascending:YES inMOC:self.managedObjectContext]lastObject]person]perName];
            break;
        case 1:
            cell.textLabel.text = @"Date of labeling";
            cell.detailTextLabel.text = _conjugate.labDateOfLabeling;
            break;
        case 2:
            cell.textLabel.text = @"Tag";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", _conjugate.tag.tagName, _conjugate.tag.tagMW];
            break;
        case 3:
            cell.textLabel.text = @"Concentration";
            cell.detailTextLabel.text = _conjugate.labConcentration;
            break;
        case 4:
            cell.textLabel.text = @"Staining concentration";
            cell.detailTextLabel.text = _conjugate.labCytofStainingConc;
            break;
        case 5:
            cell.textLabel.text = @"Tube number";
            cell.detailTextLabel.text = _conjugate.labBBTubeNumber;
            break;
        default:
            break;
    }
}

-(void)setNoteCells:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = [_validationNotes objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ | %@", [ADBApplicationType applicationForInt:[[dict valueForKey:@"app"]intValue]], [dict valueForKey:@"sample"]];
    cell.detailTextLabel.text = [dict valueForKey:@"note"];
    if ([[dict valueForKey:@"isVal"]boolValue])cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.backgroundColor = [General colorForValidationNotesDictionary:dict];
}

-(void)setExperimentCells:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    Ensayo *ensayo = (Ensayo *)[[self getAllExperiments]objectAtIndex:indexPath.row];
    if ([ensayo isMemberOfClass:[Ensayo class]]) {
        cell.textLabel.text = ensayo.enyTitle;
    }else{
        cell.textLabel.text = [(ZLotEnsayo *)ensayo ensayo].enyTitle;
    }
    
    cell.detailTextLabel.text = nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellId = @"CloneCell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor whiteColor];
    
    switch (indexPath.section) {
        case 0:
            [self setConjugateCells:cell atIndexPath:indexPath];
            break;
        case 1:
            [self setLotCells:cell atIndexPath:indexPath];

            break;
        case 2:
            [self setCloneCells:cell atIndexPath:indexPath];
            break;
            
        case 3:
            [self setProteinCells:cell atIndexPath:indexPath];
            break;
            
        case 4:
            [self setNoteCells:cell atIndexPath:indexPath];
            break;
        case 5:
            [self setExperimentCells:cell atIndexPath:indexPath];
            break;
        default:
            break;
    }
    cell.detailTextLabel.tag = indexPath.row + 10* indexPath.section;
    [self setGrayColorInTableText:cell];
    
    return cell;
    
}


-(id)objectEditingWithIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            return _conjugate;
            break;
        case 1:
            return _lot;
            break;
        case 2:
            return _lot.clone;
            break;
        case 3:
            return _lot.clone.protein;
            break;
        default:
            break;
    }
    return nil;
}

-(NSArray *)getAllExperiments{
    NSMutableArray *ensayos = [NSMutableArray arrayWithArray:_lot.validationExperiments.allObjects];
    if(_lot.lotEnsayos.count > 0)
    [ensayos addObjectsFromArray:_lot.validationExperiments.allObjects];
    for (ZLotEnsayo *linker in _lot.lotEnsayos) {
        if(linker.ensayo)[ensayos addObject:linker.ensayo];
    }
    return [NSArray arrayWithArray:ensayos];
}

-(void)actionShowLinkToTDS:(UITableViewCell *)cell{
    UIViewController *cont = [[UIViewController alloc]init];
    UIWebView *wb = [[UIWebView alloc]initWithFrame:self.view.window.frame];
    wb.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [cont.view addSubview:wb];
    [wb loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:cell.detailTextLabel.text]]];
    [self showModalWithCancelButton:cont fromVC:self withPresentationStyle:UIModalPresentationFullScreen];
}

-(void)pickDetails{
    if (self.lot.comertialReagent) {
        ADBInfoCommertialViewController *more = [[ADBInfoCommertialViewController alloc]initWithNibName:nil bundle:nil andReagent:_conjugate.lot.comertialReagent];
        [self showModalWithCancelButton:more fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    switch (indexPath.section) {
 
        case 1:{
            if (indexPath.row == 1) {
                [self actionShowLinkToTDS:cell];return;
            }
        }
            break;
            
        case 2:{
            if(indexPath.row == 7){
                [self pickDetails];return;
                
            }

        }
            break;
            
        case 3:
            [self validationBoxWithIndexPath:indexPath];return;
            break;
            
        case 4:
            [self validationBoxWithIndexPath:indexPath];return;
            break;
            
        case 5:
            [self journalWithIndexPath:indexPath];return;
            break;
            
        default:
            
            break;
    }
    
    [General showOKAlertWithTitle:cell.textLabel.text andMessage:cell.detailTextLabel.text delegate:self];
}

-(void)journalWithIndexPath:(NSIndexPath *)indexPath{
    Ensayo *ensayo = (Ensayo *)[[self getAllExperiments] objectAtIndex:indexPath.row];
    ADBJournalViewController *journal = [[ADBJournalViewController alloc]initWithNibName:nil bundle:nil andEnsayo:ensayo];
    [self showModalWithCancelButton:journal fromVC:self withPresentationStyle:UIModalPresentationFullScreen];
}

-(void)validationBoxWithIndexPath:(NSIndexPath *)indexPath{
    ADBValidationBoxViewController *validation = [[ADBValidationBoxViewController alloc]initWithNibName:nil bundle:nil andJson:[_validationNotes objectAtIndex:indexPath.row]];
    validation.delegate = self;
    _editable = [_validationNotes objectAtIndex:indexPath.row];
    UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:validation];
    [self showModalOrPopoverWithViewController:navCon withFrame:[self.tableView cellForRowAtIndexPath:indexPath].contentView.frame];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section < 4) {
        return YES;
    }
    if (_validationNotes.count <= indexPath.row) {
        return NO;
    }
    NSDictionary *note = [_validationNotes objectAtIndex:indexPath.row];
    //int grp = [[ADBAccountManager sharedInstance]currentGroupPerson].gpeGroupPersonId.intValue;
    int per = [[ADBAccountManager sharedInstance]currentGroupPerson].person.perPersonId.intValue;
    if((indexPath.section == 4 && [[note valueForKey:@"grp"]intValue] == per ) || (indexPath.section == 4 && [[note valueForKey:@"personId"]intValue] == per )){
        return YES;
    }
    return NO;
}

-(NSDictionary *)dictForAll{

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@{
                     @"0":@[@"0",@"Labeled by"],
                     @"1":@[@"0",@"Date of labeling"],
                     @"2":@[@"0",@"Tag"],
                     @"3":@[@"1",@"Concentration", @"labConcentration"],
                     @"4":@[@"1",@"Staining Concentration", @"labCytofStainingConc"],
                     @"5":@[@"0",@"Tube number", @"labBBTubeNumber"],
                     } forKey:@"0"];
    
    [dict setValue:@{
                     @"0":@[@"1",@"Amount", @"lotConcentration"],
                     @"1":@[@"1",@"Link to Technical data sheet", @"lotDataSheetLink"],
                     @"2":@[@"1",@"Lot Number", @"lotNumber"],
                     @"3":@[@"0",@"Expiration date"],
                     @"4":@[@"0",@"Provider"],
                     @"5":@[@"0",@"Order number"],
                     } forKey:@"1"];
    
    [dict setValue:@{
                     @"0":@[@"1",@"Amount", @"lotConcentration"],
                     @"1":@[@"1",@"Link to Technical data sheet", @"lotDataSheetLink"],
                     @"2":@[@"1",@"Lot Number", @"lotNumber"],
                     @"3":@[@"0",@"Expiration date"],
                     @"4":@[@"0",@"Provider"],
                     @"5":@[@"0",@"Order number"],
                     } forKey:@"1"];
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

-(UITableViewRowAction *)addDeleteFunctionWithIp:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [_validationNotes removeObjectAtIndex:indexPath.row];
        [self saveSubroutine];
    }];
    return deleteAction;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
    if(indexPath.section == 3){
        if (!_conjugate) {
            UITableViewRowAction *deleteAction = [self addDeleteFunctionWithIp:indexPath];
            [array addObject:deleteAction];
        }
    }else if(indexPath.section == 4){
        if (_conjugate) {
            UITableViewRowAction *deleteAction = [self addDeleteFunctionWithIp:indexPath];
            [array addObject:deleteAction];
        }
    }
    if (indexPath.section < 1) {
        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            id object = [self objectEditingWithIndexPath:indexPath];
            if (object) {
                NSString *title = [NSString stringWithFormat:@"Edit %@", [self tableView:self.tableView titleForHeaderInSection:indexPath.section]];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alert addTextFieldWithConfigurationHandler:^(UITextField *textField){
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    textField.text = cell.detailTextLabel.text;
                }];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                     //[object setValue:[(UITextField *)alert.textFields.lastObject text] forKey:@"GET KEY"];
                }];
                [alert addAction:cancel];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
        [array addObject:action];
    }
    return [NSArray arrayWithArray:array];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.view.bounds.size.width, 30)];
    lab.text = [self tableView:self.tableView titleForHeaderInSection:section];
    lab.textColor = [UIColor orangeColor];
    [view addSubview:lab];
    if (section == 1) {
        UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
        but.frame = CGRectMake(self.view.bounds.size.width - 70, 5, 60, 20);
        [but addTarget:self action:@selector(editLot) forControlEvents:UIControlEventTouchUpInside];
        [but setTitle:@"Edit..." forState:UIControlStateNormal];
        [view addSubview:but];
    }
    if (section == 2) {
        UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
        but.frame = CGRectMake(self.view.bounds.size.width - 70, 5, 60, 20);
        [but addTarget:self action:@selector(editClone) forControlEvents:UIControlEventTouchUpInside];
        [but setTitle:@"Edit..." forState:UIControlStateNormal];
        [view addSubview:but];
    }
    return view;
}

-(void)editLot{
    ADBAddKitViewController *edit = [[ADBAddKitViewController alloc]initWithNibName:nil bundle:nil andClone:self.lot.clone andDict:nil andLot:self.lot];
    edit.delegate = self;
    [self showModalWithCancelButton:edit fromVC:self withPresentationStyle:UIModalPresentationFormSheet];
}

-(void)didAddLot:(Lot *)lot{
    [self dismissModalOrPopover];
    [self refreshTable];
}

-(void)editClone{
    ADBAddAntibodyViewController *edit = [[ADBAddAntibodyViewController alloc]initWithNibName:nil bundle:nil andEditableClone:self.lot.clone andDict:nil];
    edit.delegate = self;
    [self showModalWithCancelButton:edit fromVC:self withPresentationStyle:UIModalPresentationFormSheet];
}

-(void)addAntibody:(ADBAddAntibodyViewController *)controller withNewProtein:(BOOL)newProt{
    [self dismissModalOrPopover];
    [self refreshTable];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title;
    switch (section) {
        case 0:
            title = @"Conjugate information";
            break;
        case 1:
            title = @"Lot information";
            break;
        case 2:
            title = @"Clone information";
            break;
            
        case 3:
            title = @"Protein";
            break;
            
        case 4:
            title = @"Validation Notes";
            break;
        case 5:
            title = @"Experiments";
            break;
        default:
            break;
    }
    return title;
}

@end
