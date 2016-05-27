//
//  ADBArticleCellViewController.h
//  LabPad
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ADBArticleCellViewController : UITableViewCell {

	//Paper *paper; Will have
    
    UILabel *titlePaperLabel;
    UILabel *authors;
    UILabel *journal;
	UILabel *date;
}

//@property (nonatomic, retain) Paper *paper;

@property (nonatomic, retain) IBOutlet UILabel *titlePaperLabel;
@property (nonatomic, retain) IBOutlet UILabel *authors;
@property (nonatomic, retain) IBOutlet UILabel *journal;
@property (nonatomic, retain) IBOutlet UILabel *date;

@end
