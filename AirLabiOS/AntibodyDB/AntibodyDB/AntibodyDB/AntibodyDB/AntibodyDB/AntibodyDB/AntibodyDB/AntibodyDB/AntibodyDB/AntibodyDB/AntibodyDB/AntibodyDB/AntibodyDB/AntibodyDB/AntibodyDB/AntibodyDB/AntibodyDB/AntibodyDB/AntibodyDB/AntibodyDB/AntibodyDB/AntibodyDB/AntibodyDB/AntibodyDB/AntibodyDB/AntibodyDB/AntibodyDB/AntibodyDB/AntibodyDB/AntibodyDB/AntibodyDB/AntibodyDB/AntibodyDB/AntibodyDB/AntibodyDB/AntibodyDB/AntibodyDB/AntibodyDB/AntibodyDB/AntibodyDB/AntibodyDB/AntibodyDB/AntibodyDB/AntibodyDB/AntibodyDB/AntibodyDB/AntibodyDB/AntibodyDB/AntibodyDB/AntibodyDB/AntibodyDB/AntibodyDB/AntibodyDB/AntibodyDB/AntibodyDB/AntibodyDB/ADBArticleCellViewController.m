//
//  ADBArticleCellViewController.m
//  LabPad
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBArticleCellViewController.h"


@implementation ADBArticleCellViewController

@synthesize titlePaperLabel, journal, authors, date;
//@synthesize paper;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		NSInteger newSize = 22; //calculate new size based on length
		
		[ self.titlePaperLabel setFont: [ UIFont systemFontOfSize: newSize ]];
		[self.titlePaperLabel setLineBreakMode:NSLineBreakByWordWrapping];
    }
	
    return self;
}

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */



@end
