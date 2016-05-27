//
//  ADBMasterViewController.m
// AirLab
//
//  Created by Raul Catena on 3/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBAppDelegate.h"

@interface ADBMasterViewController ()

@property (nonatomic, strong) UIBarButtonItem *itemOnHold;
@property (nonatomic, strong) DBRestClient *restClient;

//Para el código de barras
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *prevLayer;

@end

@implementation ADBMasterViewController

@synthesize tableView = _tableView;
@synthesize tableView2 = _tableView2;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize filtered = _filtered;
@synthesize popover = _popover;
@synthesize currentTextFieldResponder = _currentTextFieldResponder;
@synthesize previousPredicate = _previousPredicate;
@synthesize scroll = _scroll;
@synthesize collectionView = _collectionView;

@synthesize itemOnHold = _itemOnHold;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //[self scrollifyMainView];
    }
    return self;
}

//BarcodeCamera

-(void)barCode{
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = self.view.bounds;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_prevLayer];
    
    [_session startRunning];
}

//Override this callback
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"Am I here");
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil)
        {
            NSLog(@"Detection string is %@", detectionString);
            break;
        }
        
    }
    [_prevLayer removeFromSuperlayer];
    [_tableView reloadData];
}

- (DBRestClient *)restClient {
    if (!_restClient) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}

-(void)autoRefresh{
    if (_noAutorefresh == YES) {
        return;
    }
    [self.fetchedResultsController performFetch:nil];
    [self.tableView reloadData];
}

-(id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)enableOKButtonForTextField{
    UIAlertController *controller = (UIAlertController *)self.presentedViewController;
    if (controller.actions.count >=2) {
        UIAlertAction *action = (UIAlertAction *)[controller.actions objectAtIndex:1];
        action.enabled = (BOOL)[[(UITextField *)[[controller textFields]lastObject]text]length];
    }
}

-(NSManagedObjectContext *)managedObjectContext{
    ADBAppDelegate *delegate = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
    return delegate.managedObjectContext;
}

-(void)adjustIOS7{
    if ([[[[[UIDevice currentDevice] systemVersion]
           componentsSeparatedByString:@"."] objectAtIndex:0] intValue] >= 7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

-(void)setTheTableviewWithStyle:(UITableViewStyle)style{
    self.tableView = [[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds style:style];
    self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

-(void)scrollifyMainView{
    self.view = [[UIScrollView alloc]initWithFrame:self.view.frame];
}

-(void)changeColorOfTitle{
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor orangeColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}

-(void)subscribeToUpdates{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refetch) name:UPDATE_SUBSCRIPTION object:nil];
}

-(void)unsubscribe{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UPDATE_SUBSCRIPTION object:nil];
}

-(void)refetch{
    self.fetchedResultsController = nil;
    [self fetchedResultsController];
    [self refreshTable];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self adjustIOS7];
    [self changeColorOfTitle];
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    if (error) [General logError:error];
    NSLog(@"Found %i objects of type %@", (int)self.fetchedResultsController.fetchedObjects.count, NSStringFromClass([[self.fetchedResultsController.fetchedObjects lastObject]class]));
    
    [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(autoRefresh) userInfo:nil repeats:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self subscribeToUpdates];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self unsubscribe];
}

#pragma mark TableView

//All to be overriden

-(void)addSearchBar{
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    searchBar.delegate = self;
    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.aSearchDisplayController.delegate = self;
    self.aSearchDisplayController.searchResultsDelegate = self;
    self.aSearchDisplayController.searchResultsDataSource = self;
    self.aSearchDisplayController = searchDisplayController;
    
    self.tableView.tableHeaderView = searchBar;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //NSLog(@"Calculating sections");
    NSInteger count = [[_fetchedResultsController sections] count];
    
	if (count == 0 || tableView == self.searchDisplayController.searchResultsTableView) {
		count = 1;
	}
    return count;
}

