//
//  ADBSelectMemorizedViewController.m
//  AirLab
//
//  Created by Raul Catena on 11/19/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBSelectMemorizedViewController.h"

@interface ADBSelectMemorizedViewController ()

@end

@implementation ADBSelectMemorizedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTheTableviewWithStyle:UITableViewStylePlain];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [(NSDictionary *)[[NSUserDefaults standardUserDefaults]valueForKey:NSUD_EMAIL_LOGIN]allKeys].count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"prev";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    cell.textLabel.text = [[[[NSUserDefaults standardUserDefaults]valueForKey:NSUD_EMAIL_LOGIN]allKeys]objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = @"XXXX";
    
    [self setGrayColorInTableText:cell];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults]valueForKey:NSUD_EMAIL_LOGIN];
    NSDictionary *new = [NSDictionary dictionaryWithObject:[dict valueForKey:[dict.allKeys objectAtIndex:indexPath.row]] forKey:[dict.allKeys objectAtIndex:indexPath.row]];
    [self.delegate selectedLogin:new];
}


@end
