//
//  ADBInicialViewController.m
// AirLab
//
//  Created by Raul Catena on 5/21/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBInicialViewController.h"
#import "PSInstagramViewController.h"
#import "ADBSearchLabViewController.h"
#import "ADBInfoCommertialViewController.h"
#import <Social/Social.h>

@interface ADBInicialViewController (){
    int trial;
}

@end

@implementation ADBInicialViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)prepareArraysForDashboard{
    
    _comments = [General searchDataBaseForClass:COMMENTWALL_DB_CLASS sortBy:@"createdAt" ascending:NO inMOC:self.managedObjectContext];
    
    NSFetchRequest *areq = [NSFetchRequest fetchRequestWithEntityName:LABELEDANTIBODY_DB_CLASS];
    areq.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"tubFinishedAt" ascending:NO]];
    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"tubFinishedBy != %@", @"0"];
    //NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"labRelabeled = nil"];
    areq.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[pred1]];
    _finishedAbs = [self.managedObjectContext executeFetchRequest:areq error:nil];
    
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:REAGENTINSTANCE_DB_CLASS];
    req.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"reiRequestedAt" ascending:NO]];
    req.predicate = [NSPredicate predicateWithFormat:@"reiStatus = %@", @"ordered"];
    _orders = [self.managedObjectContext executeFetchRequest:req error:nil];
    
    NSFetchRequest *breq = [NSFetchRequest fetchRequestWithEntityName:LABELEDANTIBODY_DB_CLASS];
    breq.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"labLabeledAntibodyId" ascending:NO]];
    breq.predicate = [NSPredicate predicateWithFormat:@"tubIsLow == %@", @"1"];
    _low = [self.managedObjectContext executeFetchRequest:breq error:nil];
    
    NSFetchRequest *lastReq = [NSFetchRequest fetchRequestWithEntityName:REAGENTINSTANCE_DB_CLASS];
    lastReq.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"reiReceivedAt" ascending:NO]];
    lastReq.predicate = [NSPredicate predicateWithFormat:@"reiReceivedAt.length > 0"];
    _lastArrived = [self.managedObjectContext executeFetchRequest:lastReq error:nil];
    
   
}

-(void)autoRefresh{
    [self prepareArraysForDashboard];
    [super autoRefresh];
}

-(void)changedType:(UISegmentedControl *)sender{
    NSString *class;
    switch (sender.selectedSegmentIndex) {
        case 0:
            class = COMMENTWALL_DB_CLASS;
            break;
            
        default:
            class = REAGENTINSTANCE_DB_CLASS;
            break;
    }
    [[NSUserDefaults standardUserDefaults]setValue:[NSDate date].description forKey:[NSString stringWithFormat:@"CHECKED_DASHBOARD_%@", class]];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self autoRefresh];
    [self notis];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goToPhDComics)];
    [_phdComics addGestureRecognizer:tap];
    [_phdComics setUserInteractionEnabled:YES];
    
    [General iPhoneBlock:nil iPadBlock:^{
        self.navigationItem.rightBarButtonItems= @[[[UIBarButtonItem alloc]initWithTitle:@"Log out" style:UIBarButtonItemStyleDone target:self action:@selector(logOff)], [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchLab:)]];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Create group/lab" style:UIBarButtonItemStyleDone target:self action:@selector(createGroup)];
    }];
    
    [[IPImporter getInstance]setAcompleter:ZGROUPPERSON_DB_CLASS withBlock:nil];
    [[IPImporter getInstance]setAcompleter:GROUP_DB_CLASS withBlock:nil];
}

