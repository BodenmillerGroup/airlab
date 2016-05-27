//
//  ADBNewJournalViewViewController.m
//  AirLab
//
//  Created by Raul Catena on 7/3/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import "ADBNewJournalViewViewController.h"

#define START_CANVAS 55.0f

@interface ADBNewJournalViewViewController ()
@property (nonatomic, strong) Ensayo *ensayo;
@property (nonatomic, strong) LabeledAntibody *conjugate;
@property (nonatomic, strong) Lot *lot;
@property (nonatomic, strong) NSMutableArray *cells;

@end

@implementation ADBNewJournalViewViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.noAutorefresh = YES;
    
    if(!_cells)self.cells = [NSMutableArray array];
    
    [self setTheTableviewWithStyle:UITableViewStylePlain];
    self.tableView.frame = CGRectMake(0, START_CANVAS, self.tableView.frame.size.width, self.tableView.frame.size.height - START_CANVAS);
    
    [self setUpButtons];
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];if(error)[General logError:error];
    
    [[IPFetchObjects getInstance]addPartsForServerWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_fetchedResultsController performFetch:nil];
            [self.tableView reloadData];
        });
    }];
    [[IPFetchObjects getInstance]addFilesForServerWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_fetchedResultsController performFetch:nil];
            [self.tableView reloadData];
        });
    }];
    [[IPFetchObjects getInstance]addFilePartsForServerWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_fetchedResultsController performFetch:nil];
            [self.tableView reloadData];
        });
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andEnsayo:(Ensayo *)ensayo
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.ensayo = ensayo;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andLot:(Lot *)lot andConj:(LabeledAntibody *)conjugate
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.lot = lot;
        self.conjugate = conjugate;
        self.ensayo = [NSEntityDescription insertNewObjectForEntityForName:ENSAYO_DB_CLASS inManagedObjectContext:self.managedObjectContext];
        self.ensayo.enyTitle = [NSString stringWithFormat:@"Validation experiment for %@ (%@)", self.lot.lotNumber, [NSDate date].description];
        [General offlineIdToObject:(Object *)_ensayo];
    }
    return self;
}

#pragma mark - View lifecycle

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:PART_DB_CLASS];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
        request.predicate = [NSPredicate predicateWithFormat:@"ensayo = %@", _ensayo];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];//TODO add section name keypath with protein or epitope
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fetchedResultsController.fetchedObjects.count;
}

-(ADBPartViewCellTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"PartCell";
    Part *part = [_fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    ADBPartViewCellTableViewCell *cell;
    if (indexPath.row < _cells.count - 1 && _cells.count > 0) {
        cell = [_cells objectAtIndex:indexPath.row];
    }else{
        cell = [[ADBPartViewCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID andPart:part];
        cell.delegate = self;
        [_cells addObject:cell];
    }
    return cell;
}

-(void)refreshTable{
    dispatch_async(dispatch_get_main_queue(), ^{
        [super refreshTable];
    });
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < _cells.count - 1 && _cells.count > 0) {
        ADBPartViewCellTableViewCell * cell = (ADBPartViewCellTableViewCell *)[_cells objectAtIndex:indexPath.row];
        return [cell frameCalculated].size.height;
    }else{
        return 100.0f;
    }
}

-(void)setUpButtons{
    self.optionsButton = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 55)];
    self.optionsButton.tintColor = [UIColor orangeColor];
    [self.view addSubview:_optionsButton];
    
    UIBarButtonItem *addSectionButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(addPart)];
    UIBarButtonItem *pdfButton = [[UIBarButtonItem alloc]initWithTitle:@"PDF" style:UIBarButtonItemStyleDone target:self action:@selector(createPDF)];
    UIBarButtonItem *printButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(printPDF:)];
    NSArray *arrayOfButtons = [NSArray arrayWithObjects:addSectionButton, pdfButton, printButton, nil];
    self.navigationItem.rightBarButtonItems = arrayOfButtons;
    
    UIImage *utilities = [UIImage imageNamed:@"swiss-knife.png"];
    UIButton *utilitiesButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [utilitiesButton setBackgroundImage:utilities forState:UIControlStateNormal];
    [utilitiesButton addTarget:self action:@selector(showSwiss:) forControlEvents:UIControlEventTouchUpInside];
    [utilitiesButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *utilitiesBarButton = [[UIBarButtonItem alloc]initWithCustomView:utilitiesButton];
    
    UIImage *addReag = [UIImage imageNamed:@"water-bottleOrange.png"];
    UIButton *addReagButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [addReagButton setBackgroundImage:addReag forState:UIControlStateNormal];
    [addReagButton addTarget:self action:@selector(showToInclude:) forControlEvents:UIControlEventTouchUpInside];
    [addReagButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *addReagBarBarButton = [[UIBarButtonItem alloc]initWithCustomView:addReagButton];
    
    UIImage *addSamples = [UIImage imageNamed:@"cylinderOrange.png"];
    UIButton *addSamplesButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [addSamplesButton setBackgroundImage:addSamples forState:UIControlStateNormal];
    [addSamplesButton addTarget:self action:@selector(showGenerate:) forControlEvents:UIControlEventTouchUpInside];
    [addSamplesButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *addSamplesBarButton = [[UIBarButtonItem alloc]initWithCustomView:addSamplesButton];
    
    UIBarButtonItem *sep = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fix = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [General iPhoneBlock:^{fix.width = 0.0f;} iPadBlock:^{fix.width = 30.0f;}];
    
    
    UIBarButtonItem *addText = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(addText:)];
    UIBarButtonItem *addPicture = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(addPicture:)];
    UIBarButtonItem *addRecipe = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(addRecipe:)];
    UIBarButtonItem *addPanel = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(addPanel:)];
    UIBarButtonItem *addFile = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(addFile:)];
    UIBarButtonItem *addDoodle = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(addDoodle:)];
    UIBarButtonItem *addLayout = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(addPlate:)];
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:utilitiesBarButton];
    [array addObject:fix];
    [array addObject:addReagBarBarButton];
    [array addObject:fix];
    [array addObject:addSamplesBarButton];
    [array addObject:sep];
    [array addObject:addText];
    [array addObject:fix];
    [array addObject:addPicture];
    [array addObject:fix];
    [array addObject:addRecipe];
    [array addObject:fix];
    if (!_lot && !_conjugate) {
        [array addObject:addPanel];
        [array addObject:fix];
    }
    [array addObject:addFile];
    [array addObject:fix];
    [array addObject:addDoodle];
    [array addObject:fix];
    [array addObject:addLayout];
    
    self.optionsButton.items = [NSArray arrayWithArray:array];
}

