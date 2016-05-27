//
//  ADBAddGroupViewController.m
// AirLab
//
//  Created by Raul Catena on 8/24/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddGroupViewController.h"

@interface ADBAddGroupViewController (){
    CGPoint touchPoint;
}

@end

@implementation ADBAddGroupViewController

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [self.mapView addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)]];
    // Do any additional setup after loading the view from its nib.
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
    
}

-(void)done{
    if (_nameOfLab.text && _institution.text) {
        if (![General checkPointersAndText:@[_nameOfLab.text, _institution.text, [General coordinatesToString:(CLLocationCoordinate2D)[(MKPointAnnotation *)[self.mapView.annotations lastObject]coordinate]]]]) {
            NSLog(@"%f,%f", touchPoint.x, touchPoint.y);
            [General showOKAlertWithTitle:@"Please input all the required information" andMessage:nil delegate:self];
            return;
        }
        
        
        Group *group = (Group *)[General newObjectOfType:GROUP_DB_CLASS saveContext:YES];
        group.grpName = self.nameOfLab.text;
        group.grpInstitution = self.institution.text;
        group.grpCoordinates = [General coordinatesToString:(CLLocationCoordinate2D)[(MKPointAnnotation *)[self.mapView.annotations lastObject]coordinate]];
        ZGroupPerson *linker = (ZGroupPerson *)[General newObjectOfType:ZGROUPPERSON_DB_CLASS saveContext:NO];
        [General doLinkForProperty:@"group" inObject:linker withReceiverKey:@"gpeGroupId" fromDonor:group withPK:@"grpGroupId"];
        [General doLinkForProperty:@"person" inObject:linker withReceiverKey:@"gpePersonId" fromDonor:[ADBAccountManager sharedInstance].currentUser withPK:@"perPersonId"];
        
        ///RCF KONTUZ. This is an exception. Only for group creation.
        group.createdBy = linker.person.perPersonId;
                
        [self.delegate didAddGroup];
    }else{
        [General showOKAlertWithTitle:@"Please input all the required information" andMessage:nil delegate:self];
        return;
    }
}

@end