-(void)notis{
    if(!_updateType)return;
    for (UIView *view in _updateType.subviews) {
        if (view.tag == 1000) {
            [view removeFromSuperview];
        }
    }
    
    ADBNotificationCenter *not = [[ADBNotificationCenter alloc]init];
    
    int finished = [not unseenForArray:_finishedAbs ofClass:LABELEDANTIBODY_DB_CLASS];
    //Will add this categories too.
    //finished = finished + [not unseenForArray:_finishedAbs ofClass:SAMPLE_DB_CLASS];
    //finished = finished + [not unseenForArray:_finishedAbs ofClass:LOT_DB_CLASS];
    //finished = finished + [not unseenForArray:_finishedAbs ofClass:REAGENTINSTANCE_DB_CLASS];
    
    if (finished > 0) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(_updateType.bounds.size.width/_updateType.numberOfSegments*2-30, 20, 30, 30)];
        label.text = [NSString stringWithFormat:@"  %i", finished];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 1000;
        label.backgroundColor = [UIColor orangeColor];
        label.clipsToBounds = YES;
        label.textColor = [UIColor whiteColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        label.layer.borderColor = [UIColor whiteColor].CGColor;
        label.layer.cornerRadius = label.bounds.size.width/2;
        [_updateType addSubview:label];
    }
    
    int remainingOrdered = [[[ADBNotificationCenter alloc]init]unseenForArray:_orders ofClass:REAGENTINSTANCE_DB_CLASS];
    if (remainingOrdered>0) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(_updateType.bounds.size.width/_updateType.numberOfSegments*3-30, 20, 30, 30)];
        label.text = [NSString stringWithFormat:@"  %i", remainingOrdered];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 1000;
        label.backgroundColor = [UIColor orangeColor];
        label.clipsToBounds = YES;
        label.textColor = [UIColor whiteColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        label.layer.borderColor = [UIColor whiteColor].CGColor;
        label.layer.cornerRadius = label.bounds.size.width/2;
        [_updateType addSubview:label];
    }
    
    
    int remaining = [[[ADBNotificationCenter alloc]init]unseenForArray:_comments ofClass:COMMENTWALL_DB_CLASS];
    if (remaining>0) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(_updateType.bounds.size.width/_updateType.numberOfSegments*5-30, 20, 30, 30)];
        label.text = [NSString stringWithFormat:@"  %i", remaining];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 1000;
        label.backgroundColor = [UIColor orangeColor];
        label.clipsToBounds = YES;
        label.textColor = [UIColor whiteColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        label.layer.cornerRadius = label.bounds.size.width/2;
        label.layer.borderColor = [UIColor whiteColor].CGColor;
        [_updateType addSubview:label];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.nombre.text = [NSString stringWithFormat:@"Hello, %@", [[[ADBAccountManager sharedInstance]currentUser]perName]];
    self.lab.text = [NSString stringWithFormat:@"Welcome to the %@ group", [[[[ADBAccountManager sharedInstance]currentGroupPerson]group]grpName]];
    [General iPhoneBlock:nil iPadBlock:^{
        [self triggerComic];
    }];
    
    //[NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(triggerComic) userInfo:nil repeats:YES];
    
    [self buttonForAdmin];
    
    [[IPFetchObjects getInstance] addTagsFromServerWithBlock:nil];
    [[IPFetchObjects getInstance] addSpeciesFromServerWithBlock:nil];
    [[IPFetchObjects getInstance] addProviderssFromServerWithBlock:nil];
    [[IPFetchObjects getInstance] addCommentWallsForServerWithBlock:nil];
    
    //[self autoRefresh]//;
    [self prepareArraysForDashboard];
    [self notis];
}

-(void)logOff{
    [[ADBAccountManager sharedInstance]logOff];
}

-(void)searchLab:(UIBarButtonItem *)sender{
    [self showModalOrPopoverWithViewController:[[ADBSearchLabViewController alloc]init] withFrame:CGRectMake(self.view.bounds.size.width, 0, 0, 0)];
}

-(void)createGroup{
    ADBAddGroupViewController *add = [[ADBAddGroupViewController alloc]init];
    add.delegate = self;
    [self showModalWithCancelButton:add fromVC:self withPresentationStyle:UIModalPresentationFullScreen];
}

