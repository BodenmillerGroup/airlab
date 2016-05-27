//
//  ADBSciArtViewController.h
//  LabPad
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADBMasterViewController.h"

@interface ADBSciArtViewController : ADBMasterViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) IBOutlet UISegmentedControl *choice;

-(IBAction)choiceDone:(UISegmentedControl *)sender;

@end