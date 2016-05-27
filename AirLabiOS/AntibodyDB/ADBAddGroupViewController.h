//
//  ADBAddGroupViewController.h
// AirLab
//
//  Created by Raul Catena on 8/24/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import <MapKit/MapKit.h>

@protocol AddGroupDelegate <NSObject>

-(void)didAddGroup;

@end

@interface ADBAddGroupViewController : ADBMasterViewController

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UITextField *nameOfLab;
@property (nonatomic, weak) IBOutlet UITextField *institution;
@property (nonatomic, weak) id<AddGroupDelegate>delegate;

@end
