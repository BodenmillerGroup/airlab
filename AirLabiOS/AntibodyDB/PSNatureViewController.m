//
//  PSNatureViewController.m
//  iScientist
//
//  Created by Raul Catena on 10/20/13.
//  Copyright (c) 2013 Raul Catena. All rights reserved.
//

#import "PSNatureViewController.h"
#import "HTMLParser.h"

@interface PSNatureViewController (){
    int previous;
    int selectedPaper;
}

@end

@implementation PSNatureViewController

@synthesize newsArray = _newsArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Science Digest";
    journal = 0;
    [self searchFeed:journal];
}

-(void)journalChanged:(UISegmentedControl *)sender{
    previous = journal;
    journal = (int)sender.selectedSegmentIndex;
    [self searchFeed:journal];
}

-(void)searchFeed:(int)journalCode{
	
    NSMutableArray *array  = [NSMutableArray array];
    switch (journalCode) {
        case 0:
            [array addObject:[NSString stringWithFormat:@"http://feeds.nature.com/nature/rss/current"]];
            break;
        case 1:
            [array addObject:[NSString stringWithFormat:@"http://www.sciencemag.org/rss/current.xml"]];
            [array addObject:@"http://www.sciencemag.org/rss/news.xml"];
            [array addObject:@"http://www.sciencemag.org/rss/express.xml"];
            [array addObject:@"http://www.sciencemag.org/rss/twis.xml"];
            [array addObject:@"http://www.sciencemag.org/rss/ec.xml"];
            break;
        case 2:
            [array addObject:[NSString stringWithFormat:@"http://www.pnas.org/rss/current.xml"]];
            break;
        case 3:
            [array addObject:@"http://www.cell.com/cell/inpress.rss"];
            [array addObject:@"http://www.cell.com/cell/current.rss"];
            break;
            
        case 4:
            [array addObject:@"http://feeds.nature.com/nmeth/rss/current"];
            [array addObject:@"http://feeds.nature.com/nmeth/rss/aop"];
        default:
            break;
    }
	
    for (NSString *aSearchString in array) {
        NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:aSearchString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        
        [NSURLConnection sendAsynchronousRequest:theRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response_, NSData *data_, NSError *error_){
            if (!error_) {
                [self extractData:data_];
            }
        }];
    }
}

