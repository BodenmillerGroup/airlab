//
//  ADBInicialViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/21/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBInicialViewController.h"
#import "PSInstagramViewController.h"
#import "ADBSearchLabViewController.h"
#import <Social/Social.h>

@interface ADBInicialViewController (){
    int trial;
}

@property (nonatomic, strong) NSArray *finishedAbs;
@property (nonatomic, strong) NSArray *orders;
@property (nonatomic, strong) NSArray *low;

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
    _finishedAbs = [General searchDataBaseForClass:LABELEDANTIBODY_DB_CLASS withDictionaryOfTerms:[NSDictionary dictionaryWithObjects:@[@"1"] forKeys:@[@"deleted"]] sortBy:@"labLabeledAntibodyId" ascending:YES inMOC:self.managedObjectContext];
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:REAGENTINSTANCE_DB_CLASS];
    req.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"reiReagentInstanceId" ascending:YES]];
    req.predicate = [NSPredicate predicateWithFormat:@"reiStatus != %@", @"stock"];
    _orders = [self.managedObjectContext executeFetchRequest:req error:nil];
    _low = [General searchDataBaseForClass:LABELEDANTIBODY_DB_CLASS withDictionaryOfTerms:[NSDictionary dictionaryWithObjects:@[@"1"] forKeys:@[@"catchedInfo"]] sortBy:@"labLabeledAntibodyId" ascending:YES inMOC:self.managedObjectContext];
}

-(void)autoRefresh{
    [self prepareArraysForDashboard];
    [super autoRefresh];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goToPhDComics)];
    [_phdComics addGestureRecognizer:tap];
    [_phdComics setUserInteractionEnabled:YES];
    
    self.navigationItem.rightBarButtonItems= @[[[UIBarButtonItem alloc]initWithTitle:@"Log out" style:UIBarButtonItemStyleBordered target:self action:@selector(logOff)], [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchLab:)]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Create group/lab" style:UIBarButtonItemStyleDone target:self action:@selector(createGroup)];
    
    [self prepareArraysForDashboard];
    
    [[IPImporter getInstance]setAcompleter:ZGROUPPERSON_DB_CLASS withBlock:nil];
    [[IPImporter getInstance]setAcompleter:GROUP_DB_CLASS withBlock:nil];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.nombre.text = [NSString stringWithFormat:@"Hello, %@", [[[ADBAccountManager sharedInstance]currentUser]perName]];
    self.lab.text = [NSString stringWithFormat:@"Welcome to the %@ group", [[[[ADBAccountManager sharedInstance]currentGroupPerson]group]grpName]];
    [self triggerComic];
    //[NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(triggerComic) userInfo:nil repeats:YES];
    
    [self buttonForAdmin];
    
    [[IPFetchObjects getInstance] addTagsFromServerWithBlock:nil];
    [[IPFetchObjects getInstance] addSpeciesFromServerWithBlock:nil];
    [[IPFetchObjects getInstance] addProviderssFromServerWithBlock:nil];
    
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
    [General showOKAlertWithTitle:@"Log off in a few minutes and log in again to access the new group you have created" andMessage:nil];
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
                _phdComics.bounds = CGRectMake(0, 0, MAX(300, _phdComics.bounds.size.width), MAX(170, image.size.height));
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
    if ([[ADBAccountManager sharedInstance]currentGroupPerson].gpeRole.intValue > 1) {
        _groupAdminButton.hidden = YES;
    }else{
        _groupAdminButton.hidden = NO;
        [General addBorderToButton:_groupAdminButton withColor:[UIColor orangeColor]];
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_updateType.selectedSegmentIndex == 0)return MIN(_finishedAbs.count, 10);
    if(_updateType.selectedSegmentIndex == 1)return MIN(_orders.count, 10);
    if(_updateType.selectedSegmentIndex == 2)return MIN(_low.count, 10);
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *stringCell = @"aCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:stringCell];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCell];
    }
    if(_updateType.selectedSegmentIndex == 0){
        LabeledAntibody *lab = [_finishedAbs objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@%@", lab.lot.clone.protein.proName, lab.lot.clone.cloName, lab.tag.tagName, lab.tag.tagMW];
    }else if(_updateType.selectedSegmentIndex == 1){
        ReagentInstance *inst = [_orders objectAtIndex:indexPath.row];
        cell.textLabel.text = inst.comertialReagent.comName;
    }else if(_updateType.selectedSegmentIndex == 2){
        LabeledAntibody *inst = [_low objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"anti-%@ %@", inst.lot.clone.protein.proName, inst.lot.clone.cloName];
    }else{
        cell.textLabel.text = @"Example";
    }
    
    [self setGrayColorInTableText:cell];
    
    return cell;
}


-(void)sendTweet{
    if(!_phdComics.image)return;
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                
                NSLog(@"Cancelled");
                
            } else
                
            {
                NSLog(@"Done");
            }
            
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        controller.completionHandler =myBlock;
        [controller setInitialText:@"Funny cartoon from PhDComics"];
        
        NSCalendar *cal = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
        int flags = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
        NSDateComponents *comps = [cal components:flags fromDate:[NSDate date]];
        comps.day = comps.day - trial;
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"MMddyy";;

        NSString *url = [NSString stringWithFormat:@"http://www.phdcomics.com/comics/archive/phd%@s.gif", [formatter stringFromDate:[cal dateFromComponents:comps]]];
        
        [controller addURL:[NSURL URLWithString:url]];

        [controller addImage:_phdComics.image];
        
        [self presentViewController:controller animated:YES completion:Nil];
        
    }
    else{
        [General showOKAlertWithTitle:@"Configure Twitter" andMessage:@"Go to phone settings and set up your account"];
    }
}

-(void)sendFB{
    if(!_phdComics.image)return;
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                
                NSLog(@"Cancelled");
                
            } else
                
            {
                NSLog(@"Done");
            }
            
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        controller.completionHandler =myBlock;
        [controller setInitialText:@"Funny cartoon from PhDComics"];
        
        NSCalendar *cal = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
        int flags = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
        NSDateComponents *comps = [cal components:flags fromDate:[NSDate date]];
        comps.day = comps.day - trial;
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"MMddyy";;
        
        NSString *url = [NSString stringWithFormat:@"http://www.phdcomics.com/comics/archive/phd%@s.gif", [formatter stringFromDate:[cal dateFromComponents:comps]]];
        
        [controller addURL:[NSURL URLWithString:url]];
        
        [controller addImage:_phdComics.image];
        
        [self presentViewController:controller animated:YES completion:Nil];
        
    }
    else{
        [General showOKAlertWithTitle:@"Configure Facebook" andMessage:@"Go to phone settings and set up your account"];
    }
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

-(void)changedType:(id)sender{
    [self.tableView reloadData];
}

@end