-(void)saveRoutine{
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    for (Part *part in self.fetchedResultsController.fetchedObjects) {
        if (part.hasChanges) {
            [[IPExporter getInstance]updateObject:part withBlock:nil];
        }
    }
    [General saveContextAndRoll];
}

#pragma mark Add content

-(void)addText:(UIBarButtonItem *)sender{
    Part *part = (Part *)[General newObjectOfType:PART_DB_CLASS saveContext:YES];
    [General doLinkForProperty:@"ensayo" inObject:part withReceiverKey:@"prtEnsayoId" fromDonor:_ensayo withPK:@"enyEnsayoId"];
    part.prtPosition = [NSString stringWithFormat:@"%lu", (unsigned long)_ensayo.parts.count];
    part.prtType = @"text";
    NSError *error;
    [_fetchedResultsController performFetch:&error];
    if (error)[General logError:error];
    [self.tableView reloadData];
}

-(void)textViewActive:(UITextView *)textView{
    self.currentTextView = textView;
}

-(void)textViewInActive:(UITextView *)textView{
    self.currentTextView = nil;
}

-(void)addPicture:(UIBarButtonItem *)sender{
    [General showCameraWithDelegate:self inVC:self];
}
-(void)addRecipe:(UIBarButtonItem *)sender{
    
}
-(void)addFile:(UIBarButtonItem *)sender{
    ADBSelectFileViewController *select = [[ADBSelectFileViewController alloc]init];
    select.delegate = self;
    [self showModalWithCancelButton:select fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
}

-(void)createPartWithImage:(UIImage *)image{
    NSData *data = UIImageJPEGRepresentation(image, 0.2);
    File *aFile = (File *)[General newObjectOfType:FILE_DB_CLASS saveContext:YES];
    aFile.zetData = data;
    aFile.filExtension = @"jpg";
    aFile.filHash = [NSString stringWithFormat:@"%@_%@", [General randomStringWithLength:2], [General randomStringWithLength:18]];
    aFile.catchedInfo = [NSString stringWithFormat:@"%@|%lu", aFile.filHash, (unsigned long)data.length];
    aFile.filSize = [NSString stringWithFormat:@"%lu", (unsigned long)data.length];
    Part *part = (Part *)[General newObjectOfType:PART_DB_CLASS saveContext:YES];
    part.prtPosition = [NSString stringWithFormat:@"%lu", (unsigned long)_ensayo.parts.count];
    part.prtType = @"pic";
    //aFile.part = part;
    ZFilePart *linker = (ZFilePart *)[General newObjectOfType:NSStringFromClass([ZFilePart class]) saveContext:YES];
    
    [General doLinkForProperty:@"part" inObject:linker withReceiverKey:@"fptPartId" fromDonor:part withPK:@"prtPartId"];
    [General doLinkForProperty:@"file" inObject:linker withReceiverKey:@"fptFileId" fromDonor:aFile withPK:@"filFileId"];
    [General doLinkForProperty:@"ensayo" inObject:part withReceiverKey:@"prtEnsayoId" fromDonor:_ensayo withPK:@"enyEnsayoId"];
    [General saveContextAndRoll];
    [self.tableView reloadData];
    
    aFile.zetUploadData = data;
    [General saveContextAndRoll];

}

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)addDoodle:(UIBarButtonItem *)sender{
    
    UIImage *image = [ADBNewJournalViewViewController imageWithColor:[UIColor whiteColor] andSize:CGSizeMake(500, 500)];
    [self createPartWithImage:image];
}
-(void)addPlate:(UIBarButtonItem *)sender{
    ADBTemplaterViewController *plate = [[ADBTemplaterViewController alloc]init];
    plate.delegate = self;
    UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:plate];
    self.popover = [[UIPopoverController alloc]initWithContentViewController:navCon];
    [self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)generatedPlateImage:(UIImage *)image{
    [self createPartWithImage:image];
    [self.popover dismissPopoverAnimated:YES];
}

