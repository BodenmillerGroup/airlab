//
//  ADBAdminGroupViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAdminGroupViewController.h"

@interface ADBAdminGroupViewController (){
    CGPoint touchPoint;
}
@property (nonatomic, strong) NSArray *everyBody;
@property (nonatomic, strong) ZGroupPerson *selected;
@end

@implementation ADBAdminGroupViewController

-(void)setSelected:(ZGroupPerson *)selected{
    _selected = selected;
    _selectedName.text = selected.person.perName;
    _selectedLastName.text = selected.person.perLastname;
    _selectedEmail.text = selected.person.perEmail;
    _selectedRole.selectedSegmentIndex = selected.gpeRole.integerValue;
    _selectedCanPlaceOrders.on = selected.gpeOrders.boolValue;
    _selectedCanEraseRecords.on = selected.gpeErase.boolValue;
    _selectedCanSeeFinances.on = selected.gpeFinances.boolValue;
}

-(void)anyChanged:(id)sender{
    if (sender == _groupName || sender == _institution || sender == _url) {
        _saveInfoGroupButton.alpha = 1;
        return;
    }
    _saveButton.alpha = 1;
}

-(void)saved:(id)sender{
    //TODO save data changes
    _saveButton.alpha = 0;
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = touchMapCoordinate;
    
    [self.mapView addAnnotation:point];
    
    [[ADBAccountManager sharedInstance]currentGroupPerson].group.grpCoordinates = [General coordinatesToString:touchMapCoordinate];
    
    _saveInfoGroupButton.alpha = 1;
    
}

-(void)savedInfoGroup:(id)sender{
    //TODO save data changes
    Group *group = [[ADBAccountManager sharedInstance]currentGroupPerson].group;
    group.grpCoordinates = [General coordinatesToString:(CLLocationCoordinate2D)[(MKPointAnnotation *)[self.mapView.annotations lastObject]coordinate]];
    if (_groupName.text.length > 0) {
        group.grpName = _groupName.text;
    }
    if (_institution.text.length > 0) {
        group.grpInstitution = _institution.text;
    }
    if (_url.text.length > 0) {
        group.grpUrl = _url.text;
    }
    [[IPExporter getInstance]updateInfoForObject:group withBlock:^(NSURLResponse *response, NSData *data, NSError *error){
        if (!error && [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding].intValue == 1) {
            _saveInfoGroupButton.alpha = 0;
        }
    }];
    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)refresh{
    self.everyBody = [[[[[ADBAccountManager sharedInstance]currentGroupPerson]group]groupPersons]allObjects];
    NSLog(@"Everybody is %i", _everyBody.count);
    [self.tableView reloadData];
    
}

-(void)checkRights{
    if ([[[ADBAccountManager sharedInstance]currentGroupPerson]gpeRole].intValue>1) {
        _selectedRole.userInteractionEnabled = NO;
        _selectedCanPlaceOrders.userInteractionEnabled = NO;
        _selectedCanEraseRecords.userInteractionEnabled = NO;
        _selectedCanSeeFinances.userInteractionEnabled = NO;
        _url.userInteractionEnabled = NO;
        _institution.userInteractionEnabled = NO;
        _groupName.userInteractionEnabled = NO;
    }
}

-(void)updateSaveButton{
    _saveButton.alpha = 0.0f;
    [General addBorderToButton:_saveButton withColor:[UIColor orangeColor]];
    _saveInfoGroupButton.alpha = 0.0f;
    [General addBorderToButton:_saveInfoGroupButton withColor:[UIColor orangeColor]];
}

-(void)layGroup{
    _groupName.text = [[ADBAccountManager sharedInstance]currentGroupPerson].group.grpName;
    _institution.text = [[ADBAccountManager sharedInstance]currentGroupPerson].group.grpInstitution;
    _url.text = [[ADBAccountManager sharedInstance]currentGroupPerson].group.grpUrl;
    NSLog(@"The group URL is %@",[[ADBAccountManager sharedInstance]currentGroupPerson].group.grpUrl );
    CLLocationCoordinate2D touchMapCoordinate = [General stringToCoordinates:[[ADBAccountManager sharedInstance]currentGroupPerson].group.grpCoordinates];
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = touchMapCoordinate;
    
    [self.mapView addAnnotation:point];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refresh];
    [self checkRights];
    [self updateSaveButton];
    [self layGroup];
    
    [self.mapView addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)]];
    
    [[IPFetchObjects getInstance]addPeopleFromLabFromServerWithBlock:^{
        [self refresh];
    }];
}

-(void)invite:(id)sender{
    if ([General checkEmailIsValid:_invitee.text]) {
        [[ADBAccountManager sharedInstance]invite:_invitee.text];
    }else{
        [General showOKAlertWithTitle:@"Please input a valid email address" andMessage:nil];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[[ADBAccountManager sharedInstance]currentGroupPerson]group]groupPersons].count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *personCell = @"PersonCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:personCell];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:personCell];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    ZGroupPerson *person  = [_everyBody objectAtIndex:indexPath.row];
    if (!person.person.perName) {
        cell.textLabel.text = person.person.perEmail;
        cell.detailTextLabel.text = nil;
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", person.person.perName, person.person.perLastname];
        cell.detailTextLabel.text = person.person.perEmail;
    }
    if (person == [[ADBAccountManager sharedInstance]currentGroupPerson]) {
        cell.textLabel.textColor = [UIColor blueColor];
        cell.textLabel.text = [cell.textLabel.text stringByAppendingString:@" (Me)"];
    }else{
        [self setGrayColorInTableText:cell];
    }
    
    if (person.gpeRole.intValue == -1) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIColor *color = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
        [General addBorderToButton:button withColor:color];
        [button setTitleColor:color forState:UIControlStateNormal];
        button.tag = indexPath.row;
        [button addTarget:self action:@selector(accept:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(cell.contentView.bounds.size.width - 70, 5, 65, cell.contentView.bounds.size.height - 10);
        [cell.contentView addSubview:button];
        [button setTitle:@"Accept" forState:UIControlStateNormal];
    }
    
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Remove from this group";//[[LanguageController getInstance]getIdiomForKey:DELETE_ROW];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    ZGroupPerson *groupPerson = [_everyBody objectAtIndex:indexPath.row];
    if (groupPerson == [[ADBAccountManager sharedInstance]currentGroupPerson]) {
        return NO;
    }
    return YES;
    //Override when yes
}

//Override if necesary
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ZGroupPerson *groupPerson = [_everyBody objectAtIndex:indexPath.row];
        [[ADBAccountManager sharedInstance]removePersonGroup:groupPerson];
        [self.tableView reloadData];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ZGroupPerson *groupPerson = [_everyBody objectAtIndex:indexPath.row];
    [self setSelected:groupPerson];
}


-(void)accept:(UIButton *)button{
    ZGroupPerson *groupPerson = [_everyBody objectAtIndex:button.tag];
    [[ADBAccountManager sharedInstance]acceptPersonGroup:groupPerson];
}

@end
