//
//  ADBMetalPanelViewController.m
// AirLab
//
//  Created by Raul Catena on 5/8/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMetalPanelViewController.h"
#import "ADBMetalsViewController.h"
#import "ADBAllInfoForAbViewController.h"
#import "ADBCyTOFPanelGenerator.h"

@interface ADBMetalPanelViewController (){
    float totalVolumeStored;
}


@property (nonatomic, strong) LabeledAntibody *deletable;
@property (nonatomic, weak) UILabel *totalTextField;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) NSString *sortHandle;

@end

@implementation ADBMetalPanelViewController

@synthesize panel = _panel;
@synthesize popover = _popover;
@synthesize linkers = _linkers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPanel:(Panel *)panel
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.panel = panel;
        _sortHandle = @"tagMW";
        [self setDictionaries];
    }
    return self;
}

-(void)setDictionaries{
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *arrayObjects = [NSMutableArray array];
    for (NSDictionary *dict in [General jsonStringToObject:_panel.panDetails]) {
        [array addObject:dict.mutableCopy];
        [arrayObjects addObject:[self conjugateForLinkerDictionary:dict.mutableCopy]];
    }

    NSArray *theSortedArray = [array sortedArrayUsingComparator:^(NSDictionary * obj1, NSDictionary * obj2) {
        LabeledAntibody *lab1 = [arrayObjects objectAtIndex:[array indexOfObject:obj1]];
        LabeledAntibody *lab2 = [arrayObjects objectAtIndex:[array indexOfObject:obj2]];
        if ([_sortHandle isEqualToString:@"labBBTubeNumber"]) {
            return [lab1.labBBTubeNumber compare:lab2.labBBTubeNumber options:NSNumericSearch];
        }
        if ([_sortHandle isEqualToString:@"tagMW"]) {
            return [lab1.tag.tagMW compare:lab2.tag.tagMW options:NSNumericSearch];
        }
        if ([_sortHandle isEqualToString:@"uL"]) {
            NSString * amount1 = [NSString stringWithFormat:@"%f", [self microLiterOfConjugate:obj1]];
            NSString * amount2 = [NSString stringWithFormat:@"%f", [self microLiterOfConjugate:obj2]];
            return [amount1 compare:amount2 options:NSNumericSearch];
        }
        return [(NSString *)[obj1 valueForKey:@"plaActualConc"] compare:(NSString *)[obj2 valueForKey:@"plaActualConc"] options:NSNumericSearch];
    }];
    self.linkers = theSortedArray.mutableCopy;
    [self refreshTable];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *sep = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    NSMutableArray *rightItems = [NSMutableArray arrayWithObjects:
                                  [[UIBarButtonItem alloc]initWithTitle:@"Duplicate panel" style:UIBarButtonItemStyleDone target:self action:@selector(duplicate)],
                                  sep,
                                  [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(done)],
                                  sep,
                                  [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actions:)],
                                  sep, nil];
    
    if (_panel) {
        
        [General iPhoneBlock:^{} iPadBlock:^{
            sep.width = 100;
        }];
        
        
        
        if([[[ADBAccountManager sharedInstance]currentGroupPerson].gpeGroupPersonId isEqualToString:_panel.createdBy])
            [rightItems addObject:[[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(edit:)]];
        
        self.navigationItem.rightBarButtonItems = rightItems;
    }else{
        self.navigationItem.rightBarButtonItem.action = @selector(done);
    }
    NSNumber *previous = [[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"panel%@", _panel.panPanelId]];
    if(previous)totalVolumeStored = previous.floatValue;
    else totalVolumeStored = 300.0f;
    [self.tableView reloadData];
    [self setTheTableviewWithStyle:UITableViewStylePlain];
    
    self.noAutorefresh = YES;
}

-(void)done{
    [self checkRefreshables];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setDictionaries];
    [self refreshTable];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithFloat:totalVolumeStored] forKey:[NSString stringWithFormat:@"panel%@", _panel.panPanelId]];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)edit:(UIBarButtonItem *)sender{

    ADBMetalsViewController *edit = [[ADBMetalsViewController alloc]initWithNibName:nil bundle:nil andPanel:_panel];
    [self.navigationController pushViewController:edit animated:YES];
}


