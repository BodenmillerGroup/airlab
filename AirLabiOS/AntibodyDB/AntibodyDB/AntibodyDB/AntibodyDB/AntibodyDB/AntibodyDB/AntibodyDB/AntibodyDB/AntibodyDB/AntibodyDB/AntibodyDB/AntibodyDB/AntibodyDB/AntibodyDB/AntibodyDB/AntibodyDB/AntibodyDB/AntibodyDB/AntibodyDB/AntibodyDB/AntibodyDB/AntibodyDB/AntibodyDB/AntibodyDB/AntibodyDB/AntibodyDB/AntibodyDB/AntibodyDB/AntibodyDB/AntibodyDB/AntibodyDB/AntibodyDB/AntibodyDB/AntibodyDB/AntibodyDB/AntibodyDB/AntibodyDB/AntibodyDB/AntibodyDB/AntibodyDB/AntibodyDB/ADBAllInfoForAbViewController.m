//
//  ADBAllInfoForAbViewController.m
//  AntibodyDB
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
    
    UIBarButtonItem *validationButton = [[UIBarButtonItem alloc]initWithTitle:@"+ note" style:UIBarButtonItemStyleBordered target:self action:@selector(addValidation:)];
    UIBarButtonItem *validationExpButton = [[UIBarButtonItem alloc]initWithTitle:@"+ journal" style:UIBarButtonItemStyleBordered target:self action:@selector(addValidationExp:)];
    if (_lot.validationExperiments.count > 0) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(files:)];
        self.navigationItem.rightBarButtonItems = @[validationButton, validationExpButton, button];
    }else self.navigationItem.rightBarButtonItems = @[validationButton, validationExpButton];
    
    self.validationNotes = [NSMutableArray arrayWithArray:[General arrayOfValidationNotesForLot:_lot andConjugate:_conjugate]];
    
    [[IPFetchObjects getInstance]addLotEnsayosForServerWithBlock:^{[self.tableView reloadData];}];
}

-(void)files:(UIBarButtonItem *)sender{
    ADBJournalViewController *journal = [[ADBJournalViewController alloc]initWithNibName:nil bundle:nil andEnsayo:_lot.validationExperiments.anyObject];
    [self showModalWithCancelButton:journal fromVC:self withPresentationStyle:UIModalPresentationFullScreen];
}

-(void)addValidation:(UIBarButtonItem *)sender{
    
    ADBValidationBoxViewController *validator = [[ADBValidationBoxViewController alloc]init];
    validator.delegate = self;
    UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:validator];
    self.popover = [[UIPopoverController alloc]initWithContentViewController:navCon];
    [self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [validator.cellLine becomeFirstResponder];
}

