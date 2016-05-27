//
//  PSNatureViewController.h
//  iScientist
//
//  Created by Raul Catena on 10/20/13.
//  Copyright (c) 2013 Raul Catena. All rights reserved.
//

#import "ADBMasterViewController.h"
#import <MessageUI/MessageUI.h>

@interface PSNatureViewController : ADBMasterViewController <MFMailComposeViewControllerDelegate>{
    int journal;//0 Nature, 1 Science, 2 PNAS
}

@property (nonatomic, retain) NSArray *newsArray;
@property (nonatomic, weak) IBOutlet UISegmentedControl *journalSegments;

-(IBAction)journalChanged:(UISegmentedControl *)sender;

@end
