//
//  ADBJournalViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 6/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBJournalViewController.h"
#import "ADBUtilitiesViewController.h"


@interface ADBJournalViewController ()

@property (nonatomic, strong) Ensayo *ensayo;
@property (nonatomic, strong) Lot *lot;
@property (nonatomic, strong) LabeledAntibody *conjugate;

@end

@implementation ADBJournalViewController

@synthesize fetchedResultsController = _fetchedResultsController;

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
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"ensayo = %@", _ensayo];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];//TODO add section name keypath with protein or epitope
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(void)refreshCanvasSize{
    float cumulative = 20.0f;
    int x = 0;
    for (UIView *view in _canvas.subviews) {
        view.tag = x;
        cumulative = cumulative + view.bounds.size.height + 20;
        x++;
    }
    if (_currentTextView) {
        cumulative = cumulative + 250.0f;
    }
    NSLog(@"New size is %f", MAX(cumulative, self.view.bounds.size.height));
    _canvas.contentSize = CGSizeMake(self.view.bounds.size.width, MAX(cumulative, self.view.bounds.size.height));
}

-(float)getLastPosition{
    float cumulative = 20.0f;
    for (UIView *view in _canvas.subviews) {
        cumulative = cumulative + view.bounds.size.height + 20;
    }
    return cumulative;
}

-(void)setUpPart:(ADBPartView *)part{
    part.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    part.delegate = self;
    part.frame = CGRectMake(20, [self getLastPosition], part.frame.size.width - 40, part.frame.size.height);
    [self.canvas addSubview:part];
    [self refreshCanvasSize];
}


-(void)loadParts{
    [_fetchedResultsController performFetch:nil];
    
    BOOL firstTime = NO;
    
    if (self.canvas.subviews.count>0) {
        for (UIView *aView in self.canvas.subviews) {
            [aView removeFromSuperview];
        }
        [self refreshCanvasSize];
    }else{
        firstTime = YES;
    }
    
    if (_fetchedResultsController.fetchedObjects.count > 0) {
        int x = 0;
        for (Part *ensayoPart in _fetchedResultsController.fetchedObjects) {
            ADBPartView *part = [[ADBPartView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100) andPart:ensayoPart];
            part.tag = x;
            x++;
            [self setUpPart:part];
        }
        [self refreshCanvasSize];
    }
    //if (firstTime)
    //[self.canvas scrollRectToVisible:[(UIView *)[self.canvas.subviews lastObject]frame] animated:YES];
}

-(void)reload{
    [self loadParts];
}

-(void)addSectionAtEnd{
    [_fetchedResultsController performFetch:nil];
    ADBPartView *partView = [[ADBPartView alloc]initWithFrame:self.view.frame andPart:[_fetchedResultsController.fetchedObjects lastObject]];
    [self setUpPart:partView];
    [self refreshCanvasSize];
}

-(void)moveFromIndex:(int)index pixels:(float)pixels{
    if (index == _canvas.subviews.count) {
        [self refreshCanvasSize];
        [self.canvas scrollRectToVisible:_canvas.frame animated:YES];
        return;
    }
    for (int x = index; x<_canvas.subviews.count; x++) {
        UIView *subV = [_canvas.subviews objectAtIndex:x];
        [UIView animateWithDuration:1.0 animations:^{
            subV.frame = CGRectOffset(subV.frame, 0, pixels);
        }completion:^(BOOL finished){
            [self refreshCanvasSize];
        }];
    }
}

-(void)partsLoadFromIndex:(int)from deltaHeight:(float)delta{
    if (self.canvas.subviews.count>0) {
        
        int y;
        for (y = from; y<_canvas.subviews.count; y++) {
            UIView *aView = [self.canvas.subviews objectAtIndex:y];
            if (y>=from) {
                [UIView beginAnimations:@"RemoveView" context:NULL];
                [aView removeFromSuperview];
                [UIView commitAnimations];
            }
        }
        
        for (y = from; y<_fetchedResultsController.fetchedObjects.count; y++) {
            Part *part = [_fetchedResultsController.fetchedObjects objectAtIndex:y];
            ADBPartView *partView = [[ADBPartView alloc]initWithFrame:self.view.frame andPart:part];
            [self setUpPart:partView];
        }
    }
    [self refreshCanvasSize];
}

