    //
//  AdvancedSearchPaperViewController.m
//  LabPad
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//
#import "ADBPubmedDetailViewController.h"
#import "ADBPubmedSearchViewController.h"


@interface ADBPubmedDetailViewController()
@property (nonatomic, strong) NSMutableArray *terms;
@end

@implementation ADBPubmedDetailViewController

#pragma mark pickerView



- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
}

-(NSString *)composeAdvancedTerm{
    NSMutableString *query = [NSMutableString string];
    if (_terms.count>0) {
        for (int i=0; i<_terms.count-1; i++) {
            NSString *key = [[[_terms objectAtIndex:i] allKeys]lastObject];
            NSString *value = [[[_terms objectAtIndex:i] allValues]lastObject];
            if ([key isEqual:@"All Fields"]) {
                [query appendFormat:@"%@ AND ", value];
            }else{
                [query appendFormat:@"%@[%@] AND ", value, key];
            }
        }
    }
    return query;
}

-(void)done{
	[self.delegate advancedSearch:[self composeAdvancedTerm]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _terms.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *stringCell = @"AdvancedTerm";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:stringCell];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCell];
    }
    NSDictionary *term = [_terms objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ in %@", [term valueForKey:term.allKeys.lastObject], term.allKeys.lastObject];
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [_terms removeObjectAtIndex:indexPath.row];
    }];
    [array addObject:deleteAction];
    return [NSArray arrayWithArray:array];
}

-(IBAction)addTerms{
	if (_terms == nil) {
		_terms = [NSMutableArray array];
	}
	if ([_searchField.text length]>0) {
		[self.terms addObject:[NSDictionary dictionaryWithObject:_searchField.text forKey:[_typeOfTerm titleForSegmentAtIndex:_typeOfTerm.selectedSegmentIndex]]];
	}
    [self.tableView reloadData];
	self.searchField.text = nil;
}

@end
