//
//  ADBJsonDicEditorViewController.m
//  AirLab
//
//  Created by Raul Catena on 7/13/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import "ADBJsonDicEditorViewController.h"

@interface ADBJsonDicEditorViewController ()

@property (nonatomic, strong) NSMutableDictionary *jsonDict;

@end

@implementation ADBJsonDicEditorViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andJsonDict:(NSDictionary *)dict{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.jsonDict = dict.mutableCopy?dict.mutableCopy:[NSMutableDictionary dictionary];;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItems = @[
                                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)],
                                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)]
                                                ];
    [self setTheTableviewWithStyle:UITableViewStyleGrouped];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _jsonDict.allKeys.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellDi = @"cellDi";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellDi];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellDi];
    }
    for (UIView *aV in cell.contentView.subviews) {
        if ([aV isMemberOfClass:[UITextField class]]) {
            [aV removeFromSuperview];
        }
    }
    cell.textLabel.text = [_jsonDict.allKeys objectAtIndex:indexPath.row];
    UITextField *field = [[UITextField alloc]initWithFrame:CGRectMake(cell.contentView.bounds.size.width - 300, 0, 280, cell.bounds.size.height)];
    field.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    field.tag = indexPath.row;
    field.delegate = self;
    field.text = [_jsonDict valueForKey:cell.textLabel.text];
    [cell.contentView addSubview:field];
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *ip){
        NSString *key = [_jsonDict.allKeys objectAtIndex:indexPath.row];
        [_jsonDict setValue:nil forKey:key];
        [self.tableView reloadData];
    }];
    
    return [NSArray arrayWithObject:deleteAction];
}

-(void)add{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New property" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:nil];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *actionYes = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [_jsonDict setValue:@"" forKey:[(UITextField *)[alert.textFields lastObject]text]];
        [self.tableView reloadData];
    }];
    [alert addAction:action];
    [alert addAction:actionYes];
    [self presentViewController:alert animated:YES completion:nil];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *key = [_jsonDict.allKeys objectAtIndex:textField.tag];
    [_jsonDict setValue:[textField.text stringByAppendingString:string] forKey:key];
    return YES;
}

-(void)done{
    [self.delegate didEditJsonDict:_jsonDict];
}

@end
