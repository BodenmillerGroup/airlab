//
//  ADBPubmedSearchViewController.h
//  LabPad
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADBMasterViewController.h"
#import "ADBPubmedDetailViewController.h"

@class PaperTableViewCell;

@interface ADBPubmedSearchViewController : ADBMasterViewController <AdvancedSearch> {

	BOOL searchingIDs;
	BOOL searching;
	
}

@property (nonatomic, retain) NSArray *titlesOfPapers;
@property (nonatomic, retain) NSArray *journals;
@property (nonatomic, retain) NSArray *authors;
@property (nonatomic, retain) NSArray *dates;
@property (nonatomic, retain) NSArray *pubmedIDsArray;
@property (nonatomic, retain) IBOutlet UITextField *searchBox;

-(IBAction)searchButton;
-(IBAction)goToAdvancedSearch;

@end