-(void)extractData:(NSData *)data{//Array of NSManagedObjects Papers, quiza solo al anadir
	//NSLog(@"Data is %@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    if(journal == 0){
        HTMLParser *parser = [[HTMLParser alloc]initWithData:data error:nil];
        HTMLNode *body = [parser body];
        NSArray *list = [body findChildTags:@"item"];
        
        NSMutableArray *array = [NSMutableArray array];
        
        for (HTMLNode *item in list) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            if([[[item findChildTags:@"title"]lastObject] contents])[dict setValue:[[[item findChildTags:@"title"]lastObject] contents] forKey:@"Title"];
            if([[[item findChildTags:@"description"]lastObject] contents])[dict setValue:[[[item findChildTags:@"description"]lastObject] contents] forKey:@"Description"];
            if([[[item findChildTags:@"url"]lastObject] contents])[dict setValue:[[[item findChildTags:@"url"]lastObject] contents] forKey:@"Url"];
            
            [array addObject:dict];
            
        }
        
        self.newsArray = [NSArray arrayWithArray:array];
        [self.tableView reloadData];
    }else if(journal == 1){
        HTMLParser *parser = [[HTMLParser alloc]initWithData:data error:nil];
        HTMLNode *body = [parser body];
        NSArray *list = [body findChildTags:@"item"];
        NSMutableArray *array = [NSMutableArray array];
        
        for (HTMLNode *item in list) {
            //NSLog(@"item %@", item.rawContents);
            NSString *rawContents = [item rawContents];
            NSArray *link = [rawContents componentsSeparatedByString:@"<link>"];
            NSString *linkString = link.lastObject;
            NSArray *trimLink = [linkString componentsSeparatedByString:@"<date>"];
            linkString = [trimLink objectAtIndex:0];
            
            NSMutableDictionary *dict = [ NSMutableDictionary dictionary];
            if([[[item findChildTags:@"title"]lastObject] contents])[dict setValue:[[[item findChildTags:@"title"]lastObject] contents] forKey:@"Title"];
            if([[[item findChildTags:@"section"]lastObject] contents])[dict setValue:[[[item findChildTags:@"section"]lastObject] contents] forKey:@"Description"];
            if(linkString)[dict setValue:linkString forKey:@"Url"];
            
            [array addObject:dict];
        }
        
        if(previous != journal){
            previous = journal;
            self.newsArray = [NSArray arrayWithArray:array];
        }else{
            NSMutableArray *arrayMut = [NSMutableArray arrayWithArray:_newsArray];
            [arrayMut addObjectsFromArray:array];
            self.newsArray = [NSArray arrayWithArray:arrayMut];
        }
        [self.tableView reloadData];
    }else if(journal == 2){
        NSArray *list = [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]componentsSeparatedByString:@"<item"];
        
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *item in list) {
            //NSLog(@"Data is %@", item);
            
            NSMutableDictionary *dict = [ NSMutableDictionary dictionary];
            
            //Title
            NSArray *subarray = [item componentsSeparatedByString:@"<title>"];
            NSString *title = [subarray lastObject];
            NSArray *subsubarray = [title componentsSeparatedByString:@"["];
            if (subsubarray.count > 2) {
                [dict setValue:[subsubarray objectAtIndex:2] forKey:@"Title"];
            }
            //Description
            NSArray *subdesc = [item componentsSeparatedByString:@"<description>"];
            NSString *description = [subdesc lastObject];
            NSArray *subsubdesc = [description componentsSeparatedByString:@"["];
            if (subsubdesc.count > 2) {
                [dict setValue:[subsubdesc objectAtIndex:2] forKey:@"Description"];
            }
            //Link
            NSArray *sublink = [item componentsSeparatedByString:@"<link>"];
            NSString *link = [sublink lastObject];
            NSArray *subsublink = [link componentsSeparatedByString:@"</link>"];
            if (subsublink.count > 0) {
                [dict setValue:[subsublink objectAtIndex:0] forKey:@"Url"];
            }
            //NSLog(@"Array info %@", arrayInfo);

            if(dict.allKeys.count > 1)
            [array addObject:dict];
            
        }
        
        self.newsArray = [NSArray arrayWithArray:array];
        [self.tableView reloadData];
    }
    else if(journal == 3){
        HTMLParser *parser = [[HTMLParser alloc]initWithData:data error:nil];
        HTMLNode *body = [parser body];
        NSArray *list = [body findChildTags:@"item"];
        
        NSMutableArray *array = [NSMutableArray array];
        
        for (HTMLNode *item in list) {
    
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            if([[[item findChildTags:@"title"]lastObject] contents])[dict setValue:[[[item findChildTags:@"title"]lastObject] contents] forKey:@"Title"];
            NSArray *preLink = [[item rawContents]componentsSeparatedByString:@"</link>"];
            NSArray *postLink = [[preLink firstObject]componentsSeparatedByString:@"<link>"];
            [dict setValue:postLink.lastObject forKey:@"Url"];
            if([[[item findChildTags:@"description"]lastObject] contents])[dict setValue:[[[item findChildTags:@"description"]lastObject] contents] forKey:@"Description"];
            [array addObject:dict];
            
        }
        if(previous != journal){
                previous = journal;
            self.newsArray = [NSArray arrayWithArray:array];
        }else{
            NSMutableArray *arrayMut = [NSMutableArray arrayWithArray:_newsArray];
            [arrayMut addObjectsFromArray:array];
            self.newsArray = [NSArray arrayWithArray:arrayMut];
        }
        [self.tableView reloadData];
    }else if(journal == 4){
        HTMLParser *parser = [[HTMLParser alloc]initWithData:data error:nil];
        HTMLNode *body = [parser body];
        NSArray *list = [body findChildTags:@"item"];
        
        NSMutableArray *array = [NSMutableArray array];
        
        for (HTMLNode *item in list) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            if([[[item findChildTags:@"title"]lastObject] contents])[dict setValue:[[[item findChildTags:@"title"]lastObject] contents] forKey:@"Title"];
            if([[[item findChildTags:@"description"]lastObject] contents])[dict setValue:[[[item findChildTags:@"description"]lastObject] contents] forKey:@"Description"];
            if([[[item findChildTags:@"url"]lastObject] contents])[dict setValue:[[[item findChildTags:@"url"]lastObject] contents] forKey:@"Url"];
            
            [array addObject:dict];
            
        }
        
        if(previous != journal){
            previous = journal;
            self.newsArray = [NSArray arrayWithArray:array];
        }else{
            NSMutableArray *arrayMut = [NSMutableArray arrayWithArray:_newsArray];
            [arrayMut addObjectsFromArray:array];
            self.newsArray = [NSArray arrayWithArray:arrayMut];
        }
        [self.tableView reloadData];
    }
}

