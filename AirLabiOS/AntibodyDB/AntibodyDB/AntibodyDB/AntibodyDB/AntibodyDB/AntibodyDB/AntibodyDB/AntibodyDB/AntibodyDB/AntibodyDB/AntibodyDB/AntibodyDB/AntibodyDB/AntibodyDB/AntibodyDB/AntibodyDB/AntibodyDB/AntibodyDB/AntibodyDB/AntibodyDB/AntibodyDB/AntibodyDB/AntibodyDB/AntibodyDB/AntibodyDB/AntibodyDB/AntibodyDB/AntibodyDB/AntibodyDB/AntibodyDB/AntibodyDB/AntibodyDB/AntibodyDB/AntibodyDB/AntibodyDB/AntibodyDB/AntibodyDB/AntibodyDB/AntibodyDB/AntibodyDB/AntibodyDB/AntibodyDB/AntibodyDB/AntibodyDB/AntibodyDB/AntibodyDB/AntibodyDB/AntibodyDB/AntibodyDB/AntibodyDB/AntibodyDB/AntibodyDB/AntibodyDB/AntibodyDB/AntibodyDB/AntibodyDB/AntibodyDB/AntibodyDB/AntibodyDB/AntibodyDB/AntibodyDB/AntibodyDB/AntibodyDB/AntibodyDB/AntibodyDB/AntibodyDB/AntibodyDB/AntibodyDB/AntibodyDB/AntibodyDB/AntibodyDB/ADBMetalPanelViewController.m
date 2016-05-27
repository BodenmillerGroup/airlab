//
//  ADBMetalPanelViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/8/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMetalPanelViewController.h"
#import "ADBMetalsViewController.h"
#import "ADBAllInfoForAbViewController.h"

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
@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPanel:(Panel *)panel
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.panel = panel;
        _sortHandle = @"labeledAntibody.tag.tagMW";
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationController.viewControllers.count == 1) {
        UIBarButtonItem *sep = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        [General iPhoneBlock:^{} iPadBlock:^{
            sep.width = 100;
        }];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
                                                   [[UIBarButtonItem alloc]initWithTitle:@"Duplicate panel" style:UIBarButtonItemStyleBordered target:self action:@selector(duplicate)],
                                                   sep,
                                                   [[UIBarButtonItem alloc]initWithTitle:@"DONE" style:UIBarButtonItemStylePlain target:self action:@selector(done)],
                                                   sep,
                                                   [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actions:)],
                                                   sep,
                                                   [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(edit:)],nil];
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

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self refreshTable];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithFloat:totalVolumeStored] forKey:[NSString stringWithFormat:@"panel%@", _panel.panPanelId]];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)edit:(UIBarButtonItem *)sender{
    NSMutableArray *clones = [NSMutableArray arrayWithCapacity:_panel.panelLabeledAntibodies.count];
    for (ZPanelLabeledAntibody *linker in _panel.panelLabeledAntibodies) {
        [clones addObject:linker.labeledAntibody];
    }
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
    
    UIAlertAction *numberAction = [UIAlertAction
                                  actionWithTitle:@"Order by tube #"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      _sortHandle = @"labeledAntibody.labBBTubeNumber";
                                      self.fetchedResultsController = nil;
                                      [self refreshTable];
                                  }];
    [alertController addAction:numberAction];
    
    UIAlertAction *metalAction = [UIAlertAction
                                  actionWithTitle:@"Order by metal tag"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      _sortHandle = @"labeledAntibody.tag.tagMW";
                                      self.fetchedResultsController = nil;
                                      [self refreshTable];
                                  }];
    [alertController addAction:metalAction];
    
    UIAlertAction *uLAction = [UIAlertAction
                                  actionWithTitle:@"Order by uL"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      _sortHandle = @"zetFactor.floatValue";
                                      self.fetchedResultsController = nil;
                                      [self refreshTable];
                                  }];
    [alertController addAction:uLAction];
    
    UIAlertAction *cyTOFAction = [UIAlertAction
                                  actionWithTitle:@"Generate panel for CyTOF"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      
                                  }];
    [alertController addAction:cyTOFAction];
    alertController.popoverPresentationController.sourceView = [[UIApplication sharedApplication]keyWindow].rootViewController.view;
    alertController.popoverPresentationController.barButtonItem = sender;
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)print{
    [General generatePDFFromScrollView:self.tableView onVC:self];
}

-(void)duplicate{
    Panel *newPanel = (Panel *)[IPCloner clone:_panel inContext:self.managedObjectContext];
    newPanel.panPanelId = nil;
    for(ZPanelLabeledAntibody *linker in _fetchedResultsController.fetchedObjects){NSLog(@"________");
        ZPanelLabeledAntibody *newLiner = (ZPanelLabeledAntibody *)[IPCloner clone:linker inContext:self.managedObjectContext];
        [General doLinkForProperty:@"panel" inObject:newLiner withReceiverKey:@"plaPanelId" fromDonor:newPanel withPK:@"panPanelId"];
        [General doLinkForProperty:@"labeledAntibody" inObject:newLiner withReceiverKey:@"plaLabeledAntibodyId" fromDonor:linker.labeledAntibody withPK:@"labLabeledAntibodyId"];
        newLiner.plaPanelLabeledAntibodyId = nil;
    }
    
    self.panel = newPanel;
    [self refreshTable];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Name this panel" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.tag = 2;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}



-(void)done{
    if (!_panel.panName) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Name this panel" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
        return;
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self checkRefreshables];
    }];
}

