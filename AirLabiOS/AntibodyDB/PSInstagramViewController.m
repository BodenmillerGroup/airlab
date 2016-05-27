//
//  PSInstagramViewController.m
//  PrimaveraSound
//
//  Created by Raul Catena on 5/13/13.
//  Copyright (c) 2013 Raul Catena. All rights reserved.
//

#import "PSInstagramViewController.h"
#import "ADBMasterViewController.h"
#import "ADBAppDelegate.h"
#import "InstagramCell.h"
#import "PSInstagramPhotoTaken.h"
#import "MyCell.h"
//#import "InstaPic.h"

NSString *kCellID = @"cellID";
#define MAX_PICTURES 16

@interface PSInstagramViewController ()

@property(nonatomic, strong) NSArray* data;

@end

@implementation PSInstagramViewController

//@synthesize instagram = _instagram;
@synthesize collectionView = _collectionView;
@synthesize data = _data;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define APP_ID_INSTAGRAM @"9a650b98df5545af9f197a7400188cd0"

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"AirLab | Instagram";
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"MyCell" bundle:nil] forCellWithReuseIdentifier:kCellID];
    
    self.instagram = [[Instagram alloc] initWithClientId:APP_ID_INSTAGRAM delegate:self];
    // here i can set accessToken received on previous login
    ADBAppDelegate *delegateApp = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
    delegateApp.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    NSLog(@"ACCESS TOKEN IS %@", delegateApp.instagram.accessToken);
    delegateApp.instagram.sessionDelegate = self;
    if (![delegateApp.instagram isSessionValid]) {
        [delegateApp.instagram authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
    }else{
        [self realizeCallWithInstagram:delegateApp.instagram];
    }
    
}

-(void)realizeCallWithInstagram:(Instagram *)anInstagram{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"tags/science/media/recent", @"method", nil];//@"users/self/followed-by", @"method", nil];//media/popular
    [anInstagram requestWithParams:params delegate:self];
}

#define INSTAGRAM_ACCESS_TOKEN @"accessToken"
-(void)igDidLogin {
    NSLog(@"Instagram did login");
    // here i can store accessToken
    ADBAppDelegate* appDelegate = (ADBAppDelegate *)[UIApplication sharedApplication].delegate;
    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.instagram.accessToken forKey:INSTAGRAM_ACCESS_TOKEN];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    [self realizeCallWithInstagram:appDelegate.instagram];
}

-(void)igDidNotLogin:(BOOL)cancelled{
}

-(void)igDidLogout{
}

-(void)igSessionInvalidated{
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return _photos.count;//self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    //
    MyCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    
    //cell.image.image = nil;
    
    NSDictionary *images = [[self.data objectAtIndex:indexPath.row]objectForKey:@"images"];
    NSDictionary *lowRes = [images objectForKey:@"low_resolution"];
    NSString *url = [lowRes objectForKey:@"url"];
    
    if (url) {
        //NSLog(@"URL is %@", url);
        if ([_photos valueForKey:url]) {
            cell.image.image = [_photos valueForKey:url];
        }else{
            //cell.image.image = [UIImage imageNamed:PLACEHOLDER_IMAGE];
        }
    }else{
        //cell.image.image = [UIImage imageNamed:PLACEHOLDER_IMAGE];
    }
    
    //cell.label.text = [NSString stringWithFormat:@"{%ld,%ld}", (long)indexPath.row, (long)indexPath.section];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    InstagramCell *cell = (InstagramCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    PSInstagramDetailViewController *detailViewController = [[PSInstagramDetailViewController alloc]initWithNibName:nil bundle:nil image:cell.image.image andDataDictionary:[self.data objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:detailViewController animated:YES];
    self.navigationController.navigationBar.topItem.title = @" ";
}

#pragma mark - IGRequestDelegate

- (void)request:(IGRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Instagram did fail: %@", error);
    [General showOKAlertWithTitle:@"Error" andMessage:[error localizedDescription] delegate:self];
}

- (void)request:(IGRequest *)request didLoad:(id)result {
    NSLog(@"Instagram did load: %@", result);
    self.data = (NSArray*)[result objectForKey:@"data"];
    
    if (!_photos) {
        _photos = [NSMutableDictionary dictionaryWithCapacity:40];
    }
    
    UIBarButtonItem *oldButton = self.navigationItem.rightBarButtonItem;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:spinner];
    
    __block int counter = 1;
    
    for (NSDictionary *dict in self.data) {
        NSDictionary *images = [dict objectForKey:@"images"];
        NSDictionary *lowRes = [images objectForKey:@"low_resolution"];
        NSString *url = [lowRes objectForKey:@"url"];
        
        if (url) {
            if (![_photos valueForKey:url]) {
                dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
                dispatch_async(downloadQueue, ^{
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
                    
                    if (image) {
                        [_photos setObject:image forKey:url];
                        /////////////////////To keep the pictures
                        //InstaPic *pic = [NSEntityDescription insertNewObjectForEntityForName:@"InstaPic" inManagedObjectContext:self.managedObjectContext];
                        //pic.zetPicture = [NSKeyedArchiver archivedDataWithRootObject:image];
                    }
                    counter++;
                    if (counter >= MAX_PICTURES) {
                        self.navigationItem.rightBarButtonItem = oldButton;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.collectionView reloadData];
                        
                    });
                });
            }
        }
    }
    
    //if (self.managedObjectContext.hasChanges) {
      //  [[IPImporter getInstance].managedObjectContext save:nil];
    //}
    
    [self.collectionView reloadData];
}

-(void)takePicture{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else{
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    };
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:^{}];
}

-(void)reload{
    ADBAppDelegate *delegateApp = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
    [self realizeCallWithInstagram:delegateApp.instagram];
}

#pragma UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker
	  didFinishPickingImage : (UIImage *)image
				 editingInfo:(NSDictionary *)editingInfo
{
    //NSData *data = [NSKeyedArchiver archivedDataWithRootObject:image];
    NSData *data = UIImageJPEGRepresentation(image, 0.2);
    
    NSLog(@"La foto %i", [data length]);
    
    [self dismissViewControllerAnimated:YES completion:^{
        PSInstagramPhotoTaken *photoTaken = [[PSInstagramPhotoTaken alloc]initWithNibName:nil bundle:nil andImage:image];
        //[self presentAModal:photoTaken withBarColor:[UIColor colorWithRed:0 green:0.3 blue:0 alpha:1]];
        [self showModalWithCancelButton:photoTaken fromVC:self withPresentationStyle:UIModalPresentationCurrentContext];
    }];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)  picker
{

    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
