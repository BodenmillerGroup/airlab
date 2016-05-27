//
//  PlateLayoutViewController.m
//  LabPad
//
//  Created by Raul Catena on 5/10/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBTemplaterViewController.h"
#import "PlateView.h"
#import "Plate.h"
#import "PlateWell.h"
#import <QuartzCore/QuartzCore.h>

#define GAP 40


@interface ADBTemplaterViewController()

@property (nonatomic, strong) Plate *plate;

@end

@implementation ADBTemplaterViewController


-(void)createPlateWithPrevious:(Plate *)plate{
    int rowNumber = (int)self.rowsSlider.value;
    int columnNumber = (int)self.columnsSlider.value;
    self.thePlateView = [[PlateView alloc]initWithFrame:CGRectMake(GAP, GAP, self.plateView.bounds.size.width - GAP, self.plateView.bounds.size.height - GAP) andRows:rowNumber andColumns:columnNumber];
    //self.plateView.contentSize = _thePlateView.bounds.size;
    self.plateView.minimumZoomScale = 0.9;
	self.plateView.maximumZoomScale = 3;
	//self.plateView.delegate = self;
    
    [self.plateView addSubview:_thePlateView];
    [_thePlateView setNeedsDisplay];
    
	CGFloat gapColumns = _thePlateView.bounds.size.width/(float)columnNumber;
	CGFloat gapRows = _thePlateView.bounds.size.height/(float)rowNumber;
	
	NSArray *alphabet = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", nil];
    
    NSArray *theWells;
    if (plate) {
        NSSortDescriptor *sortD = [NSSortDescriptor sortDescriptorWithKey:@"pwlPosition" ascending:YES];
        theWells = [plate.wells sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortD]];
    }
    
    int x;
	for (x=0; x<(rowNumber * columnNumber); x++) {
		
		int y = floor(x /columnNumber);//indicates the row
		int z =x-(columnNumber * y);//indicates the column
		
		UIButton *boxButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[boxButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		boxButton.backgroundColor = [UIColor whiteColor];
		//boxButton.layer.borderColor = [UIColor blackColor].CGColor;
		//boxButton.layer.borderWidth = 0.5f;
		//boxButton.layer.cornerRadius = 10.0f;
		boxButton.tag = x;
		[boxButton addTarget:self action:@selector(selectDeselect:) forControlEvents:UIControlEventTouchUpInside];
		boxButton.frame = CGRectMake((5 + (z * gapColumns)), (5 + (y * gapRows)), (gapColumns - 10), (gapRows - 10));
        boxButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        boxButton.titleLabel.numberOfLines = 3;
        boxButton.titleLabel.frame = CGRectMake(0, 0, boxButton.bounds.size.width, boxButton.bounds.size.height);
        boxButton.titleLabel.font = [UIFont systemFontOfSize:18];
        boxButton.titleLabel.minimumScaleFactor = 10;
		boxButton.titleLabel.textColor = [UIColor blackColor];
		[_thePlateView addSubview:boxButton];
        
        if (theWells) {
            [boxButton setTitle:[(PlateWell *)[theWells objectAtIndex:x]pwlText] forState:UIControlStateNormal];
        }
		
        NSString *letter = [alphabet objectAtIndex:y];
		NSString *number = [NSString stringWithFormat:@"%i", z + 1];
		UILabel *rowLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, (GAP + (y * gapRows) + ((gapRows-30)/2)), 20, 30)];
		rowLabel.text = letter;
		[self.plateView addSubview:rowLabel];
		UILabel *columnLabel = [[UILabel alloc]initWithFrame:CGRectMake(((GAP + (gapColumns/2)) + (z * gapColumns)), GAP - 35, 20, 30)];
		columnLabel.text = number;
		[self.plateView addSubview:columnLabel];
		
	}
    [_rowsSlider setHidden:YES];
    [_columnsSlider setHidden:YES];
    [_aNewButton setHidden:YES];
    [_filas setHidden:YES];
    [_columnas setHidden:YES];
    [_typeOfPlate setHidden:YES];
    [_startButton setHidden:NO];
    [_saveButton setHidden:NO];
}