-(void)didAddGroup{
    [self dismissModalOrPopover];
    [General showOKAlertWithTitle:@"Log off in a few minutes and log in again to access the new group you have created" andMessage:nil delegate:self];
}

-(void)goToPhDComics{
    
    ADBMasterViewController *master = [[ADBMasterViewController alloc]init];
    UIWebView *webView = [[UIWebView alloc]initWithFrame:self.view.frame];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.phdcomics.com"]]];
    [master.view addSubview:webView];
    [self showModalWithCancelButton:master fromVC:self withPresentationStyle:UIModalPresentationFullScreen];
}

-(void)getComic{
    NSCalendar *cal = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    int flags = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
    NSDateComponents *comps = [cal components:flags fromDate:[NSDate date]];
    comps.day = comps.day - trial;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"MMddyy";;
    [self getComicAtDate:[formatter stringFromDate:[cal dateFromComponents:comps]]];
}

-(void)getComicAtDate:(NSString *)date{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable){
        return;
    }
    NSString *url = [NSString stringWithFormat:@"http://www.phdcomics.com/comics/archive/phd%@s.gif", date];
    NSLog(@"The url is %@", url);
    NSMutableURLRequest *request = [General callToGetAPI:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                //_phdComics.bounds = CGRectMake(0, 0, MAX(300, _phdComics.bounds.size.width), MAX(170, image.size.height));
                _phdComics.image = image;
                
            }else{
                trial++;
                [self getComic];
            }
        }
    }];
}

-(void)triggerComic{
    [self getComic];
}

-(void)buttonForAdmin{
    if ([[ADBAccountManager sharedInstance]currentGroupPerson].gpePersonId.intValue == [[ADBAccountManager sharedInstance]currentGroupPerson].group.createdBy.intValue) {
        _groupAdminButton.hidden = NO;
    }else{
        _groupAdminButton.hidden = YES;
    }
    [General addBorderToButton:_groupAdminButton withColor:[UIColor orangeColor]];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_updateType.selectedSegmentIndex == 0)return MIN(_comments.count, 20);
    if(_updateType.selectedSegmentIndex == 1)return MIN(_finishedAbs.count, 20);
    if(_updateType.selectedSegmentIndex == 2)return MIN(_orders.count, 20);
    if(_updateType.selectedSegmentIndex == 3)return MIN(_low.count, 20);
    if(_updateType.selectedSegmentIndex == 4)return MIN(_lastArrived.count, 20);
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *stringCell = @"aCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:stringCell];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:stringCell];
    }
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    
    if(_updateType.selectedSegmentIndex == 0){
        CommentWall *comment = [_comments objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", comment.cwlComment];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ - %@ | %@", comment.groupPerson.person.perName, comment.groupPerson.person.perLastname, [General getDateFromDescription:comment.createdAt], [General getHourFromDescription:comment.createdAt]];
    }else if(_updateType.selectedSegmentIndex == 1){
        LabeledAntibody *lab = [_finishedAbs objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@%@", lab.lot.clone.protein.proName, lab.lot.clone.cloName, lab.tag.tagName, lab.tag.tagMW];
        cell.detailTextLabel.text = [General getDateFromDescription:lab.tubFinishedAt];
    }else if(_updateType.selectedSegmentIndex == 2){
        ReagentInstance *inst = [_orders objectAtIndex:indexPath.row];
        cell.textLabel.text = inst.comertialReagent.comName;
        cell.detailTextLabel.text = [[[General getDateFromDescription:inst.reiRequestedAt] stringByAppendingString:@" "]stringByAppendingString:@" "];
    }else if(_updateType.selectedSegmentIndex == 3){
        LabeledAntibody *inst = [_low objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"anti-%@ %@", inst.lot.clone.protein.proName, inst.lot.clone.cloName];
        cell.detailTextLabel.text = nil;
    }else if(_updateType.selectedSegmentIndex == 4){
        ReagentInstance *inst = [_lastArrived objectAtIndex:indexPath.row];
        cell.textLabel.text = inst.comertialReagent.comName;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Received by %@", [(ReagentInstance *)inst receiver].person.perName];
    }
    cell.detailTextLabel.textColor = [UIColor orangeColor];
    
    [self setGrayColorInTableText:cell];
    
    return cell;
}

