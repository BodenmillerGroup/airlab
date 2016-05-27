//
//  ADBSeePaperViewController.m
//  LabPad
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBSeePaperViewController.h"
#import "ADBPubmedSearchViewController.h"
#import "ADBPubmedSession.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "ScientificArticle.h"


@interface ADBSeePaperViewController ()

@property (nonatomic, strong) ScientificArticle *article;

@end

@implementation ADBSeePaperViewController


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andArticle:(ScientificArticle *)article{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.article = article;
    }
    return self;
}

-(void)setLabels{
    CGRect frame = CGRectMake(0, 0, 20, 20);
    
    self.titleArticle = [[UILabel alloc]initWithFrame:frame];_titleArticle.numberOfLines = 0;
    self.titleArticle.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    self.titleArticle.font = [self.titleArticle.font fontWithSize:20];
        _titleArticle.textColor = [UIColor darkGrayColor];
    self.authorsArticle = [[UILabel alloc]initWithFrame:frame];_authorsArticle.numberOfLines = 0;
        _authorsArticle.textColor = [UIColor orangeColor];
    self.dateLabelArticle = [[UILabel alloc]initWithFrame:frame];_dateLabelArticle.numberOfLines = 0;
        _dateLabelArticle.textColor = [UIColor orangeColor];
    self.journalArticle = [[UILabel alloc]initWithFrame:frame];_journalArticle.numberOfLines = 0;
        _journalArticle.textColor = [UIColor darkGrayColor];
    self.abstractArticle = [[UILabel alloc]initWithFrame:frame];_abstractArticle.numberOfLines = 0;
        _abstractArticle.textColor = [UIColor darkGrayColor];
}

-(void)addDataFromArticle{
    self.titleArticle.text = _article.sciTitle;
    self.authorsArticle.text = _article.sciAuthors;
    self.dateLabelArticle.text = _article.sciPubDate;
    self.journalArticle.text = _article.sciSource;
    self.abstractArticle.text = _article.sciAbstract;
}

-(void)addDataFromDownload{
    self.titleArticle.text = [self.data objectAtIndex:0];
    self.authorsArticle.text = [self.data objectAtIndex:1];
    self.dateLabelArticle.text = [self.data objectAtIndex:2];
    self.journalArticle.text = [self.data objectAtIndex:3];
}

-(void)layFrames{
    float margin = 10.0f;
    float height = 10.0f;
    float width = self.view.bounds.size.width - 2*margin;
    
    self.titleArticle.frame = CGRectMake(margin, height, width, [General calculateHeightedLabelForLabelWithText:_titleArticle.text andWidth:width andFontSize:_titleArticle.font.pointSize]);
    self.titleArticle.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_titleArticle];
    height = height + margin + _titleArticle.bounds.size.height;
    
    self.authorsArticle.frame = CGRectMake(margin, height, width, [General calculateHeightedLabelForLabelWithText:_authorsArticle.text andWidth:width andFontSize:_authorsArticle.font.pointSize]);
        self.authorsArticle.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_authorsArticle];
    height = height + margin + _authorsArticle.bounds.size.height;
    
    self.dateLabelArticle.frame = CGRectMake(margin, height, width, [General calculateHeightedLabelForLabelWithText:_dateLabelArticle.text andWidth:width andFontSize:_dateLabelArticle.font.pointSize]);
        self.dateLabelArticle.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_dateLabelArticle];
    height = height + margin + _dateLabelArticle.bounds.size.height;
    
    self.journalArticle.frame = CGRectMake(margin, height, width, [General calculateHeightedLabelForLabelWithText:_journalArticle.text andWidth:width andFontSize:_journalArticle.font.pointSize]);
        self.journalArticle.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_journalArticle];
    height = height + margin + _journalArticle.bounds.size.height;
    
    self.abstractArticle.frame = CGRectMake(margin, height, width, [General calculateHeightedLabelForLabelWithText:_abstractArticle.text andWidth:width andFontSize:_abstractArticle.font.pointSize]);
        self.abstractArticle.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_abstractArticle];
    height = height + margin + _abstractArticle.bounds.size.height;
    
    UIScrollView *scroll = (UIScrollView *)self.view;
    scroll.contentSize = CGSizeMake(scroll.contentSize.width, height);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)addActions{
    NSMutableArray *actions = [NSMutableArray array];
    [actions addObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(goToSearch)]];
    if(!_article)
        [actions addObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addToMyPapers)]];
    [actions addObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(goToPubmedArticle)]];
    if (_article && !_article.sciLabShared.boolValue) {
        [actions addObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(shareWithLab)]];
    }
    [actions addObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(emailLab)]];
    
    self.navigationItem.rightBarButtonItems = actions;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setLabels];
    if (_article) {
        [self addDataFromArticle];
    }else{
        [self addDataFromDownload];
    }
    [self layFrames];
    
    [self addActions];
    
    if (_article) {
        [self searchForArticleData:_article.sciPubmedID];
    }else if(!_article)
        [self searchForArticleData:[self.data objectAtIndex:4]];
}