-(IBAction)createPlate:(UIButton *)sender{
    [self createPlateWithPrevious:nil];
}

-(IBAction)savePlateRoutine:(NSString *)title{
    Plate *plate = (Plate *)[General newObjectOfType:@"Plate" saveContext:YES];
    plate.plaRows = [NSString stringWithFormat:@"%i", (int)self.rowsSlider.value];
    plate.plaColumns = [NSString stringWithFormat:@"%i", (int)self.columnsSlider.value];
    plate.plaPlateName = title;
    
    int wells = plate.plaRows.intValue*plate.plaColumns.intValue;
    for (int x = 0; x<wells; x++) {
        PlateWell *well = (PlateWell *)[General newObjectOfType:@"PlateWell" saveContext:YES];
        well.pwlPosition = [NSString stringWithFormat:@"%i", x];
        well.pwlText = [(UIButton *)[_thePlateView.subviews objectAtIndex:x]titleLabel].text;
        [General doLinkForProperty:@"plate" inObject:well withReceiverKey:@"pwlPlateId" fromDonor:plate withPK:@"plaPlateId"];
        well.plate = plate;
    }
    [General saveContextAndRoll];
}

-(void)didSelectPlate:(Plate *)plate{
    _plate = plate;
    _rowsSlider.value = plate.plaRows.floatValue;
    _columnsSlider.value = plate.plaColumns.floatValue;
    [self createPlateWithPrevious:_plate];
    [self.popover dismissPopoverAnimated:YES];
}

-(IBAction)savePlate:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Save plate" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    NSString *title = [alertView textFieldAtIndex:0].text;
    return title.length > 0?YES:NO;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSString *title = [alertView textFieldAtIndex:0].text;
        [self savePlateRoutine:title];
    }
}

-(void)selectDeselect:(UIButton *)sender{
    for(UIView* aView in self.view.subviews){
        if([aView isMemberOfClass:[UITextView class]])[aView removeFromSuperview];
    }
    
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, 200, 100)];
    textView.tag = sender.tag;
    currentWell = sender.tag;
    UIButton *theButton = (UIButton *)[_thePlateView.subviews objectAtIndex:sender.tag];
    if (theButton.titleLabel.text.length > 0) {
        textView.text = theButton.titleLabel.text;
    }
    [textView setFont:[UIFont fontWithName:@"TrebuchetMS" size:25]];
    UIViewController *viewC = [[UIViewController alloc]init];
    viewC.view = textView;
    viewC.preferredContentSize = textView.bounds.size;
    [General iPhoneBlock:^{
        [self.view addSubview:textView];
    } iPadBlock:^{
        self.popover = [[UIPopoverController alloc]initWithContentViewController:viewC];
        [self.popover setDelegate:self];
        [self.popover presentPopoverFromRect:sender.frame inView:self.thePlateView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }];
    [textView becomeFirstResponder];

    
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    UITextView *textView = (UITextView *)popoverController.contentViewController.view;
    int x = textView.tag;

    NSArray *theWells;
    if (_plate) {
        NSSortDescriptor *sortD = [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES];
        theWells = [_plate.wells sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortD]];
    }
    
    UIButton *theButton = (UIButton *)[_thePlateView.subviews objectAtIndex:x];
    if (theWells) {
        [(PlateWell *)[theWells objectAtIndex:x]setPwlText:textView.text];
    }
    [theButton setTitle:textView.text forState:UIControlStateNormal];           
}

-(void)sliderChanged:(UISlider *)sender{
    if (sender == _rowsSlider) {
        self.filas.text = [NSString stringWithFormat:@"%i rows", (int)sender.value];
    }
    if (sender == _columnsSlider) {
        self.columnas.text = [NSString stringWithFormat:@"%i columns", (int)sender.value];
    }
    _typeOfPlate.selectedSegmentIndex = -1;
}