#pragma mark tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([[_newsArray objectAtIndex:indexPath.row]valueForKey:@"Description"] ){
        float titleHeight = [General calculateHeightedLabelForLabelWithText:[[_newsArray objectAtIndex:indexPath.row]valueForKey:@"Title"]
                                                                   andWidth:self.view.bounds.size.width - 32 andFontSize:22];
        
        return MAX([General calculateHeightedLabelForLabelWithText:[[_newsArray objectAtIndex:indexPath.row]valueForKey:@"Description"] andWidth:self.view.bounds.size.width - 32 andFontSize:18] + 30 + titleHeight, 60);
    }
    else return 60.0f;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 0;
	if (_newsArray) {
        rows = _newsArray.count;
    }
    NSLog(@"Number %lu", rows);
	return rows;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    for (UIView *viewi in cell.contentView.subviews) {
        [viewi removeFromSuperview];
    }
    
    float titleHeight = [General calculateHeightedLabelForLabelWithText:[[_newsArray objectAtIndex:indexPath.row]valueForKey:@"Title"]
                                                                         andWidth:self.view.bounds.size.width - 32 andFontSize:22];
    
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(16, 6, self.view.bounds.size.width - 32, titleHeight)];

    
    title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    title.lineBreakMode = NSLineBreakByWordWrapping;
    title.textAlignment = NSTextAlignmentJustified;
    title.font = [UIFont systemFontOfSize:22];
    title.numberOfLines = 0;
    title.textColor = [UIColor orangeColor];
    title.text = [[_newsArray objectAtIndex:indexPath.row]valueForKey:@"Title"];
    if (journal == 1) {
        title.text = [title.text stringByReplacingOccurrencesOfString:@"[" withString:@""];
        title.text = [title.text stringByReplacingOccurrencesOfString:@"]" withString:@" - "];
    }
    [cell.contentView addSubview:title];
    
    
    if ([(NSArray *)[_newsArray objectAtIndex:indexPath.row]count] > 1) {
        CGRect frame = CGRectMake(16, titleHeight + 12, self.view.bounds.size.width - 32, [General calculateHeightedLabelForLabelWithText:[[_newsArray objectAtIndex:indexPath.row]valueForKey:@"Description"]  andWidth:title.bounds.size.width andFontSize:18]);

        UILabel *subtitle = [[UILabel alloc]initWithFrame:frame];
        subtitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        subtitle.lineBreakMode = NSLineBreakByWordWrapping;
        subtitle.textAlignment = NSTextAlignmentJustified;
        subtitle.numberOfLines = 0;
        subtitle.font = [UIFont systemFontOfSize:18];
        subtitle.textColor = [UIColor darkGrayColor];
        

        subtitle.text = [[[[_newsArray objectAtIndex:indexPath.row]valueForKey:@"Description"]componentsSeparatedByString:@"...]]></des"]firstObject];
        [cell.contentView addSubview:subtitle];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ReagentCellIdentifier = @"CellID";
	
	UITableViewCell *cell = nil;
    cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:ReagentCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ReagentCellIdentifier];
    }
	[self configureCell:cell atIndexPath:indexPath];
		
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedPaper = (int)indexPath.row;
    ADBMasterViewController *viewController = [[ADBMasterViewController alloc]init];
    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sendToFriend:)];
    UIWebView *webView = [[UIWebView alloc]initWithFrame:self.navigationController.view.frame];
    NSURLRequest *request;
    if (journal == 1 || journal == 3){
        [viewController.view addSubview:webView];
        NSString *url = [[_newsArray objectAtIndex:indexPath.row]valueForKey:@"Url"];
        NSArray *comps = [url componentsSeparatedByString:@"?rss"];
        url = [comps objectAtIndex:0];
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    }else{
        [viewController.view addSubview:webView];
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[_newsArray objectAtIndex:indexPath.row]valueForKey:@"Url"]]];
    }
     NSLog(@"URL is ____%@", request.URL.absoluteString);
    [webView loadRequest:request];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)emailLab{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:[NSString stringWithFormat:@"Check out this paper from %@ Magazine", [_journalSegments titleForSegmentAtIndex:journal]]];
    NSMutableArray *array = [NSMutableArray array];
    for (ZGroupPerson *person in [[ADBAccountManager sharedInstance]allGroupMembers]) {
        if(person.person.perEmail)[array addObject:person.person.perEmail];
    }
    [picker setToRecipients:[NSArray arrayWithArray:array]];
    
    // Fill out the email body text
    NSString *messageBody = [NSString stringWithFormat:@"email generated with AirLab\n\n%@", [[_newsArray objectAtIndex:selectedPaper]valueForKey:@"Url"]];
    [picker setMessageBody:messageBody isHTML:YES];
    
    //picker.navigationBar.barStyle = UIBarStyleBlack; // choose your style, unfortunately, Translucent colors behave quirky.
    picker.navigationBar.tintColor = [UIColor orangeColor];
    picker.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)sendToFriend:(UIBarButtonItem *)sender{
    if ([UIAlertController class])
    {
        NSLog(@"Can do like this");
    }
    else {
        NSLog(@"Can NOT do like this");
        //println("UIAlertController can NOT be instantiated")
        
        //make and use a UIAlertView
    }
    NSString *url = [[_newsArray objectAtIndex:selectedPaper]valueForKey:@"Url"];
    NSArray *comps = [url componentsSeparatedByString:@"?rss"];
    url = [comps objectAtIndex:0];
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Share..."
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *emailActionInAlert = [UIAlertAction
                                          actionWithTitle:@"Email lab"
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction *action)
                                          {
                                              [self emailLab];
                                          }];
    [alertController addAction:emailActionInAlert];
    
    UIAlertAction *twitterActionInAlert = [UIAlertAction
                                         actionWithTitle:@"Twitter"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action)
                                         {
                                             [General sendTweet:@"#AirLab" withImage:nil andURL:url fromVC:self];
                                         }];
    [alertController addAction:twitterActionInAlert];
    
    UIAlertAction *facebookActionInAlert = [UIAlertAction
                                         actionWithTitle:@"Facebook"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action)
                                         {
                                             [General sendFB:@"#AirLab" withImage:nil andURL:url fromVC:self];
                                         }];
    [alertController addAction:facebookActionInAlert];
    alertController.popoverPresentationController.sourceView = [[UIApplication sharedApplication]keyWindow].rootViewController.view;
    alertController.popoverPresentationController.barButtonItem = sender;
    alertController.view.tintColor = [UIColor orangeColor];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    return;
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

@end