#pragma mark query

-(void)searchForArticleData:(NSString *)idArticle{
	
    NSString *aSearchString = [NSMutableString stringWithFormat:@"http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=%@&WebEnv=%@&query_key=%@&retmode=xml", idArticle, [ADBPubmedSession sharedInstance].webEnv, [ADBPubmedSession sharedInstance].queryKey];
    NSLog(@"DAta %@", aSearchString);
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:aSearchString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [NSURLConnection sendAsynchronousRequest:theRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (data) {
            //self.abstractArticle.text = [self parse:data];
            if (_article) {
                _article.sciAbstract = [[ADBPubmedSession sharedInstance] parseAbstract:data];
                [[IPExporter getInstance]updateInfoForObject:_article withBlock:nil];
                [General saveContextAndRoll];
                [self addDataFromArticle];
            }else{
                self.abstractArticle.text = [[ADBPubmedSession sharedInstance] parseAbstract:data];
                //[self addDataFromDownload];
            }
            [self layFrames];
        }else{
            [General noConnection:nil];
        }
    }];
		
}

-(void)goToPubmedArticle{
    NSString *url = [NSString stringWithFormat:@"http://www.ncbi.nlm.nih.gov/pubmed/%@", _article.sciPubmedID?_article.sciPubmedID:[self.data objectAtIndex:4]];
    ADBMasterViewController *see = [[ADBMasterViewController alloc]init];
    see.view = [[UIWebView alloc]initWithFrame:self.view.frame];
    [(UIWebView *)see.view loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [self.navigationController pushViewController:see animated:YES];
}

-(void)goToSearch{
	if ([self.navigationController.viewControllers count]>1) {
		[self.navigationController popViewControllerAnimated:YES];
	}else {
		ADBPubmedSearchViewController *spvc = [[ADBPubmedSearchViewController alloc]init];
		[self.navigationController setViewControllers:[NSArray arrayWithObject:spvc]];
	}

}

-(void)emailLab{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:[NSString stringWithFormat:@"Check out this paper from %@ Magazine", _article.sciSource]];
    NSMutableArray *array = [NSMutableArray array];
    for (ZGroupPerson *person in [[ADBAccountManager sharedInstance]allGroupMembers]) {
        if(person.person.perEmail)[array addObject:person.person.perEmail];
    }
    [picker setToRecipients:[NSArray arrayWithArray:array]];
    
    // Fill out the email body text
    NSString *messageBody = [NSString stringWithFormat:@"email generated with AirLab\n\n%@\n\%@\n<a href='http://www.ncbi.nlm.nih.gov/pubmed/%@'>http://www.ncbi.nlm.nih.gov/pubmed/%@", _article.sciTitle, _article.sciAuthors, _article.sciPubmedID, _article.sciPubmedID];
    [picker setMessageBody:messageBody isHTML:YES];
    
    //picker.navigationBar.barStyle = UIBarStyleBlack; // choose your style, unfortunately, Translucent colors behave quirky.
    picker.navigationBar.tintColor = [UIColor orangeColor];
    picker.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
        {
            
        }
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
            
        default:
        {
            [General showOKAlertWithTitle:@"Email failed" andMessage:nil delegate:self];
            
        }
            
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)addToMyPapers{
	
	NSArray *resultOfFetch = [General searchDataBaseForClass:SCIENTIFICARTICLE_DB_CLASS withTerm:[self.data objectAtIndex:4] inField:@"sciPubmedID" sortBy:@"sciPubmedID" ascending:YES inMOC:self.managedObjectContext];
		
	if ([resultOfFetch count] > 0) {
        [General showOKAlertWithTitle:@"This article is already in your list" andMessage:nil delegate:self];
	}else {
		//ScientificArticle *paper = (ScientificArticle *)[General newObjectOfType:SCIENTIFICARTICLE_DB_CLASS saveContext:NO];
        ScientificArticle *paper = [NSEntityDescription insertNewObjectForEntityForName:SCIENTIFICARTICLE_DB_CLASS inManagedObjectContext:self.managedObjectContext];
		paper.sciTitle = self.titleArticle.text;
		paper.sciAuthors = self.authorsArticle.text;
		paper.sciSource = self.journalArticle.text;
		paper.sciPubDate = self.dateLabelArticle.text;
		paper.sciPubmedID = [self.data objectAtIndex:4];
		paper.sciAbstract = self.abstractArticle.text;
		
        [General saveContextAndRoll];
        [General offlineIdToObject:paper];
        ADBAccountManager *manager = [ADBAccountManager sharedInstance];
        [manager addPersonGroup:[manager currentGroupPerson] toObject:paper];
        
        self.article = paper;
        [self addActions];
	}
}

-(void)shareWithLab{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Do you want to share this paper with your group?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *handler){
    
    }];
    [controller addAction:actionCancel];
    UIAlertAction *actionShare = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *handler){
        _article.sciLabShared = @"1";
        [[IPExporter getInstance]updateInfoForObject:_article withBlock:nil];
        [self addActions];
    }];
    [controller addAction:actionShare];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
