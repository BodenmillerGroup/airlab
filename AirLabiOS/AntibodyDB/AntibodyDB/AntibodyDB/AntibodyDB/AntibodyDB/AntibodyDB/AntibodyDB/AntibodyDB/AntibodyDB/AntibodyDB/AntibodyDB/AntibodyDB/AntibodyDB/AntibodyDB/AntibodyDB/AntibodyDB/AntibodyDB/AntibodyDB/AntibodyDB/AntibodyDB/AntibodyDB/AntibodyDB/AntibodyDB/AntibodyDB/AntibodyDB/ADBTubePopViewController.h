//
//  ADBViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBPurchaseBoxViewController.h"

@protocol TubePopDelegate <NSObject>

-(void)didRemoveTube;

@end

@interface ADBTubePopViewController : ADBMasterViewController <PurchaseBoxProtocol>
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *sideLabel;
@property (weak, nonatomic) IBOutlet UIButton *empty;
@property (weak, nonatomic) IBOutlet UIButton *reorder;
@property (weak, nonatomic) IBOutlet UIButton *remove;
@property (assign, nonatomic) id<TubePopDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIButton *qrImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTube:(Tube *)tube;
- (IBAction)markEmpty:(UIButton *)sender;
- (IBAction)reorder:(id)sender;
- (IBAction)removeTube:(id)sender;

@end
