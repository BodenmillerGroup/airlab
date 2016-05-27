//
//  AdvancedSearchPaperViewController.h
//  LabPad
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADBMasterViewController.h"

@protocol AdvancedSearch <NSObject>

-(void)performAdvancedSearchWithTerm:(NSString *)term;

@end

@interface AdvancedSearchPaperViewController : ADBMasterViewController <UIPickerViewDelegate, UIPickerViewDataSource> {

	NSArray *termTypeArray;
}

@property (nonatomic, retain) IBOutlet UITextField *inputField;
@property (nonatomic, retain) IBOutlet UITextView *outputField;
@property (nonatomic, retain) IBOutlet UIButton *addTermsButton;
@property (nonatomic, retain) IBOutlet UISegmentedControl *typeOfTerm;
@property (nonatomic, retain) IBOutlet UIPickerView *from;
@property (nonatomic, retain) IBOutlet UIPickerView *to;
@property (nonatomic, retain) IBOutlet UISwitch *fromSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *toSwitch;
@property (nonatomic, retain) NSMutableArray *searchTerms;
@property (nonatomic, assign) id<AdvancedSearch>delegate;


-(IBAction)advancedSearchButton;
-(IBAction)addTerms;
-(IBAction)removeTerm;
-(IBAction)resignKeyBoard;
-(IBAction)switchOn;
-(void)performAdvancedSearch;

@end
