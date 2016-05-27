//
//  ScientificArticle.h
//  AirLab
//
//  Created by Raul Catena on 11/9/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"


@interface ScientificArticle : Object

@property (nonatomic, retain) NSString * sciAbstract;
@property (nonatomic, retain) NSString * sciAuthors;
@property (nonatomic, retain) NSString * sciEPubDate;
@property (nonatomic, retain) NSString * scifullJournalName;
@property (nonatomic, retain) NSString * sciIssue;
@property (nonatomic, retain) NSString * sciLabShared;
@property (nonatomic, retain) NSString * sciLastAuthor;
@property (nonatomic, retain) NSString * sciNlmUniqueID;
@property (nonatomic, retain) NSString * sciPages;
@property (nonatomic, retain) NSString * sciPMID;
@property (nonatomic, retain) NSString * sciPubDate;
@property (nonatomic, retain) NSString * sciPubmedID;
@property (nonatomic, retain) NSString * sciPubTypes;
@property (nonatomic, retain) NSString * sciScientificArticleId;
@property (nonatomic, retain) NSString * sciSource;
@property (nonatomic, retain) NSString * sciTitle;
@property (nonatomic, retain) NSString * sciVol;

@end
