//
//  ADBDefineApplicationsViewController.m
//  AirLab
//
//  Created by Raul Catena on 2/10/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import "ADBDefineApplicationsViewController.h"

@interface ADBDefineApplicationsViewController ()

@property (nonatomic, strong) NSMutableArray *arrayOfSegms;
@property (nonatomic, strong) Clone *clone;
@property (nonatomic, strong) NSMutableDictionary *model;

@end

@implementation ADBDefineApplicationsViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andClone:(Clone *)clone{
    self = [self initWithNibName:nil bundle:nibBundleOrNil];
    if (self) {
        self.clone = clone;
        self.model = [[General jsonStringToObject:clone.cloApplication]mutableCopy];
        if (!_model) {
            self.model = [NSMutableDictionary dictionaryWithCapacity:5];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTheTableviewWithStyle:UITableViewStylePlain];
    self.title = [NSString stringWithFormat:@"%@ %@", _clone.cloName, _clone.protein.proName];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
}

-(void)done{
    for (UISegmentedControl *segm in _arrayOfSegms) {
        if (segm.selectedSegmentIndex >= 0) {
            [_model setObject:[NSNumber numberWithBool:(BOOL)segm.selectedSegmentIndex] forKey:[NSString stringWithFormat:@"%i", segm.tag]];
        }
    }
    if(!_clone)[self.delegate doneDefiningApplicationsPreClone:[General jsonObjectToString:[NSDictionary dictionaryWithDictionary:_model]]];
    NSString *result = [General jsonObjectToString:[NSDictionary dictionaryWithDictionary:_model]];
    self.clone.cloApplication = result;
    if(_clone)
        [self.delegate doneDefiningApplicationsForClone:self.clone];
    else
        [self.delegate doneDefiningApplicationsPreClone:result];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    UISegmentedControl *segm = [[UISegmentedControl alloc]initWithItems:@[@"NO", @"YES"]];
    segm.selectedSegmentIndex = -1;
    segm.tag = indexPath.section;
    [segm addTarget:self action:@selector(valueSelected:) forControlEvents:UIControlEventValueChanged];
    if ([_model valueForKey:[NSString stringWithFormat:@"%i", indexPath.section]]) {
        NSLog(@"Model %@ at %i", [_model valueForKey:[NSString stringWithFormat:@"%i", indexPath.section]], indexPath.section);
        segm.selectedSegmentIndex = [[_model valueForKey:[NSString stringWithFormat:@"%i", indexPath.section]]intValue];
    }
    if (!_arrayOfSegms) {
        _arrayOfSegms = [NSMutableArray array];
    }
    [_arrayOfSegms addObject:segm];
    segm.frame = CGRectMake(5, 5, self.view.bounds.size.width - 50, cell.bounds.size.height -  10);
    segm.tintColor = [UIColor orangeColor];
    
    UIButton *erase = [UIButton buttonWithType:UIButtonTypeCustom];
    [erase setTitle:@"X" forState:UIControlStateNormal];
    [erase setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    erase.tag = indexPath.section;
    [erase addTarget:self action:@selector(erase:) forControlEvents:UIControlEventTouchUpInside];
    erase.frame = CGRectMake(self.view.bounds.size.width - 40, 5, 30, 30);
    [cell addSubview:erase];
    
    [cell addSubview:segm];
    return cell;
}

-(void)valueSelected:(UISegmentedControl *)sender{
    [_model setObject:[NSNumber numberWithInt:sender.selectedSegmentIndex] forKey:[NSString stringWithFormat:@"%i", sender.tag]];
}

-(void)erase:(UIButton *)sender{
    [_model removeObjectForKey:[NSString stringWithFormat:@"%i", sender.tag]];
    [self.arrayOfSegms removeAllObjects];
    [self.tableView reloadData];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [ADBApplicationType applicationForInt:section];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