-(void)cancel{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    UITextField *field = [alertView textFieldAtIndex:0];
    if (field.text.length > 0) {
        return YES;
    }
    return NO;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1 && buttonIndex == 0){
        //_deletable.deleted = @"1";
        [[IPExporter getInstance]deleteObject:_deletable withBlock:nil];
        [self.tableView reloadData];
        return;
    }
    if (buttonIndex == 1) {
        UITextField *field = [alertView textFieldAtIndex:0];
        self.panel.panName = field.text;
        [[ADBAccountManager sharedInstance]addPersonGroup:[[ADBAccountManager sharedInstance]currentGroupPerson] toObject:_panel];
        [[IPExporter getInstance]uploadInfoForNewObject:_panel withBlock:nil];
        [self refreshTable];
        
    }
    if(alertView.tag != 2){
        [self.delegate didAddPanel:self.panel];
    }
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ZPANELLABELEDANTIBODY_DB_CLASS];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:_sortHandle ascending:YES selector:@selector(localizedStandardCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"panel == %@", self.panel];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];//TODO add section name keypath with protein or epitope
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fetchedResultsController.fetchedObjects.count + 3;
}

-(float)microLiterOfConjugate:(ZPanelLabeledAntibody *)linker{
    float microL = linker.plaActualConc.floatValue*totalVolumeStored/linker.labeledAntibody.labConcentration.floatValue;
    return microL;
}

-(void)changeFinalConcentration:(double)concentration ofLinker:(ZPanelLabeledAntibody *)linker{
    linker.plaActualConc = [NSString stringWithFormat:@"%.2f", concentration];
}

-(void)checkRefreshables{
    for(ZPanelLabeledAntibody *linker in _fetchedResultsController.fetchedObjects){
        [[IPExporter getInstance]updateInfoForObject:linker withBlock:nil];
    }
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
    
    
    
    if (indexPath.row >= [_fetchedResultsController.fetchedObjects count]) {
        
        UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        }
        
        for(UIView *view in cell.contentView.subviews){
            if([view isMemberOfClass:[UIStepper class]] || [view isMemberOfClass:[UISlider class]]){
                [view removeFromSuperview];
            }
        }
        
        if (indexPath.row == [_fetchedResultsController.fetchedObjects count]) {
            cell.textLabel.text = @"Total antibodies";
            float total = 0;
            for(ZPanelLabeledAntibody *lab in _fetchedResultsController.fetchedObjects){
                total = total + [self microLiterOfConjugate:lab];
            }
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f uL", total];
            cell.detailTextLabel.textColor = [UIColor colorWithRed:79.0f/255.0f green:159.0f/255.0f blue:49.0f/255.0f alpha:1];
        }else if(indexPath.row == _fetchedResultsController.fetchedObjects.count + 1){
            cell.textLabel.text = @"Diluent";
            float total = 0;
            for(ZPanelLabeledAntibody *lab in _fetchedResultsController.fetchedObjects){
                total = total + [self microLiterOfConjugate:lab];
            }
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f uL", totalVolumeStored - total];
            cell.detailTextLabel.textColor = [UIColor orangeColor];
        }
        else if(indexPath.row == _fetchedResultsController.fetchedObjects.count + 2){
            cell.textLabel.text = @"TOTAL";
            self.totalTextField = cell.detailTextLabel;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f uL", totalVolumeStored];
            if(!_slider)
                self.slider = [[UISlider alloc]initWithFrame:CGRectMake(200, 0, cell.frame.size.width - 400, 70)];
            _slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [cell addSubview:_slider];
            _slider.tintColor = [UIColor orangeColor];
            //MIN
            float total = 0;
            for(ZPanelLabeledAntibody *lab in _fetchedResultsController.fetchedObjects){
                total = total + [self microLiterOfConjugate:lab];
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
    ZPanelLabeledAntibody *conjugateLinker = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.linker = conjugateLinker;
    return cell;
}



-(void)showInfoFor:(int)tag{
    LabeledAntibody *lab = (LabeledAntibody *)[_fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
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
    return YES;
}



-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    LabeledAntibody *conjugate = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Archive" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        if (!conjugate.deleted.boolValue) {
            _deletable = conjugate;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Archive?" message:@"Are you sure? This action can not be undone" delegate:self cancelButtonTitle:@"Archive" otherButtonTitles:@"Cancel", nil];
            alert.tag = 1;
            [alert show];
        }
    }];
    
    UITableViewRowAction *shareAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Mark is low" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        conjugate.catchedInfo = @"1";
        [[IPExporter getInstance]updateInfoForObject:conjugate withBlock:nil];
        [self.tableView reloadData];
    }];
    shareAction.backgroundColor = [UIColor grayColor];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    if (conjugate.deleted.intValue != 1) {
        [array addObject:deleteAction];
    }
    if (conjugate.catchedInfo.intValue != 1 && conjugate.deleted.intValue != 1) {
        [array addObject:shareAction];
    }
    return [NSArray arrayWithArray:array];
}


@end
