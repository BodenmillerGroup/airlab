//
//  ADBMasterViewController.h
// AirLab
//
//  Created by Raul Catena on 3/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "UIView+AnimationExtensions.h"
#import <AVFoundation/AVFoundation.h>
#import <DropboxSDK/DropboxSDK.h>

@interface ADBMasterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UIActionSheetDelegate, DBRestClientDelegate, AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITableView *tableView2;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSMutableArray *filtered;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) UITextField *currentTextFieldResponder;
@property (nonatomic, strong) UITextView *currentTextViewResponder;
@property (nonatomic, strong) NSPredicate *previousPredicate;
@property (nonatomic, strong) IBOutlet UIScrollView *scroll;
@property (nonatomic, strong) UISearchDisplayController *aSearchDisplayController;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, assign) BOOL noAutorefresh;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

-(void)setTheTableviewWithStyle:(UITableViewStyle)style;
-(void)showModalOrPopoverWithViewController:(UIViewController *)controller withFrame:(CGRect)frame;
-(void)dismissModalOrPopover;
-(void)showModalWithCancelButton:(UIViewController *)controller fromVC:(UIViewController *)presenter withPresentationStyle:(UIModalPresentationStyle)style;

-(void)setGrayColorInTableText:(UITableViewCell *)cell;

-(void)autoRefresh;

//Navigation
-(void)backToHomeInNavCon;
-(void)addSearchBar;

//Spinners
-(void)startNavBarSpinner;
-(void)stopNavBarSpinner;
-(void)startCentralSpinner;
-(void)stopCentralSpinner;

//Messages
-(void)noInternetConnection;
-(void)errorInternetConnection;

//Data showing
-(void)refreshTable;

//Filter subclassable methods
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;

//Dropbox
- (DBRestClient *)restClient;
-(BOOL)isDropBoxLinked;
-(void)linkDropBox;
-(void)unlinkDropBox;

//Enabler
-(void)enableOKButtonForTextField;

//Barcode
-(void)barCode;
@end