-(void)didDeleteSection:(ADBPartView *)part{
    [UIView animateWithDuration:1.0 animations:^{
        part.alpha = 0.0f;
    } completion:^(BOOL finished){
        [part removeFromSuperview];
        for (int x = part.tag; x<_canvas.subviews.count; x++) {
            ADBPartView *aView = (ADBPartView *)[_canvas.subviews objectAtIndex:x];
            aView.tag = x;
        }
        [self moveFromIndex:(int)part.tag pixels:-part.bounds.size.height-20];
    }];
}


-(void)setUpButtons{
    UIBarButtonItem *addSectionButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(addPart)];
    UIBarButtonItem *pdfButton = [[UIBarButtonItem alloc]initWithTitle:@"PDF" style:UIBarButtonItemStyleBordered target:self action:@selector(createPDF)];
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpButtons];
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];if(error)[General logError:error];
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!_currentTextView && _canvas.scrollEnabled)[self loadParts];
    
    //TODO change this one call so that there is only one update
    __block int theInt = 0;
    [[IPFetchObjects getInstance]addPartsForServerWithBlock:^{[_fetchedResultsController performFetch:nil];theInt++;if(theInt == 2)[self loadParts];}];
    [[IPFetchObjects getInstance]addFilesForServerWithBlock:^{[_fetchedResultsController performFetch:nil];theInt++;if(theInt == 2)[self loadParts];}];
    [[IPFetchObjects getInstance]addFilePartsForServerWithBlock:^{[_fetchedResultsController performFetch:nil];theInt++;if(theInt == 2)[self loadParts];}];
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

-(void)addText:(UIBarButtonItem *)sender{
    Part *part = (Part *)[General newObjectOfType:PART_DB_CLASS saveContext:YES];
    [General doLinkForProperty:@"ensayo" inObject:part withReceiverKey:@"prtEnsayoId" fromDonor:_ensayo withPK:@"enyEnsayoId"];
    part.prtPosition = [NSString stringWithFormat:@"%i", _ensayo.parts.count];
    part.prtType = @"text";
    NSError *error;
    [_fetchedResultsController performFetch:&error];
    if (error)[General logError:error];
    [self addSectionAtEnd];
}

-(void)textViewActive:(UITextView *)textView{
    self.currentTextView = textView;
    //[self.canvas scrollRectToVisible:textView.superview.frame animated:YES];
    [self refreshCanvasSize];
}

-(void)textViewInActive:(UITextView *)textView{
    self.currentTextView = nil;
    [self refreshCanvasSize];
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

-(void)createPartWithImage:(UIImage *)image{
    NSData *data = UIImageJPEGRepresentation(image, 0.2);
    File *aFile = (File *)[General newObjectOfType:FILE_DB_CLASS saveContext:YES];
    aFile.zetData = data;
    aFile.filExtension = @"jpg";
    aFile.filHash = [General randomStringWithLength:18];
    Part *part = (Part *)[General newObjectOfType:PART_DB_CLASS saveContext:YES];
    part.prtPosition = [NSString stringWithFormat:@"%i", _ensayo.parts.count];
    part.prtType = @"pic";
    //aFile.part = part;
    ZFilePart *linker = (ZFilePart *)[General newObjectOfType:NSStringFromClass([ZFilePart class]) saveContext:YES];
    
    [General doLinkForProperty:@"part" inObject:linker withReceiverKey:@"fptPartId" fromDonor:part withPK:@"prtPartId"];
    [General doLinkForProperty:@"file" inObject:linker withReceiverKey:@"fptFileId" fromDonor:aFile withPK:@"filFileId"];
    [General doLinkForProperty:@"ensayo" inObject:part withReceiverKey:@"prtEnsayoId" fromDonor:_ensayo withPK:@"enyEnsayoId"];
    [General saveContextAndRoll];
    [self addSectionAtEnd];
    
    NSMutableURLRequest *request = [General photoUpload:data withName:aFile.filHash];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response_, NSData *data_, NSError *error_){
        if (!data || [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]intValue] == 0) {
            aFile.zetUploadData = data;
        }
    }];
}

