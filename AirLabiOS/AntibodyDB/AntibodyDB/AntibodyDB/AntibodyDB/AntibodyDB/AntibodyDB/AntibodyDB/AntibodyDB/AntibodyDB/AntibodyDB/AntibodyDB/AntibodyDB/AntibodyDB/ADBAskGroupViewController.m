//
//  ADBAskGroupViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAskGroupViewController.h"

@interface ADBAskGroupViewController ()
@property (nonatomic, strong) NSArray *groups;
@end

@implementation ADBAskGroupViewController

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
    _groups = nil;
    [self setTheTableviewWithStyle:UITableViewStylePlain];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner setCenter:self.view.center];
    [self.view addSubview:spinner];
    [spinner startAnimating];
    NSMutableURLRequest *request = [General callToGetAPIWithSuffix:@"getAllGroups"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response_, NSData *data, NSError *error){
        [spinner removeFromSuperview];
        if (!error) {
            _groups = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            [self.tableView reloadData];
        }else{
            [General noConnection:nil];
        }
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _groups.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *type = @"CellType";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:type];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:type];
    }
    cell.textLabel.text = [[_groups objectAtIndex:indexPath.row]valueForKey:@"grpName"];
    cell.detailTextLabel.text = [[_groups objectAtIndex:indexPath.row]valueForKey:@"grpInstitution"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = [[[_groups objectAtIndex:indexPath.row]valueForKey:@"grpGroupId"]intValue];
    NSString *post = [NSString stringWithFormat:@"data={\"personId\":\"%@\",\"groupRequested\":\"%i\"}",
                      [[ADBAccountManager sharedInstance]currentUser].perPersonId, index];
    NSLog(@"Post is %@", post);
    NSMutableURLRequest *request = [General callToAPI:@"requestJoinGroup" withPost:post];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response_, NSData *data, NSError *error){
        if (!error) {
            [General showOKAlertWithTitle:@"Your request has been sent" andMessage:@"Wait for the group administrator to activate your account"];
        }else [General noConnection:nil];
    }];
}

@end
