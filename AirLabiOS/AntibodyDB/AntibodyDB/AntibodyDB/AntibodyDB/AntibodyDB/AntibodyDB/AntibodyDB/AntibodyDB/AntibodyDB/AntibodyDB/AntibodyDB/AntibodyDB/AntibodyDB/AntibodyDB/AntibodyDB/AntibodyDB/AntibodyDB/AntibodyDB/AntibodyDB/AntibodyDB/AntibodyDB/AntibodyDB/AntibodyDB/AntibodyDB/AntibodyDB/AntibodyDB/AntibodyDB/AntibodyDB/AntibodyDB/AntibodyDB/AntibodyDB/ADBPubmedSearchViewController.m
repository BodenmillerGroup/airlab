//
//  ADBPubmedSearchViewController.m
//  LabPad
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBPubmedSearchViewController.h"
#import "ADBSeePaperViewController.h"
#import "ADBArticleCellViewController.h"
#import "ADBPubmedSession.h"
#import "ScientificArticle.h"
#import "TFHpple.h"
#import "HTMLParser.h"
#import "HTMLNode.h"

#define FONT_SIZE 19.0f
#define CELL_CONTENT_WIDTH 550.0f
#define CELL_CONTENT_MARGIN 10.0f


@implementation ADBPubmedSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Search for Scientific Papers";
	searchingIDs = NO;
	searching = NO;
}


#pragma mark tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.titlesOfPapers count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 111;
}


- (ADBArticleCellViewController *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Dequeue or if necessary create a RecipeTableViewCell, then set its recipe to the recipe for the current row.
    static NSString *ReagentCellIdentifier = @"PaperTableViewCellID";
    
	//Here put custom cells
    ADBArticleCellViewController *cell = (ADBArticleCellViewController *)[self.tableView dequeueReusableCellWithIdentifier:ReagentCellIdentifier];
    if (!cell) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ADBArticleCellViewController" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        [General iPhoneBlock:nil iPadBlock:^{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }];
    }

    cell.titlePaperLabel.text = [self.titlesOfPapers objectAtIndex:indexPath.row];
    cell.journal.text = [self.journals objectAtIndex:indexPath.row];
    
    NSMutableString *authorsString = [NSMutableString stringWithFormat:@""];
    NSMutableArray *authorsArray = [(NSArray *)[self.authors objectAtIndex:indexPath.row]mutableCopy];
    
    while (authorsArray.count > 0) {
        [authorsString appendFormat:@"%@", [authorsArray firstObject]];
        [authorsArray removeObjectAtIndex:0];
        if (authorsArray.count !=0) {
            [authorsString appendFormat:@", "];
        }
    }
    cell.authors.text = authorsString;
    cell.date.text = [self.dates objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ADBSeePaperViewController *advc = [[ADBSeePaperViewController alloc]init];
    
    NSString *theTitle = [self.titlesOfPapers objectAtIndex:indexPath.row];
    
    NSMutableString *theAuthors = [NSMutableString string];
    NSArray *authorsInPaper = [self.authors objectAtIndex:indexPath.row];
    
    if ([authorsInPaper count]>1) {
        int i=0;
        for (i=0; i<([authorsInPaper count]-1); i++) {
            [theAuthors appendFormat:@"%@, ", [authorsInPaper objectAtIndex:i]];
        }
        [theAuthors appendFormat:@"and %@", [authorsInPaper lastObject]];
    }else {
        theAuthors = [authorsInPaper lastObject];
    }
    
    NSString *theDate = [self.dates objectAtIndex:indexPath.row];
    NSString *theJournal = [self.journals objectAtIndex:indexPath.row];
    NSString *theID = [self.pubmedIDsArray objectAtIndex:indexPath.row];
    advc.data = [NSArray arrayWithObjects:theTitle, theAuthors, theDate, theJournal, theID, nil];
    [self.navigationController pushViewController:advc animated:YES];
}

#pragma mark query
-(void)searchButton{
	if (!searching) {
		if ([self.searchBox.text length]>0) {
			[self searchPubmed:self.searchBox.text];
            [self.searchBox resignFirstResponder];
			searching = YES;
		}else {
            [General showOKAlertWithTitle:@"Enter search terms" andMessage:nil];
		}
	}else{
		searching = NO;
    }
}

-(void)goToAdvancedSearch{
	AdvancedSearchPaperViewController *aspVC = [[AdvancedSearchPaperViewController alloc]init];
    aspVC.delegate = self;
	//UINavigationController *navcon = [[UINavigationController alloc] initWithRootViewController:aspVC];
	//navcon.modalPresentationStyle = UIModalPresentationFormSheet;
    [self showModalWithCancelButton:aspVC fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
}

-(void)performAdvancedSearchWithTerm:(NSString *)term{
    if (term){
        self.searchBox.text = term;
        [self searchPubmed:term];
    }
    [self dismissModalOrPopover];
}

-(void)searchPubmed:(NSString *)searchString{
    [General startBarSpinner];
	searchingIDs = YES;
	NSString *modifiedString = [searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    _searchBox.userInteractionEnabled = NO;
    
    NSMutableURLRequest *request =[General callToGetAPI:[NSString stringWithFormat:@"http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=%@&retmax=1000&usehistory=y", modifiedString]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (!error) {
            NSArray *dataArray = [[ADBPubmedSession sharedInstance] parseQuery:data];
			[self getSummaries:dataArray];
        }else{
            _searchBox.userInteractionEnabled = YES;
            [General stopBarSpinner];
        }
    }];
}

-(void)getSummaries:(NSArray *)arrayOfIDs{
	NSMutableString *searchString = [NSMutableString string];
	for (NSString *stringID in arrayOfIDs) {
		[searchString appendFormat:@"%@,", stringID];
	}
	NSString *modifiedString = [searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSMutableURLRequest *request =[General callToGetAPI:[NSString stringWithFormat:@"http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&term=&id=%@", modifiedString]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (!error) {
            NSArray *results = [[ADBPubmedSession sharedInstance]parserTitles:data];
            self.titlesOfPapers = [results objectAtIndex:0];
			self.journals = [results objectAtIndex:1];
			self.authors = [results objectAtIndex:2];
			self.dates = [results objectAtIndex:3];
			self.pubmedIDsArray = [results objectAtIndex:4];
            [General stopBarSpinner];
        }else{
            [General stopBarSpinner];
        }
        
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewRowAnimationTop animated:YES];
        _searchBox.userInteractionEnabled = YES;
    }];
}

@end