-(void)setColorAndFontToCell:(UITableViewCell *)cell{
    //cell.textLabel.font = [UIFont fontWithName:GENERAL_FONT size:20];//cell.textLabel.font.pointSize];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    //cell.detailTextLabel.font = [UIFont fontWithName:GENERAL_FONT size:17];//cell.detailTextLabel.font.pointSize];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int rows = 0;
    
    if (tableView == self.searchDisplayController.searchResultsTableView){
        rows = (int)[self.filtered count];
    }else{
        if ([[self.fetchedResultsController sections] count] > 0) {
            if ([[self.fetchedResultsController sections] count] == 1) {
                rows = (int)self.fetchedResultsController.fetchedObjects.count;
            }else{
                id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
                rows = (int)[sectionInfo numberOfObjects];
            }
            
        }
    }
    //NSLog(@"Calculating rows %i", rows);
	return rows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[UITableViewCell alloc]init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView2 deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Support delete and FRC

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Delete";//[[LanguageController getInstance]getIdiomForKey:DELETE_ROW];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
    //Override when yes
}

//Override if necesary
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        /*[self.managedObjectContext deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
		
		// Save the context.
		NSError *error;
		if (![self.managedObjectContext save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}*/
        //[self.tableView reloadData];
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            //[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

-(void)setGrayColorInTableText:(UITableViewCell *)cell{
    cell.textLabel.textColor = [UIColor darkGrayColor];
}

#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return _fetchedResultsController.fetchedObjects.count;//self.data.count;
}
//Always override
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    //
    UICollectionViewCell *cell = nil;
    /*MyCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    
    //cell.image.image = nil;
    
    NSDictionary *images = [[self.data objectAtIndex:indexPath.row]objectForKey:@"images"];
    NSDictionary *lowRes = [images objectForKey:@"low_resolution"];
    NSString *url = [lowRes objectForKey:@"url"];
    
    if (url) {NSLog(@"URL is %@", url);
        if ([_photos valueForKey:url]) {
            cell.image.image = [_photos valueForKey:url];
        }else{
            cell.image.image = [UIImage imageNamed:PLACEHOLDER_IMAGE];
        }
    }else{
        cell.image.image = [UIImage imageNamed:PLACEHOLDER_IMAGE];
    }
    
    //cell.label.text = [NSString stringWithFormat:@"{%ld,%ld}", (long)indexPath.row, (long)indexPath.section];*/
    
    return cell;
}

//Always override
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

#pragma mark Textfieldbehaviour

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissText)];
    [self.view addGestureRecognizer:tap];
    self.currentTextFieldResponder = textField;
    
    if ([self.view isMemberOfClass:[UIScrollView class]]) {
        UIScrollView *scroll = (UIScrollView *)self.view;
        scroll.contentSize = CGSizeMake(scroll.bounds.size.width, scroll.bounds.size.height + 0.5*scroll.bounds.size.height);
        [scroll scrollRectToVisible:textField.frame animated:YES];
    }
}

-(void)dismissText{
    [self.currentTextFieldResponder resignFirstResponder];
    self.currentTextFieldResponder = nil;
    for (UIGestureRecognizer *gesture in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:gesture];
    }
    
    if ([self.view isMemberOfClass:[UIScrollView class]]) {
        UIScrollView *scroll = (UIScrollView *)self.view;
        scroll.contentSize = CGSizeMake(scroll.bounds.size.width, scroll.bounds.size.height - 0.5*scroll.bounds.size.height);
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTextView)];
    [self.view addGestureRecognizer:tap];
    self.currentTextViewResponder = textView;
    
    if ([self.view isMemberOfClass:[UIScrollView class]]) {
        UIScrollView *scroll = (UIScrollView *)self.view;
        scroll.contentSize = CGSizeMake(scroll.bounds.size.width, scroll.bounds.size.height + 0.5*scroll.bounds.size.height);
        [scroll scrollRectToVisible:textView.frame animated:YES];
    }
}

-(void)dismissTextView{
    [self.currentTextViewResponder resignFirstResponder];
    self.currentTextViewResponder = nil;
    for (UIGestureRecognizer *gesture in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:gesture];
    }
    
    if ([self.view isMemberOfClass:[UIScrollView class]]) {
        UIScrollView *scroll = (UIScrollView *)self.view;
        scroll.contentSize = CGSizeMake(scroll.bounds.size.width, scroll.bounds.size.height - 0.5*scroll.bounds.size.height);
    }
}

#pragma mark common methods navigation