//Override if necesary
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    if(_updateType.selectedSegmentIndex == 0){
        LabeledAntibody *conjugate = [_finishedAbs objectAtIndex:indexPath.row];
        UITableViewRowAction *relabelAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Mark as relabeled" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            
            if (conjugate.labRelabeled.intValue != 1) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure" message:@"Have you already relabeled this clone?" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
                [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
                    conjugate.labRelabeled = @"1";
                    [[IPExporter getInstance]updateInfoForObject:conjugate withBlock:nil];
                    [self refreshTable];
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
        relabelAction.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
        [array addObject:relabelAction];
    }
    return [NSArray arrayWithArray:array];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_updateType.selectedSegmentIndex ==4){
        ADBInfoCommertialViewController *info = [[ADBInfoCommertialViewController alloc]initWithNibName:nil bundle:nil andReagent:[(ReagentInstance *)[_lastArrived objectAtIndex:indexPath.row]comertialReagent]];
        [self showModalWithCancelButton:info fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
    }
}


-(void)sendTweet{
    if(!_phdComics.image)return;
    
    NSCalendar *cal = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    int flags = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
    NSDateComponents *comps = [cal components:flags fromDate:[NSDate date]];
    comps.day = comps.day - trial;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"MMddyy";
    
    NSString *url = [NSString stringWithFormat:@"http://www.phdcomics.com/comics/archive/phd%@s.gif", [formatter stringFromDate:[cal dateFromComponents:comps]]];
    
    [General sendTweet:@"Funny cartoon from PhDComics" withImage:_phdComics.image andURL:url fromVC:self];
    
}

-(void)sendFB{
    if(!_phdComics.image)return;
    
    NSCalendar *cal = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    int flags = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
    NSDateComponents *comps = [cal components:flags fromDate:[NSDate date]];
    comps.day = comps.day - trial;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"MMddyy";
    
    NSString *url = [NSString stringWithFormat:@"http://www.phdcomics.com/comics/archive/phd%@s.gif", [formatter stringFromDate:[cal dateFromComponents:comps]]];
    
    [General sendFB:@"Funny cartoon from PhDComics" withImage:_phdComics.image andURL:url fromVC:self];
    
}

-(void)facebook:(id)sender{
    [self sendFB];
}

-(void)twitter:(id)sender{
    [self sendTweet];
}

-(void)instagram:(id)sender{
    PSInstagramViewController *instagram = [[PSInstagramViewController alloc]init];
    [self showModalWithCancelButton:instagram fromVC:self withPresentationStyle:UIModalPresentationFormSheet];
}

- (IBAction)adminGroup:(id)sender {
    ADBAdminGroupViewController *admin = [[ADBAdminGroupViewController alloc]init];
    [self showModalWithCancelButton:admin fromVC:self withPresentationStyle:UIModalPresentationFullScreen];
}

-(void)addComment:(UIButton *)sender{
    if (_updateType.selectedSegmentIndex != 0) {
        [_updateType setSelectedSegmentIndex:0];
        [self changedType:nil];
    }
    ADBAddCommentViewController *comment = [[ADBAddCommentViewController alloc]init];
    UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:comment];
    comment.delegate = self;
    [General iPhoneBlock:^{
        [self showModalWithCancelButton:comment fromVC:self withPresentationStyle:UIModalPresentationFullScreen];
    } iPadBlock:^{
        [self showModalOrPopoverWithViewController:navCon withFrame:sender.frame];}];
}

-(void)didAddComment{
    [self changedType:nil];
    [self dismissModalOrPopover];
}

@end