-(void)saveSubroutine{
    NSError *error;
    if (_conjugate) {
        _conjugate.labCellsUsedForValidation = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:_validationNotes options:NSJSONWritingPrettyPrinted error:&error] encoding:NSUTF8StringEncoding];
        [[IPExporter getInstance]updateInfoForObject:_conjugate withBlock:nil];
        
    }else{
        _lot.lotCellsValidation = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:_validationNotes options:NSJSONWritingPrettyPrinted error:&error] encoding:NSUTF8StringEncoding];
        [[IPExporter getInstance]updateInfoForObject:_lot withBlock:nil];
    }
    if (error)[General logError:error];
    [self dismissModalOrPopover];
    [self.tableView reloadData];
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
        case 0:
            rows = 2;
            break;
        case 1:
            rows = 8;
            break;
        case 2:
            rows = 5;
            break;
        case 3:{
            if (_conjugate) {
                rows = 6;
            }else{
                rows = _validationNotes.count;
            }
        }
            
            break;
        case 4:{
            if (_conjugate) {
                rows = _validationNotes.count;
            }else{
                rows = _lot.validationExperiments.count + _lot.lotEnsayos.count;
            }
        }
            
            break;
        case 5:{
            rows = _lot.validationExperiments.count + _lot.lotEnsayos.count;
        }
            
            break;
        default:
            break;
    }
    return rows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"CloneCell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    switch (indexPath.section) {
        case 0:
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
            break;
        case 1:
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
                    for (ZCloneSpeciesProtein *linker in self.lot.clone.cloneSpeciesProteins) {
                        specificities = [specificities stringByAppendingString:[NSString stringWithFormat:@"%@ (%@), ", linker.speciesProtein.species.spcName, linker.speciesProtein.species.spcAcronym]];
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
                    //RCF
                    break;
                default:
                    break;
            }
            break;
        case 2:
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
                default:
                    break;
            }
            break;
        case 3:{
            if (_conjugate) {
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.text = @"Labeled by";
                        cell.detailTextLabel.text = _conjugate.labContributorId;
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
            }else{
                NSDictionary *dict = [_validationNotes objectAtIndex:indexPath.row];
                cell.textLabel.text = [NSString stringWithFormat:@"%@ | %@", [ADBApplicationType applicationForInt:[[dict valueForKey:@"app"]intValue]], [dict valueForKey:@"sample"]];
                cell.detailTextLabel.text = [dict valueForKey:@"note"];
                if ([[dict valueForKey:@"isVal"]boolValue])cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
            
            break;
        case 4:{
            if (_conjugate) {
                NSDictionary *dict = [_validationNotes objectAtIndex:indexPath.row];
                cell.textLabel.text = [NSString stringWithFormat:@"%@ | %@", [ADBApplicationType applicationForInt:[[dict valueForKey:@"app"]intValue]], [dict valueForKey:@"sample"]];
                cell.detailTextLabel.text = [dict valueForKey:@"note"];
                if ([[dict valueForKey:@"isVal"]boolValue])cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else{
                Ensayo *ensayo = (Ensayo *)[[self getAllExperiments]objectAtIndex:indexPath.row];
                cell.textLabel.text = ensayo.enyTitle;
                cell.detailTextLabel.text = nil;
            }
        }
            
            break;
        case 5:{
            Ensayo *ensayo = (Ensayo *)[[self getAllExperiments]objectAtIndex:indexPath.row];
            cell.textLabel.text = ensayo.enyTitle;
            cell.detailTextLabel.text = nil;
        }
            
            break;
        default:
            break;
    }
    
    switch (indexPath.section) {
        case 3:{
            if (!_conjugate) {
                NSDictionary *dict = [_validationNotes objectAtIndex:indexPath.row];
                cell.backgroundColor = [General colorForValidationNotesDictionary:dict];
            }
        }
            break;
        case 4:{
            if (_conjugate) {
                NSDictionary *dict = [_validationNotes objectAtIndex:indexPath.row];
                cell.backgroundColor = [General colorForValidationNotesDictionary:dict];
            }
        }
            break;
        default:
            cell.backgroundColor = [UIColor whiteColor];
            break;
    }
    
    [self setGrayColorInTableText:cell];
    
    return cell;
}

-(NSArray *)getAllExperiments{
    NSMutableArray *ensayos = [NSMutableArray arrayWithArray:_lot.validationExperiments.allObjects];
    for (ZLotEnsayo *linker in _lot.lotEnsayos) {
        [ensayos addObject:linker.ensayo];
    }
    return [NSArray arrayWithArray:ensayos];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Careful RCF difficult to maintain this class
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 2 && indexPath.row == 1) {
        UIViewController *cont = [[UIViewController alloc]init];
        UIWebView *wb = [[UIWebView alloc]initWithFrame:self.view.window.frame];
        wb.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        [cont.view addSubview:wb];
        [wb loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:cell.detailTextLabel.text]]];
        [self showModalWithCancelButton:cont fromVC:self withPresentationStyle:UIModalPresentationFullScreen];
    }else if(indexPath.section == 1 && indexPath.row == 7){
        if (self.lot.reagentInstance.comertialReagent) {
            ADBInfoCommertialViewController *more = [[ADBInfoCommertialViewController alloc]initWithNibName:nil bundle:nil andReagent:_conjugate.lot.reagentInstance.comertialReagent];
            [self showModalWithCancelButton:more fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
        }
        
    }else if(indexPath.section == 3){
        /////[General showOKAlertWithTitle:cell.textLabel.text andMessage:cell.detailTextLabel.text];
        if (_conjugate) {
            ADBValidationBoxViewController *validation = [[ADBValidationBoxViewController alloc]initWithNibName:nil bundle:nil andJson:[_validationNotes objectAtIndex:indexPath.row]];
            validation.delegate = self;
            _editable = [_validationNotes objectAtIndex:indexPath.row];
            UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:validation];
            [self showModalOrPopoverWithViewController:navCon withFrame:[tableView cellForRowAtIndexPath:indexPath].contentView.frame];
        }
    }else if(indexPath.section == 4){
        if (_conjugate) {
            ADBValidationBoxViewController *validation = [[ADBValidationBoxViewController alloc]initWithNibName:nil bundle:nil andJson:[_validationNotes objectAtIndex:indexPath.row]];
            validation.delegate = self;
            _editable = [_validationNotes objectAtIndex:indexPath.row];
            UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:validation];
            [self showModalOrPopoverWithViewController:navCon withFrame:[tableView cellForRowAtIndexPath:indexPath].contentView.frame];
        }else{
            Ensayo *ensayo = (Ensayo *)[[self getAllExperiments] objectAtIndex:indexPath.row];
            ADBJournalViewController *journal = [[ADBJournalViewController alloc]initWithNibName:nil bundle:nil andEnsayo:ensayo];
            [self showModalWithCancelButton:journal fromVC:self withPresentationStyle:UIModalPresentationFullScreen];
        }
    }else if(indexPath.section == 5){
        Ensayo *ensayo = (Ensayo *)[[self getAllExperiments] objectAtIndex:indexPath.row];
        ADBJournalViewController *journal = [[ADBJournalViewController alloc]initWithNibName:nil bundle:nil andEnsayo:ensayo];
        [self showModalWithCancelButton:journal fromVC:self withPresentationStyle:UIModalPresentationFullScreen];
    }else{
        [General showOKAlertWithTitle:cell.textLabel.text andMessage:cell.detailTextLabel.text];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 3){
        if (_conjugate) {
            return YES;
        }
    }else if(indexPath.section == 4){
        if (_conjugate) {
            return YES;
        }
    }
    return NO;
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
        if (_conjugate) {
            UITableViewRowAction *deleteAction = [self addDeleteFunctionWithIp:indexPath];
            [array addObject:deleteAction];
        }
    }else if(indexPath.section == 4){
        if (_conjugate) {
            UITableViewRowAction *deleteAction = [self addDeleteFunctionWithIp:indexPath];
            [array addObject:deleteAction];
        }
    }
    
    return [NSArray arrayWithArray:array];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title;
    switch (section) {
        case 0:
            title = @"Protein";
            break;
        case 1:
            title = @"Clone information";
            break;
        case 2:
            title = @"Lot information";
            break;
        case 3:{
            if (_conjugate) {
                title = @"Conjugate information";
            }else{
                title = @"Validation Notes";
            }
        }
            
            break;
        case 4:{
            if (_conjugate) {
                title = @"Validation Notes";
            }else{
                title = @"Validation Experiments";
            }
            break;
        }
        case 5:
            title = @"Validation Experiments";
            break;
            
        default:
            title = @"";
            break;
    }
    return title;
}

@end