-(void)actions:(UIBarButtonItem *)sender{
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *printAction = [UIAlertAction
                                   actionWithTitle:@"Print"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [General print:self.tableView fromSender:self.navigationItem.rightBarButtonItem withJobName:[NSString stringWithFormat:@"%@", _panel.panName]];
                                   }];
    [alertController addAction:printAction];
    
    UIAlertAction *emailAction = [UIAlertAction
                                  actionWithTitle:@"Send email"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      [General sendToFriend:nil withData:[General generatePDFData:self.tableView] withSubject:[NSString stringWithFormat:@"%@", _panel.panName] fileName:[NSString stringWithFormat:@"%@.pdf", _panel.panName] fromVC:self];
                                  }];
    [alertController addAction:emailAction];
    
    UIAlertAction *pdfAction = [UIAlertAction
                                  actionWithTitle:@"Generate PDF"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      [General generatePDFFromScrollView:self.tableView onVC:self];
                                  }];
    [alertController addAction:pdfAction];
    
    UIAlertAction *csvAction = [UIAlertAction
                                actionWithTitle:@"Generate CSV"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action)
                                {
                                    [General sendToFriend:nil withData:[self generateCsv] withSubject:[NSString stringWithFormat:@"%@", _panel.panName] fileName:[NSString stringWithFormat:@"%@.csv", _panel.panName] fromVC:self];
                                }];
    [alertController addAction:csvAction];
    
    UIAlertAction *numberAction = [UIAlertAction
                                  actionWithTitle:@"Order by tube #"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      _sortHandle = @"labBBTubeNumber";
                                      [self setDictionaries];
                                  }];
    [alertController addAction:numberAction];
    
    UIAlertAction *metalAction = [UIAlertAction
                                  actionWithTitle:@"Order by metal tag"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      _sortHandle = @"tagMW";
                                      [self setDictionaries];
                                  }];
    [alertController addAction:metalAction];
    
    UIAlertAction *uLAction = [UIAlertAction
                                  actionWithTitle:@"Order by uL"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      _sortHandle = @"uL";
                                      [self setDictionaries];
                                  }];
    [alertController addAction:uLAction];
    
    UIAlertAction *cyTOFAction = [UIAlertAction
                                  actionWithTitle:@"Generate panel for CyTOF1"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      [self cyTOF1];
                                  }];
    UIAlertAction *cyTOF2Action = [UIAlertAction
                                  actionWithTitle:@"Generate panel for CyTOF2"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      [self cyTOF2];
                                  }];
    
    [alertController addAction:cyTOFAction];
    [alertController addAction:cyTOF2Action];
    
    alertController.popoverPresentationController.sourceView = [[UIApplication sharedApplication]keyWindow].rootViewController.view;
    alertController.popoverPresentationController.barButtonItem = sender;
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)print{
    [General generatePDFFromScrollView:self.tableView onVC:self];
}