-(void)addDoodle:(UIBarButtonItem *)sender{
    
    UIImage *image = [ADBJournalViewController imageWithColor:[UIColor whiteColor] andSize:CGSizeMake(500, 500)];
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
    _canvas.scrollEnabled = !isDood;
}

#pragma mark UIImagePickerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self createPartWithImage:image];
    
    [self dismissViewControllerAnimated:YES completion:^{[self loadParts];}];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage : (UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    [self createPartWithImage:image];
    
    [self dismissViewControllerAnimated:YES completion:^{[self loadParts];}];
}

-(void)createPDF{
    [General generatePDFFromScrollView:self.canvas onVC:self];
}

-(void)printPDF:(UIBarButtonItem *)sender{
    [General printPDF:[General generatePDFData:_canvas] andSender:sender withJobName:_ensayo.enyTitle];
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
        [General doLinkForProperty:@"tubeValidated" inObject:(Object *)_ensayo withReceiverKey:@"enyTubeValidatedId" fromDonor:(Object *)_lot withPK:@"lotLotId"];
        ADBAccountManager *manager = [ADBAccountManager sharedInstance];
        [manager addPersonGroup:[manager currentGroupPerson] toObject:(Object *)_ensayo];
        [General saveContextAndRoll];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}

#pragma EraseSection delegate

-(void)sectionErased:(ADBPartView *)section withView:(ADBPartView *)partView{
    
}

-(void)closeSection:(ADBPartView *)section withView:(ADBPartView *)partView{
    
}

-(void)changeHeightOfSection:(ADBPartView *)section withView:(ADBPartView *)partView andTextView:(UITextView *)textView{
    
}

#pragma mark DBRestClient Delegate
//Will need override


#pragma mark AddFileToPartDelegate

-(void)selectedFile:(File *)file{
    Part *part = (Part *)[General newObjectOfType:PART_DB_CLASS saveContext:YES];
    part.prtPosition = [NSString stringWithFormat:@"%i", _ensayo.parts.count];
    part.prtType = @"fil";
    ZFilePart *linker = (ZFilePart *)[General newObjectOfType:NSStringFromClass([ZFilePart class]) saveContext:YES];
    
    [General doLinkForProperty:@"part" inObject:linker withReceiverKey:@"fptPartId" fromDonor:part withPK:@"prtPartId"];
    [General doLinkForProperty:@"file" inObject:linker withReceiverKey:@"fptFileId" fromDonor:file withPK:@"filFileId"];
    [General doLinkForProperty:@"ensayo" inObject:part withReceiverKey:@"prtEnsayoId" fromDonor:_ensayo withPK:@"enyEnsayoId"];
    [General saveContextAndRoll];
    [self addSectionAtEnd];
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
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:panel.panelLabeledAntibodies.count];
    [dict setValue:[NSNumber numberWithInt:type] forKey:@"app"];
    [dict setValue:tissue forKey:@"sample"];
    
    for (ZPanelLabeledAntibody *linker in panel.panelLabeledAntibodies) {
        NSString *phospho = @"";
        if (linker.labeledAntibody.lot.clone.cloIsPhospho.intValue == 1) {
            phospho = @"p-";
        }
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:@[
                                                                         linker.labeledAntibody.labLabeledAntibodyId,
                                                                         [NSString stringWithFormat:@"%@%@", phospho, linker.labeledAntibody.lot.clone.protein.proName],
                                                                         linker.labeledAntibody.lot.clone.cloName,
                                                                         linker.plaActualConc,
                                                                         linker.labeledAntibody.labBBTubeNumber,
                                                                         [NSString stringWithFormat:@"%i", isVal]
                                                                         ]
                                                               forKeys:@[
                                                                         @"LabeledAb",
                                                                         @"Protein name",
                                                                         @"Clone name",
                                                                         @"Concentration",
                                                                         @"Tube number",
                                                                         @"Validation"
                                                                         ]];
        
        [dict setValue:dictionary forKey:[NSString stringWithFormat:@"%i", x]];
        x++;
    }
    part.catchedInfo = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error] encoding:NSUTF8StringEncoding];
    if (error)[General logError:error];
    
    NSError *error2;
    [_fetchedResultsController performFetch:&error2];
    if (error2)[General logError:error2];
    [self addSectionAtEnd];
}

@end
