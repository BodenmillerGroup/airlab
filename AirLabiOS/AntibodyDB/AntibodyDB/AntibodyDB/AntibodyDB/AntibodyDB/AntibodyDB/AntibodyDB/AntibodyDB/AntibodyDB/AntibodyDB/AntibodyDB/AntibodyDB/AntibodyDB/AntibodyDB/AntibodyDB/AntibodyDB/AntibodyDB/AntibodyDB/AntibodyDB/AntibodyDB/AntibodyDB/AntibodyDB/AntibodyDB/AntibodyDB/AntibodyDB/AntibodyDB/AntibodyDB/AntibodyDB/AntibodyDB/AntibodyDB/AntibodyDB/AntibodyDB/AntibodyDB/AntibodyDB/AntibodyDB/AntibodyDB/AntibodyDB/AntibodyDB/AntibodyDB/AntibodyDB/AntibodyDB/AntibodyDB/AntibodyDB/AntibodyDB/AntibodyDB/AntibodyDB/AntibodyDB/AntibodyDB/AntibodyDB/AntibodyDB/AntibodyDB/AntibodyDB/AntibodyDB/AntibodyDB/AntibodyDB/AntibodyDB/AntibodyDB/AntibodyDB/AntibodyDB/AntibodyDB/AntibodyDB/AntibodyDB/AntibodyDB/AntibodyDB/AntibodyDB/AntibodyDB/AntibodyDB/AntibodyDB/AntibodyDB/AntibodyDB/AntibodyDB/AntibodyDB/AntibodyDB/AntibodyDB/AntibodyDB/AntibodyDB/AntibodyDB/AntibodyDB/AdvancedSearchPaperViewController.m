    //
//  AdvancedSearchPaperViewController.m
//  LabPad
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//
#import "AdvancedSearchPaperViewController.h"
#import "ADBPubmedSearchViewController.h"


@implementation AdvancedSearchPaperViewController

@synthesize inputField, outputField, addTermsButton, from, to, typeOfTerm, fromSwitch, toSwitch, searchTerms;


#pragma mark pickerView

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	
	NSCalendar * gregorian = 
	[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDate *todayDate = [NSDate date];
	int flags = (NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit);
	NSDateComponents * comps = 
	[gregorian components:flags fromDate:todayDate];
	
	NSInteger year = [comps year];
	return (year - 1900);
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	return [NSString stringWithFormat:@"%i", (int)(1901 + row)];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	if (pickerView.tag == 0 && fromSwitch.on) {
		[self addTerms];
	}
	if (pickerView.tag == 1 && toSwitch.on) {
		[self addTerms];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self.fromSwitch setOn:NO];
	[self.toSwitch setOn:NO];
	[self.outputField setText:nil];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAdvancedSearch)];

	
	termTypeArray = [NSArray arrayWithObjects:@"All Fields", @"Author", @"Journal", @"Title/Abstract", @"Title", @"MeSH", nil];
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:YES];
	NSCalendar * gregorian = 
	[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDate *todayDate = [NSDate date];
	int flags = (NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit);
	NSDateComponents * comps = 
	[gregorian components:flags fromDate:todayDate];
	NSInteger year = [comps year];
	//(year - 1900);
	
	[self.from selectRow:70 inComponent:0 animated:YES];
	[self.to selectRow:(year -1901) inComponent:0 animated:YES];
}

-(IBAction)advancedSearchButton{
	[self performAdvancedSearch];
}
-(void)performAdvancedSearch{
	[self.delegate performAdvancedSearchWithTerm:self.outputField.text];
}

-(void)cancelAdvancedSearch{
	[self.delegate performAdvancedSearchWithTerm:nil];
}

-(IBAction)addTerms{
	if (self.searchTerms == nil) {
		NSMutableArray *array = [NSMutableArray array];
		self.searchTerms = array;
	}
	if ([inputField.text length]>0) {
		[self.searchTerms addObject:[NSDictionary dictionaryWithObject:self.inputField.text forKey:[termTypeArray objectAtIndex:self.typeOfTerm.selectedSegmentIndex]]];
	}
	
	NSMutableString *theOutput = [NSMutableString string];
	
	if ([searchTerms count]>0) {
		int i=0;
		for (i=0; i<([searchTerms count]-1); i++) {
			NSString *aKey = [[[self.searchTerms objectAtIndex:i] allKeys]lastObject];
			NSString *aValue = [[[self.searchTerms objectAtIndex:i] allValues]lastObject];
			if ([aKey isEqual:@"All Fields"]) {
				[theOutput appendFormat:@"%@ AND ", aValue];
			}else{
				[theOutput appendFormat:@"%@[%@] AND ", aValue, aKey];
			}
		}
	}
	
	NSString *aKey = [[[self.searchTerms lastObject] allKeys]lastObject];
	NSString *aValue = [[[self.searchTerms lastObject] allValues]lastObject];
	if ([aKey isEqual:@"All Fields"]) {
		[theOutput appendFormat:@"%@", aValue];
	}else{
		[theOutput appendFormat:@"%@[%@]", aValue, aKey];
	}
	
	if (fromSwitch.on && !toSwitch.on) {
		[theOutput appendFormat:@" AND ('%@'[Date - Publication] : '3000'[Date - Publication])", [self pickerView:self.from titleForRow:[self.from selectedRowInComponent:0] forComponent:0]]; 
	}else if (fromSwitch.on && toSwitch.on) {
		[theOutput appendFormat:@" AND (%@[Date - Publication] : %@[Date - Publication])", [self pickerView:self.from titleForRow:[self.from selectedRowInComponent:0] forComponent:0], [self pickerView:self.to titleForRow:[self.to selectedRowInComponent:0] forComponent:0]];
	}else if (!fromSwitch.on && toSwitch.on) {
		[theOutput appendFormat:@" AND ('1900'[Date - Publication] : '%@'[Date - Publication])", [self pickerView:self.to titleForRow:[self.to selectedRowInComponent:0] forComponent:0]];
	}else {
		//Don't add anything
	}
	
	if (theOutput) {
		self.outputField.text = theOutput;
	}
	self.inputField.text = nil;
	[self.inputField resignFirstResponder];
}

-(IBAction)removeTerm{
	if ([searchTerms count]>=1) {
		[searchTerms removeLastObject];
	}
	[self addTerms];
}
-(IBAction)switchOn{
	[self addTerms];
}

-(IBAction)resignKeyBoard{
	[inputField resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.inputField = nil;
	self.outputField = nil;
	self.addTermsButton = nil;
	self.from = nil;
	self.to = nil;
	self.typeOfTerm = nil;
	self.fromSwitch = nil;
	self.toSwitch = nil;
}


@end