-(NSData *)generateCsv{
    NSData *data;
    NSMutableString *csvString = [NSMutableString stringWithFormat:@"Tube number,MW,Metal,Clone name,Protein name,Conjugate concentration,Final concentration,uL to add\n"];
    for(NSDictionary *linker in _linkers){
        NSArray *result = [General searchDataBaseForClass:LABELEDANTIBODY_DB_CLASS withTerm:[linker valueForKey:@"plaLabeledAntibodyId"] inField:@"labLabeledAntibodyId" sortBy:@"labLabeledAntibodyId" ascending:YES inMOC:self.managedObjectContext];
        if (result.count > 0) {
            LabeledAntibody *lab = result.lastObject;
            [csvString appendString:lab.labBBTubeNumber];
            [csvString appendFormat:@","];
            [csvString appendString:lab.tag.tagMW];
            [csvString appendFormat:@","];
            [csvString appendString:lab.tag.tagName];
            [csvString appendFormat:@","];
            [csvString appendString:lab.lot.clone.cloName];
            [csvString appendFormat:@","];
            [csvString appendString:lab.lot.clone.protein.proName];
            [csvString appendFormat:@","];
            [csvString appendString:lab.labConcentration];
            [csvString appendFormat:@" ug/uL,"];
            [csvString appendString:[linker valueForKey:@"plaActualConc"]];
            [csvString appendFormat:@" ug/mL,"];
            [csvString appendFormat:@"%.2f uL", [self microLiterOfConjugate:linker]];
            [csvString appendFormat:@"\n"];
        }
        
    }
    NSLog(@"CSV is %@", csvString);
    data = [csvString dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

-(void)duplicate{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Name this panel" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
    [alertController addAction:cancel];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Duplicate" style:UIAlertActionStyleDefault handler:^(UIAlertAction *handler){
        Panel *newPanel = (Panel *)[IPCloner clone:_panel inContext:self.managedObjectContext];
        newPanel.panPanelId = nil;
        newPanel.panDetails = _panel.panDetails;
        newPanel.panName = [(UITextField *)[alertController.textFields objectAtIndex:0]text];
        [self refreshTable];
    }];
    yes.enabled = NO;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Name this duplicate";
         [textField addTarget:self action:@selector(enableOKButtonForTextField) forControlEvents:UIControlEventEditingChanged];
     }];
    [alertController addAction:yes];
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)cancel{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


-(void)cyTOF1{
    [[[ADBCyTOFPanelGenerator alloc]init] generateCyTOFString:1 withPanel:_panel andLinkers:_linkers fromVC:self];
}

-(void)cyTOF2{
    [[[ADBCyTOFPanelGenerator alloc]init] generateCyTOFString:2 withPanel:_panel andLinkers:_linkers fromVC:self];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _linkers.count + 3;
}

-(LabeledAntibody *)conjugateForLinkerDictionary:(NSMutableDictionary *)linker{
    NSArray *results = [General searchDataBaseForClass:LABELEDANTIBODY_DB_CLASS withTerm:[linker valueForKey:@"plaLabeledAntibodyId"] inField:@"labLabeledAntibodyId" sortBy:@"labLabeledAntibodyId" ascending:YES inMOC:self.managedObjectContext];
    if (results.count > 0) {
        LabeledAntibody *lab = results.lastObject;
        return lab;
    }
    return nil;
}

-(float)microLiterOfConjugate:(NSMutableDictionary *)linker{
    LabeledAntibody *lab = [self conjugateForLinkerDictionary:linker];
    if (lab) {
        float microL = [[linker valueForKey:@"plaActualConc"]floatValue]*totalVolumeStored/lab.labConcentration.floatValue;
        return microL;
    }
    return 0.0f;
}

-(void)changeFinalConcentration:(double)concentration ofLinker:(NSMutableDictionary *)linker{
    [linker setValue:[NSString stringWithFormat:@"%.2f", concentration] forKey:@"plaActualConc"];
}

-(void)checkRefreshables{
    _panel.panDetails = [General jsonObjectToString:_linkers];
    [[IPExporter getInstance]updateInfoForObject:_panel withBlock:nil];
}

-(void)sliderChanged:(UISlider *)sender{
    int sobra = (int)sender.value%20;
    float value;
    if (sobra == 0) {
        value = (int)sender.value;
    }else{
        value = floorf(sender.value-sobra);
    }
    sender.value = value;
    totalVolumeStored = value;
    self.totalTextField.text = [NSString stringWithFormat:@"%.0f uL", totalVolumeStored];
    [self.tableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellId = @"General";
    static NSString *cellId2 = @"Specific";
    
    
    
    if (indexPath.row >= [_linkers count]) {
        
        UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        }
        
        for(UIView *view in cell.contentView.subviews){
            if([view isMemberOfClass:[UIStepper class]] || [view isMemberOfClass:[UISlider class]]){
                [view removeFromSuperview];
            }
        }
        
        if (indexPath.row == [_linkers count]) {
            cell.textLabel.text = @"Total antibodies";
            float total = 0;
            for(NSDictionary *linker in _linkers){
                total = total + [self microLiterOfConjugate:linker];
            }
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f uL", total];
            cell.detailTextLabel.textColor = [UIColor colorWithRed:79.0f/255.0f green:159.0f/255.0f blue:49.0f/255.0f alpha:1];
        }else if(indexPath.row == _linkers.count + 1){
            cell.textLabel.text = @"Diluent";
            float total = 0;
            for(NSDictionary *linker in _linkers){
                total = total + [self microLiterOfConjugate:linker];
            }
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f uL", totalVolumeStored - total];
            cell.detailTextLabel.textColor = [UIColor orangeColor];
        }
        else if(indexPath.row == _linkers.count + 2){
            cell.textLabel.text = @"TOTAL";
            self.totalTextField = cell.detailTextLabel;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f uL", totalVolumeStored];
            [cell.detailTextLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(setTotalVolume)]];
            cell.detailTextLabel.userInteractionEnabled = YES;
            if(!_slider)
                self.slider = [[UISlider alloc]initWithFrame:CGRectMake(200, 0, cell.frame.size.width - 400, 70)];
            _slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [cell addSubview:_slider];
            _slider.tintColor = [UIColor orangeColor];
            //MIN
            float total = 0;
            for(NSDictionary *linker in _linkers){
                total = total + [self microLiterOfConjugate:linker];
            }
            _slider.minimumValue = total;
            //MAX
            _slider.maximumValue = 1000.0f;
            //VALUE
            _slider.value = totalVolumeStored;
            [_slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
            [_slider setThumbImage:[UIImage imageNamed:@"cylinderOrange.png"] forState:UIControlStateNormal];

            cell.detailTextLabel.textColor = [UIColor blackColor];
        }
        return cell;
    }
    
    ADBMetalPanelCellTableViewCell *cell = (ADBMetalPanelCellTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId2];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ADBMetalPanelCellTableViewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.delegate = self;
    cell.tag = indexPath.row;
    NSMutableDictionary *conjugateLinker = [_linkers objectAtIndex:indexPath.row];
    cell.linker = conjugateLinker;
    cell.panel = _panel;
    return cell;
}

-(void)setTotalVolume{
    ADBKeyBoardViewController *keyB = [[ADBKeyBoardViewController alloc]init];
    keyB.zdelegate = self;
    [self showModalOrPopoverWithViewController:keyB withFrame:CGRectMake(self.view.bounds.size.width/2 - 100, self.view.bounds.size.height - 100, 200, 200)];
}
-(void)sendNumber:(NSString *)number{
    totalVolumeStored = number.floatValue;
    _slider.value = totalVolumeStored;
    [self.tableView reloadData];
}


-(void)showInfoFor:(int)tag{
    LabeledAntibody *lab = [self conjugateForLinkerDictionary:[_linkers objectAtIndex:tag]];
    ADBAllInfoForAbViewController *info = [[ADBAllInfoForAbViewController alloc]initWithNibName:nil bundle:nil andConjugate:lab];
    [self showModalWithCancelButton:info fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

//Override if necesary
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    id cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell respondsToSelector:@selector(linker)]){
        LabeledAntibody *conjugate = [self conjugateForLinkerDictionary:[_linkers objectAtIndex:indexPath.row]];
        if (conjugate.tubFinishedBy.intValue == 0) {
            return YES;
        }
        if (conjugate.tubIsLow.intValue != 1 && conjugate.tubFinishedBy.intValue == 0) {
            return YES;
        }
    }
    return NO;
}


