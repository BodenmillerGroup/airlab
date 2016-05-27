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

-(void)advancedSearch:(NSString *)term;

@end

@interface ADBPubmedDetailViewController : ADBMasterViewController

@property (nonatomic, retain) IBOutlet UITextField *searchField;
@property (nonatomic, retain) IBOutlet UISegmentedControl *typeOfTerm;
@property (nonatomic, assign) id<AdvancedSearch>delegate;


@end
