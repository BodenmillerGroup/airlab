//
//  ADBSeePaperViewController.h
//  LabPad
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ADBMasterViewController.h"


@class Paper;

@interface ADBSeePaperViewController : ADBMasterViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) NSArray *data;
@property (nonatomic, retain) UILabel *titleArticle;
@property (nonatomic, retain) UILabel *authorsArticle;
@property (nonatomic, retain) UILabel *abstractArticle;
@property (nonatomic, retain) UILabel *journalArticle;
@property (nonatomic, retain) UILabel *dateLabelArticle;


-(void)searchForArticleData:(NSString *)searchString;
-(IBAction)addToMyPapers;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andArticle:(ScientificArticle *)article;


@end