-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    LabeledAntibody *conjugate = [self conjugateForLinkerDictionary:[_linkers objectAtIndex:indexPath.row]];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Archive" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        if (conjugate.tubFinishedBy.intValue == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure" message:@"This action is not reversible" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
                [General finishedTube:conjugate withBlock:^{
                    UIAlertController *alertB = [UIAlertController alertControllerWithTitle:@"Reorder" message:@"Would you like to place an order request" preferredStyle:UIAlertControllerStyleAlert];
                    [alertB addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
                    [alertB addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
                        [General reorder:conjugate.lot withAmount:1 andPurpose:@"Keep stock" withBlock:^{
                            [self.tableView reloadData];
                        }];
                        
                    }]];
                    [self presentViewController:alertB animated:YES completion:nil];
                    [self.tableView reloadData];
                }];
                
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    
    UITableViewRowAction *lowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Mark is low" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [General lowlevelsofTube:conjugate withBlock:^{
            
        }];
        
    }];
    lowAction.backgroundColor = [UIColor grayColor];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    if (conjugate.tubFinishedBy.intValue == 0) {
        [array addObject:deleteAction];
    }
    if (conjugate.tubIsLow.intValue != 1 && conjugate.tubFinishedBy.intValue == 0) {
        [array addObject:lowAction];
    }
    return [NSArray arrayWithArray:array];
}


@end