-(IBAction)selectorChanged:(UISegmentedControl *)sender{
    int filas;
    int columnas;
    
    filas = 1*pow(2.0, (double)sender.selectedSegmentIndex);
    
    switch (sender.selectedSegmentIndex){
        case 0:{
            filas = 2;
            columnas = 3;
        }
            break;
        case 1:{
            filas = 3;
            columnas = 4;
        }
            break;
        case 2:{
            filas = 4;
            columnas = 6;
        }
            break;
        case 3:{
            filas = 6;
            columnas = 8;
        }
            break;
        case 4:{
            filas = 8;
            columnas = 12;
        }
            break;
        default:{
            filas = 1;
            columnas = 0;
        }
    }
    _filas.text = [NSString stringWithFormat:@"%i rows", filas];
    _columnas.text = [NSString stringWithFormat:@"%i columns", columnas];
    _rowsSlider.value = filas;
    _columnsSlider.value = columnas;
}

-(void)start:(id)sender{
    [_rowsSlider setHidden:NO];
    [_columnsSlider setHidden:NO];
    [_aNewButton setHidden:NO];
    [_filas setHidden:NO];
    [_columnas setHidden:NO];
    [_typeOfPlate setHidden:NO];
    [_startButton setHidden:YES];
    [_saveButton setHidden:YES];
    self.thePlateView = nil;
    for (UIView *aView in self.plateView.subviews) {
        [aView removeFromSuperview];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return self.thePlateView;NSLog(@"viewforzooming");
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{
	for (UIView *aView in _thePlateView.subviews) {
		aView.contentMode = UIViewContentModeRedraw;
		[aView setNeedsDisplay];
		if ([aView isKindOfClass:[UIButton class]]) {
			[[(UIButton *)aView titleLabel]setContentScaleFactor:scale];
			[[(UIButton *)aView titleLabel]setNeedsDisplay];
		}		
	}
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.startButton.hidden = YES;
    self.preferredContentSize = self.view.bounds.size;
    self.title = @"Plate layout creator";
    [General addBorderToButton:_aNewButton withColor:[UIColor orangeColor]];
    [General addBorderToButton:_startButton withColor:[UIColor orangeColor]];
    [General addBorderToButton:_saveButton withColor:[UIColor orangeColor]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Add to journal" style:UIBarButtonItemStyleBordered target:self action:@selector(plateImage)];
    
    [[IPFetchObjects getInstance]addPlatesForServerWithBlock:nil];
    [[IPFetchObjects getInstance]addPlateWellsForServerWithBlock:nil];
}

-(void)showSavedPlates:(UIButton *)sender{
    ADBSavedPlatesViewController *plates = [[ADBSavedPlatesViewController alloc]init];
    plates.delegate = self;
    self.popover = [[UIPopoverController alloc]initWithContentViewController:plates];
    [self.popover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    UIBarButtonItem *log = nil;
    if (self.navigationItem.rightBarButtonItem) {
        log = self.navigationItem.rightBarButtonItem;
    }
    UIBarButtonItem *print = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(print:)];
    UIBarButtonItem *pdf = [[UIBarButtonItem alloc]initWithTitle:@"PDF" style:UIBarButtonItemStylePlain target:self action:@selector(generatePDF)];
    NSArray *array;
    if (log) {
        array = [NSArray arrayWithObjects:log, print, pdf, nil];
    }else{
        array = [NSArray arrayWithObjects:print, pdf, nil];
    }
    self.navigationItem.rightBarButtonItems = array;
}


-(IBAction)sendToFriend:(UIButton *)sender withData:(NSData *)data{
	[General sendToFriend:sender withData:data withSubject:@"Plate layout" fileName:[NSDate date].description fromVC:self];
}

-(void)generatePDF{
    if (self.startButton.hidden) {
        return;
    }
    [General generatePDFFromScrollView:self.plateView onVC:self];
}

#pragma print

-(void)printPDF:(NSData *)data andSender:(UIBarButtonItem *)sender{
    [General print:self.plateView fromSender:sender withJobName:self.plate.plaPlateName];
}


-(void)print:(UIBarButtonItem *)sender{
    [General print:self.plateView fromSender:sender withJobName:self.plate.plaPlateName];
}


-(void)plateImage{
    UIGraphicsBeginImageContext([self.plateView.layer frame].size);
    
    [self.plateView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    [self.delegate generatedPlateImage:outputImage];
}

@end
