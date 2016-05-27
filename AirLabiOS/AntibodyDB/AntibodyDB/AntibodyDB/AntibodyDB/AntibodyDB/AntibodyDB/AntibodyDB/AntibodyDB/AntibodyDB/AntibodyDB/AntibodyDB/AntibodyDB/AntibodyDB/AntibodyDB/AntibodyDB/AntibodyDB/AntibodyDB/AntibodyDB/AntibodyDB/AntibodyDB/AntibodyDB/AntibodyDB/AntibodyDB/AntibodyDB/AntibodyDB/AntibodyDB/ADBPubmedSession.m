//
//  ADBPubmedSession.m
//  AirLab
//
//  Created by Raul Catena on 10/26/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBPubmedSession.h"
#import "HTMLParser.h"


@implementation ADBPubmedSession

@synthesize webEnv = _webEnv, queryKey = _queryKey;

+(ADBPubmedSession *)sharedInstance{
    static dispatch_once_t pred = 0;
    __strong static ADBPubmedSession* _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

-(NSString *)getWebEnv{
    if (_webEnv) {
        [self reloadSession];
    }
    return _webEnv;
}

-(void)reloadSession{
    NSMutableURLRequest *request =[General callToGetAPI:@"http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=raul+catena&retmax=1000&usehistory=y"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (!error) {
            NSString *stringified = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSError *error2;
            NSString *toHtml = [stringified stringByReplacingOccurrencesOfString:@"<eSummaryResult>" withString:@"<html><head></head><body>"];
            NSString *toHtmlFinal = [toHtml stringByReplacingOccurrencesOfString:@"</eSummaryResult>" withString:@"</body></html>"];
            HTMLParser *parser = [[HTMLParser alloc] initWithString:toHtmlFinal error:&error2];
            
            if(error2)[General logError:error];
            
            HTMLNode *htmlNode = [parser html];
            
            NSArray *body = [htmlNode findChildTags:@"body"];//Each article NCBI summary
            HTMLNode *bodyNode = [body lastObject];
            
            NSArray *queryKeyArray = [bodyNode findChildTags:@"querykey"];
            self.queryKey = [[queryKeyArray lastObject]contents];
            NSArray *webenvArray = [bodyNode findChildTags:@"webenv"];
            self.webEnv = [[webenvArray lastObject]contents];
        }
    }];
}

-(NSString *)getQueryKey{
    if (!_queryKey) {
        [self reloadSession];
    }
    return _queryKey;
}

-(NSString *)parseAbstract:(NSData *)data{
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *parsedOne = [dataString stringByReplacingOccurrencesOfString:@"<PubmedArticleSet>" withString:@"<html><head></head><body>"];
    NSString *curated = [parsedOne stringByReplacingOccurrencesOfString:@"</PubmedArticleSet>" withString:@"</body></html>"];
    
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:curated error:&error];
    if (error)[General logError:error];
    
    HTMLNode *htmlNode = [parser html];
    
    NSArray *body = [htmlNode findChildTags:@"body"];//Each article NCBI summary
    HTMLNode *bodyNode = [body lastObject];
    
    NSArray *theArray = [bodyNode findChildTags:@"abstracttext"];
    NSMutableString *parsed = [NSMutableString string];
    for (HTMLNode *node in theArray) {
        [parsed appendFormat:@"%@ ", [node contents]];
    }
    
    return [NSString stringWithString:parsed];
}

-(NSArray *)parserTitles:(NSData *)data{
    NSString *stringified = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSString *toHtml = [stringified stringByReplacingOccurrencesOfString:@"<eSummaryResult>" withString:@"<html><head></head><body>"];
    NSString *toHtmlFinal = [toHtml stringByReplacingOccurrencesOfString:@"</eSummaryResult>" withString:@"</body></html>"];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:toHtmlFinal error:&error];
    
    if(error)[General logError:error];
    
    HTMLNode *htmlNode = [parser html];
    
    NSArray *body = [htmlNode findChildTags:@"body"];//Each article NCBI summary
    HTMLNode *bodyNode = [body lastObject];
    
    NSMutableArray *titles = [[NSMutableArray alloc]init];
    NSMutableArray *journals = [[NSMutableArray alloc]init];
    NSMutableArray *authors = [[NSMutableArray alloc]init];
    NSMutableArray *dates = [[NSMutableArray alloc]init];
    NSMutableArray *pubmedIDs = [[NSMutableArray alloc]init];
    
    NSArray *docs = [bodyNode findChildTags:@"docsum"];
    
    for (HTMLNode *node in docs) {
        NSString *title = [[node findChildWithAttribute:@"name" matchingName:@"Title" allowPartial:NO] contents];
        [titles addObject:title];
        NSString *journal = [[node findChildWithAttribute:@"name" matchingName:@"FullJournalName" allowPartial:NO] contents];
        [journals addObject:journal];
        NSString *date = [[node findChildWithAttribute:@"name" matchingName:@"PubDate" allowPartial:NO] contents];
        [dates addObject:date];
        NSMutableArray *authorsPerPaper = [NSMutableArray array];
        HTMLNode *authorsPrimary = [node findChildWithAttribute:@"name" matchingName:@"AuthorList" allowPartial:NO];
        NSArray *authorsArray = [authorsPrimary findChildTags:@"item"];
        for(HTMLNode *authorNode in authorsArray){
            [authorsPerPaper addObject:[authorNode contents]];
        }
        [authors addObject:authorsPerPaper];
        NSString *anID = [[node findChildWithAttribute:@"name" matchingName:@"pubmed" allowPartial:NO] contents];
        [pubmedIDs addObject:anID];
    }
    return @[titles, journals, authors, dates, pubmedIDs];
}

-(NSArray *)parseQuery:(NSData *)data{//Saca los ID tras esearch
    
    NSString *stringified = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSError *error;
    NSString *toHtml = [stringified stringByReplacingOccurrencesOfString:@"<eSummaryResult>" withString:@"<html><head></head><body>"];
    NSString *toHtmlFinal = [toHtml stringByReplacingOccurrencesOfString:@"</eSummaryResult>" withString:@"</body></html>"];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:toHtmlFinal error:&error];
    
    if(error)[General logError:error];
    
    HTMLNode *htmlNode = [parser html];
    
    NSArray *body = [htmlNode findChildTags:@"body"];//Each article NCBI summary
    HTMLNode *bodyNode = [body lastObject];
    
    NSMutableArray *colectingIDs = [[NSMutableArray alloc]init];
    
    NSArray *idListWrapped = [bodyNode findChildTags:@"idlist"];
    HTMLNode *idList = [idListWrapped lastObject];
    NSArray *allIDs = [idList findChildTags:@"id"];
    
    for (HTMLNode *node in allIDs) {
        NSString *aTitle = [node contents];
        [colectingIDs addObject:aTitle];
    }
    
    NSArray *queryKeyArray = [bodyNode findChildTags:@"querykey"];
    [ADBPubmedSession sharedInstance].queryKey = [[queryKeyArray lastObject]contents];
    NSArray *webenvArray = [bodyNode findChildTags:@"webenv"];
    [ADBPubmedSession sharedInstance].webEnv = [[webenvArray lastObject]contents];
    
    return colectingIDs;
    
}

@end