-(void)isDoodling:(BOOL)isDood{
    self.tableView.scrollEnabled = !isDood;
}

#pragma mark UIImagePickerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self createPartWithImage:image];
    
    [self dismissViewControllerAnimated:YES completion:^{[self.tableView reloadData];}];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage : (UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    [self createPartWithImage:image];
    
    [self dismissViewControllerAnimated:YES completion:^{[self.tableView reloadData];}];
}

-(void)createPDF{
    [General generatePDFFromScrollView:self.tableView onVC:self];
}

-(void)printPDF:(UIBarButtonItem *)sender{
    [General printPDF:[General generatePDFData:self.tableView] andSender:sender withJobName:_ensayo.enyTitle];
}

-(void)showSwiss:(UIButton *)sender{
    ADBUtilitiesViewController *utils = [[ADBUtilitiesViewController alloc]init];
    UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:utils];
    [General iPhoneBlock:^{
        [self showModalWithCancelButton:utils fromVC:self withPresentationStyle:UIModalPresentationFullScreen];
    } iPadBlock:^{
        [self showModalOrPopoverWithViewController:navCon withFrame:sender.frame];
    }];
}

-(void)showToInclude:(UIButton *)sender{
    ADBAllReagentsPickerViewController *pick = [[ADBAllReagentsPickerViewController alloc]init];
    pick.delegate = self;
    [self showModalOrPopoverWithViewController:pick withFrame:sender.frame];
}



-(void)showGenerate:(UIButton *)sender{
    ADBAllSamplesViewController *pick = [[ADBAllSamplesViewController alloc]init];
    pick.delegate = self;
    [self showModalOrPopoverWithViewController:pick withFrame:sender.frame];
}

/*-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
 return [self.scrollView.subviews objectAtIndex:0];
 }*/

