//
//  PSInstagramDetailViewController.m
//  ERA-EDTA2013
//
//  Created by Raul Catena on 10/8/13.
//  Copyright (c) 2013 Raul Catena. All rights reserved.
//

#import "PSInstagramDetailViewController.h"
#import "Instagram.h"

@interface PSInstagramDetailViewController ()

@end

@implementation PSInstagramDetailViewController

@synthesize imageViewButton = _imageViewButton;
@synthesize dataDictionary = _dataDictionary;
@synthesize image = _image;
@synthesize likes = _likes;
@synthesize likeButton = _likeButton;

-(void)viewDidUnload{
    [super viewDidUnload];
    self.imageViewButton = nil;
    self.likes = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil image:(UIImage *)image andDataDictionary:(NSDictionary *)dataDict
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.image = image;
        self.dataDictionary = dataDict;
        NSLog(@"Data dic is %@", self.dataDictionary);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.imageView.image = self.image;
    [self.imageViewButton setBackgroundImage:self.image forState:UIControlStateNormal];
    [self.imageViewButton addTarget:self action:@selector(wholeScreen) forControlEvents:UIControlEventTouchUpInside];
    self.likes.text = [NSString stringWithFormat:@"%i Likes", [[[self.dataDictionary valueForKey:@"likes"]valueForKey:@"count"]intValue]];
    if ([[_dataDictionary valueForKey:@"user_has_liked"]intValue] == 1) {
        self.likeButton.tag = 1;
        [self.likeButton setBackgroundImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [(NSArray *)[[self.dataDictionary valueForKey:@"comments"]valueForKey:@"data"]count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    NSDictionary *dict = [self.dataDictionary valueForKey:@"comments"];
    NSArray *array = [dict valueForKey:@"data"];
    NSDictionary *comment = [array objectAtIndex:indexPath.row];
    NSLog(@"Comment is %@", comment);
    cell.detailTextLabel.text = [comment valueForKey:@"text"];
    cell.detailTextLabel.textColor = self.navigationController.navigationBar.barTintColor;
    cell.textLabel.text = [[comment valueForKey:@"from"]valueForKey:@"full_name"];
    cell.textLabel.textColor = self.navigationController.navigationBar.barTintColor;
    return cell;
    
}

#define kAlertViewSavePicture 0

-(IBAction)savePicture:(id)sender{
    //LanguageController *language = [LanguageController getInstance];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Save picture" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = kAlertViewSavePicture;
    [alert show];
}

#define kAlertViewComment 1
-(IBAction)addComment:(id)sender{
    //LanguageController *language = [LanguageController getInstance];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Add comment" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = kAlertViewComment;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kAlertViewSavePicture && buttonIndex == 1) {
        UIImageWriteToSavedPhotosAlbum(self.image, self,
                                       @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    if (alertView.tag == kAlertViewComment && buttonIndex == 1) {
        NSString *comment = [alertView textFieldAtIndex:0].text;
        ADBAppDelegate *delegateApp = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
        NSString *post = [NSString stringWithFormat:@"text=%@&access_token=%@", comment, delegateApp.instagram.accessToken];
        //TODO RCF get authorize at http://bit.ly/instacomments
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@/comments", [_dataDictionary valueForKey:@"id"]]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        [request setHTTPMethod:@"POST"];
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
        [request setHTTPBody:postData];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response_, NSData *data_, NSError *error_){
            NSLog(@"Response is %@", [[NSString alloc]initWithData:data_ encoding:NSUTF8StringEncoding]);
        }];
    }
}

-(void)likePicture:(UIButton *)sender{
    if (sender.tag == 0) {
        sender.tag = 1;
        [sender setBackgroundImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
        ADBAppDelegate *delegateApp = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
        NSString *post = [NSString stringWithFormat:@"&access_token=%@", delegateApp.instagram.accessToken];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@/likes", [_dataDictionary valueForKey:@"id"]]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        [request setHTTPMethod:@"POST"];
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
        [request setHTTPBody:postData];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response_, NSData *data_, NSError *error_){
            NSLog(@"Response is %@", [[NSString alloc]initWithData:data_ encoding:NSUTF8StringEncoding]);
        }];
    }else{
        sender.tag = 0;
        [sender setBackgroundImage:[UIImage imageNamed:@"heartEmpty.png"] forState:UIControlStateNormal];
        ADBAppDelegate *delegateApp = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@/likes?access_token=%@", [_dataDictionary valueForKey:@"id"], delegateApp.instagram.accessToken]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        [request setHTTPMethod:@"DELETE"];
 
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response_, NSData *data_, NSError *error_){
            NSLog(@"Response is %@", [[NSString alloc]initWithData:data_ encoding:NSUTF8StringEncoding]);
        }];
    }
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error != NULL){
    }else{
        [General showOKAlertWithTitle:@"Image Saved" andMessage:nil delegate:self];
    }
}

-(void)wholeScreen{
    UIImageView *imageView = [[UIImageView alloc]initWithImage:self.image];
    UIView *view = [[UIView alloc]initWithFrame:self.view.frame];
    view.backgroundColor = [UIColor blackColor];
    [view addSubview:imageView];
    view.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
    imageView.center = view.center;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide:)];
    gesture.numberOfTapsRequired = 2;
    [self.view addSubview:view];
    [view addGestureRecognizer:gesture];
}

-(void)hide:(UITapGestureRecognizer *)sender{
    [sender.view removeFromSuperview];
}


@end