-(void)showModalOrPopoverWithViewController:(UIViewController *)controller withFrame:(CGRect)frame{
    if (![[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        self.popover = [[UIPopoverController alloc]initWithContentViewController:controller];
        [self.popover presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }else{
        UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:controller];
        [self presentViewController:navCon animated:YES completion:nil];
    }
}

-(void)dismissModalOrPopover{
    if(!self.presentedViewController)return;
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)cancelModal{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
}

-(void)showModalWithCancelButton:(UIViewController *)controller fromVC:(UIViewController *)presenter withPresentationStyle:(UIModalPresentationStyle)style{
    UINavigationController *navCont = [[UINavigationController alloc]initWithRootViewController:controller];
    controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelModal)];
    navCont.modalPresentationStyle = style;
    [presenter presentViewController:navCont animated:YES completion:nil];
}

#pragma mark Spinners

-(void)startNavBarSpinner{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.itemOnHold = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:spinner];
}
-(void)stopNavBarSpinner{
    self.navigationItem.rightBarButtonItem = self.itemOnHold;
}
-(void)startCentralSpinner{
    self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.bounds = CGRectMake(0, 0, 50, 50);
    self.spinner.center = self.view.center;
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
}
-(void)stopCentralSpinner{
    [_spinner stopAnimating];
    [self.spinner removeFromSuperview];
    self.spinner = nil;
}

#pragma mark showing info

-(void)refreshTable{
    NSError *error;
    //self.fetchedResultsController = nil;
    [self.fetchedResultsController performFetch:&error];
    [General saveContextAndRoll];
    [self.tableView reloadData];
    
    if(self.searchDisplayController.searchResultsTableView)[self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark Messages

-(void)noInternetConnection{
    [General showOKAlertWithTitle:ERROR andMessage:@"You are not connected to internet" delegate:self];
}

-(void)errorInternetConnection{
    [General showOKAlertWithTitle:ERROR andMessage:@"There was an error while processing the connection request" delegate:self];
}

#pragma navigation

-(void)backToHomeInNavCon{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Content Filtering

//This needs Subclass
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	self.searchDisplayController.searchBar.showsCancelButton = NO;
    if (!_previousPredicate) {
        self.previousPredicate = _fetchedResultsController.fetchRequest.predicate;
    }
	//Rest goes subclasses
	/*if (searchText != nil) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"comName contains [cd] %@", searchText];
		[self.fetchedResultsController.fetchRequest setPredicate:predicate];
		//[NSFetchedResultsController deleteCacheWithName:@"inventoryCache"];
	}else {
		[self.fetchedResultsController.fetchRequest setPredicate:nil];
		//[NSFetchedResultsController deleteCacheWithName:@"inventoryCache"];
	}
	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		[General logError:error];
	}
    
	[self.tableView reloadData];
    NSLog(@"results: %i", [[self.fetchedResultsController fetchedObjects]count]);
	self.searchDisplayController.searchBar.showsCancelButton = YES;*/
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    if(self.filtered){
        [self.searchDisplayController setActive:NO];
        [self.tableView reloadData];
        return;
    }
	[self.fetchedResultsController.fetchRequest setPredicate:self.previousPredicate];
	//[NSFetchedResultsController deleteCacheWithName:@"inventoryCache"];
    
    
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);
	}
    
	[self.tableView reloadData];
    
    
	searchBar.showsCancelButton = YES;
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods



- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
	[self filterContentForSearchText:searchString scope:
	 [[controller.searchBar scopeButtonTitles] objectAtIndex:[controller.searchBar selectedScopeButtonIndex]]];
    
	return YES;
	
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
	
	[self filterContentForSearchText:[controller.searchBar text] scope:
	 [[controller.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}

#pragma mark OpenBisDelegate
//Always override
-(void)didLogInWithToken:(NSString *)token{

}
-(void)didGetData:(NSData *)data{

}

#pragma mark DBRestClient Delegate
//Will need override

-(BOOL)isDropBoxLinked{
    if (![[DBSession sharedSession] isLinked]) {
        return NO;
    }
    return YES;
}

-(void)linkDropBox{
    [[DBSession sharedSession] linkFromController:self];
}

-(void)unlinkDropBox{
    [[DBSession sharedSession]unlinkAll];
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    
    
    NSArray* validExtensions = [General validExtensionsForFile];
    NSMutableArray* filePaths = [NSMutableArray new];
    for (DBMetadata* child in metadata.contents) {
        NSString* extension = [[child.path pathExtension] lowercaseString];
        if (!child.isDirectory && [validExtensions indexOfObject:extension] != NSNotFound) {
            [filePaths addObject:child];
        }
    }
    //Select FileViewController
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    
    NSLog(@"Error loading metadata: %@", error);
}

@end
