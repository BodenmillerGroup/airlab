//
//  ADBShopParsers.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/10/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBShopParsers.h"
#import "HTMLNode.h"
#import "HTMLParser.h"

@implementation ADBShopParsers

-(NSArray *)parseData:(NSData *)data{//Array of NSManagedObjects Papers, quiza solo al anadir
	NSError *error = nil;
	HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&error];
	
	if (error)[General logError:error];
	
	HTMLNode *body = [parser body];
	
	NSArray *groupmodule = [body findChildrenOfClass:@"searchResultGroup module"];
	HTMLNode *resultsByCategory = [groupmodule objectAtIndex:0];
	NSArray *uls = [resultsByCategory findChildTags:@"ul"];
	NSMutableArray *cats = [NSMutableArray array];
	NSMutableArray *links = [NSMutableArray array];
	for (HTMLNode *ul in uls) {
		NSArray *lisTags = [ul findChildTags:@"li"];
		for (HTMLNode *liTag in lisTags) {
			NSString *cat = [[[liTag findChildTags:@"a"]lastObject]contents];
			NSString *link = [[[liTag findChildTags:@"a"]lastObject]getAttributeNamed:@"href"];
			[cats addObject:cat];
			[links addObject:link];
		}
	}
	
	NSArray *output = [NSArray arrayWithObjects:cats, links, nil];
	return output;
}

-(NSArray *)parseDataForProduct:(NSData *)data{//Array of NSManagedObjects Papers, quiza solo al anadir
	NSError *error = nil;
	HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&error];
	
	if (error)[General logError:error];
	
	HTMLNode *body = [parser body];
	
	HTMLNode *groupmodule = [body findChildWithAttribute:@"class" matchingName:@"product" allowPartial:NO];
    NSArray *output = nil;
    if (groupmodule) {
        NSArray *uls = [groupmodule findChildTags:@"a"];
        NSMutableArray *cats = [NSMutableArray array];
        NSMutableArray *links = [NSMutableArray array];
        int x = 0;
        for (HTMLNode *ul in uls) {
            if (x>0)break;
            x++;
            NSString *cat = [ul contents];
            NSString *link = [ul getAttributeNamed:@"href"];
            [cats addObject:cat];
            [links addObject:link];
        }
        output = [NSArray arrayWithObjects:cats, links, nil];
    }
    
    
	return output;
}

-(NSArray *)parseCategoryData:(NSData *)data{
	NSError *error = nil;
	HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&error];
	
	if (error)[General logError:error];
	
	HTMLNode *bodyNode = [parser body];
	
	NSArray *groupmodule = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"productRow" allowPartial:YES];NSLog(@"Number of entries %lu", (unsigned long)[groupmodule count]);
	//NSArray *groupmodule = [bodyNode findChildrenOfClass:@"productRow module alternate hproduct standard"];
	//NSArray *groupmodule = [bodyNode findChildrenOfClass:@"productRow standard"];NSLog(@"Roducts %i", [groupmodule count]);
	
	NSMutableArray *allProducts = [NSMutableArray array];
	NSMutableArray *referencias = [NSMutableArray array];
	NSMutableArray *allLinks = [NSMutableArray array];
	for (HTMLNode *product in groupmodule) {
		NSArray *aes = [product findChildTags:@"a"];
		if ([aes count]>0) {
			int x = 0;
			for (HTMLNode *nameOfProduct in aes){
				NSString *nameOfProductString = [nameOfProduct contents];
				if ([nameOfProductString length]>0 && x == 0) {
					[allLinks addObject:[nameOfProduct getAttributeNamed:@"href"]];
					[allProducts addObject:nameOfProductString];
					
					NSString *stringForManuf = [nameOfProduct getAttributeNamed:@"title"];
					if ([stringForManuf length]>0) {
						NSArray *manufacturerArray = [stringForManuf componentsSeparatedByString:@"from "];
						NSString *manufReference = [manufacturerArray lastObject];
						if ([manufReference length]>0) {
							[referencias addObject:manufReference];
						}
					}else {
						[referencias addObject:@" "];
					}
                    
                    
					x++;
				}
			}
		}
	}
	
	NSArray *result = [NSArray arrayWithObjects:allProducts, referencias, allLinks, nil];
	return result;
}

-(NSArray *)parseProduct:(NSData *)data{//Array of NSManagedObjects Papers, quiza solo al anadir
	
	NSError *error = nil;
	HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&error];
	
	if (error)[General logError:error];
	
	HTMLNode *bodyNode = [parser body];
	
	NSArray *groupmodule = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"productDetailUL" allowPartial:YES];NSLog(@"Roducts %@", [[groupmodule lastObject]rawContents]);
	NSArray *lis = [[groupmodule lastObject] findChildTags:@"li"];NSLog(@"Lis %lu", (unsigned long)[lis count]);
	
	NSMutableArray *theTags = [NSMutableArray array];
	NSMutableArray *theValues = [NSMutableArray array];
    //Add if lis?
	for (HTMLNode *li in lis) {
		NSArray *pair = [li findChildTags:@"span"];
		if ([pair count] > 1) {
			if ([[[pair objectAtIndex:0]contents]length]>0) {
				[theTags addObject:[[pair objectAtIndex:0]contents]];
			}else {
				[theTags addObject:@" "];//Is it possible to add NULL here?
			}
			if ([[[pair objectAtIndex:1]rawContents]length]>0) {
				NSArray *aArray = [[pair objectAtIndex:1]findChildTags:@"a"];
				if ([aArray count]>0) {
					[theValues addObject:[[aArray lastObject] contents]];
				}else{
					[theValues addObject:[[pair objectAtIndex:1]contents]];
				}
			}else {
				[theValues addObject:@" "];
			}
		}
	}
    
    NSArray *link = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"clickthrough lin" allowPartial:YES];
    if (link.count > 0) {
        [theTags addObject:@"More information"];
        HTMLNode *linker = [link objectAtIndex:0];
        [theValues addObject:[linker getAttributeNamed:@"href"]];
    }
    
	NSMutableDictionary *theDict = [NSMutableDictionary dictionary];
	int x = 0;
	for (x=0; x<[theTags count]; x++) {
		[theDict setValue:[theValues objectAtIndex:x] forKey:[theTags objectAtIndex:x]];
	}
	NSArray *result = [NSArray arrayWithObjects:theTags, theValues, theDict, nil];
	return result;
}

@end