-(void)addPart{
    if (_lot || _conjugate) {
        [General doLinkForProperty:@"tubeValidated" inObject:(Object *)_ensayo withReceiverKey:@"enyTubeValidatedId" fromDonor:(Object *)_lot withPK:@"reiReagentInstanceId"];
        ADBAccountManager *manager = [ADBAccountManager sharedInstance];
        [manager addPersonGroup:[manager currentGroupPerson] toObject:(Object *)_ensayo];
        [General saveContextAndRoll];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark Delete Part

-(void)didDeleteSection:(ADBPartViewCellTableViewCell *)part{
    [_cells removeObject:part];
    [self.fetchedResultsController performFetch:nil];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

#pragma EraseSection delegate

//-(void)sectionErased:(ADBPartView *)section withView:(ADBPartView *)partView{
//    
//}
//
//-(void)closeSection:(ADBPartView *)section withView:(ADBPartView *)partView{
//    
//}
//
//-(void)changeHeightOfSection:(ADBPartView *)section withView:(ADBPartView *)partView andTextView:(UITextView *)textView{
//    
//}

#pragma mark DBRestClient Delegate
//Will need override


#pragma mark AddFileToPartDelegate

-(void)selectedFile:(File *)file{
    Part *part = (Part *)[General newObjectOfType:PART_DB_CLASS saveContext:YES];
    part.prtPosition = [NSString stringWithFormat:@"%lu", (unsigned long)_ensayo.parts.count];
    part.prtType = @"fil";
    ZFilePart *linker = (ZFilePart *)[General newObjectOfType:NSStringFromClass([ZFilePart class]) saveContext:YES];
    [General doLinkForProperty:@"part" inObject:linker withReceiverKey:@"fptPartId" fromDonor:part withPK:@"prtPartId"];
    [General doLinkForProperty:@"file" inObject:linker withReceiverKey:@"fptFileId" fromDonor:file withPK:@"filFileId"];
    [General doLinkForProperty:@"ensayo" inObject:part withReceiverKey:@"prtEnsayoId" fromDonor:_ensayo withPK:@"enyEnsayoId"];
    [General saveContextAndRoll];
    [self.tableView reloadData];
    [self dismissModalOrPopover];
}

-(void)addPanel:(UIBarButtonItem *)sender{
    ADBPanelsViewController *panels = [[ADBPanelsViewController alloc]init];
    panels.delegate = self;
    UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:panels];
    [self showModalOrPopoverWithViewController:navCon withFrame:sender.customView.superview.frame];
}

-(void)didSelectPanel:(Panel *)panel{
    
    ADBAddPanelToExpViewController *addPan = [[ADBAddPanelToExpViewController alloc]initWithPanel:panel];
    addPan.delegate = self;
    [(UINavigationController *)self.popover.contentViewController pushViewController:addPan animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
}

-(void)didSelectReagentInstance:(ReagentInstance *)aReagentInstance{
    if (_currentTextView) {
        _currentTextView.text = [_currentTextView.text stringByAppendingString:@"\n"];
        _currentTextView.text = [_currentTextView.text stringByAppendingString:aReagentInstance.comertialReagent.comName];
    }
    [self dismissModalOrPopover];
}

-(void)didSelectSample:(Sample *)aSample{
    if (_currentTextView) {
        _currentTextView.text = [_currentTextView.text stringByAppendingString:@"\n"];
        _currentTextView.text = [_currentTextView.text stringByAppendingString:[NSString stringWithFormat:@"%@ (%@)", aSample.samName, aSample.samConcentration]];
    }
    [self dismissModalOrPopover];
}

-(void)didAddDetailsForPanel:(Panel *)panel expType:(int)type andTissue:(NSString *)tissue isValidation:(BOOL)isVal{
    Part *part = (Part *)[General newObjectOfType:PART_DB_CLASS saveContext:YES];
    [General doLinkForProperty:@"ensayo" inObject:part withReceiverKey:@"prtEnsayoId" fromDonor:_ensayo withPK:@"enyEnsayoId"];
    part.prtPosition = [NSString stringWithFormat:@"%lu", (unsigned long)_ensayo.parts.count];
    part.prtType = @"pan";
    
    NSError *error;
    int x = 0;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[NSNumber numberWithInt:type] forKey:@"app"];
    [dict setValue:tissue forKey:@"sample"];
    [dict setValue:[NSString stringWithFormat:@"%i", isVal] forKey:@"Validation"];
    
    //TODO
    for (NSDictionary *linker in [General jsonStringToObject:panel.panDetails]) {
        NSArray *result = [General searchDataBaseForClass:LABELEDANTIBODY_DB_CLASS withTerm:[linker valueForKey:@"plaLabeledAntibodyId"] inField:@"labLabeledAntibodyId" sortBy:@"labLabeledAntibodyId" ascending:YES inMOC:self.managedObjectContext];
        if(result.count > 0){
            LabeledAntibody *antibody = result.lastObject;
            
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:@[
                                                                             antibody.labLabeledAntibodyId,
                                                                             [General showFullAntibodyName:antibody.lot.clone withSpecies:NO],
                                                                             antibody.lot.clone.cloName,
                                                                             [linker valueForKey:@"plaActualConc"],
                                                                             antibody.labBBTubeNumber,
                                                                             ]
                                                                   forKeys:@[
                                                                             @"LabeledAb",
                                                                             @"Protein name",
                                                                             @"Clone name",
                                                                             @"Concentration",
                                                                             @"Tube number",
                                                                             ]];
            [dict setValue:dictionary forKey:[NSString stringWithFormat:@"%i", x]];
            x++;
        }
    }
    
    part.catchedInfo = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error] encoding:NSUTF8StringEncoding];
    
    if (error)[General logError:error];
    
    NSError *error2;
    [_fetchedResultsController performFetch:&error2];
    if (error2)[General logError:error2];
    [self.tableView reloadData];
    [self dismissModalOrPopover];
}


@end
