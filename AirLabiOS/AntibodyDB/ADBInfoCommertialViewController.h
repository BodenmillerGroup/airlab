//
//  ADBInfoCommertialViewController.h
// AirLab
//
//  Created by Raul Catena on 5/11/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBPurchaseBoxViewController.h"
#import "ADBJsonDicEditorViewController.h"

@interface ADBInfoCommertialViewController : ADBMasterViewController<PurchaseBoxProtocol, JsonEditor>

@property (nonatomic, strong) ComertialReagent *reagent;
@property (weak, nonatomic) IBOutlet UIButton *imageQR;
@property (weak, nonatomic) IBOutlet UIButton *antibodyInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andReagent:(ComertialReagent *)reagent;

-(IBAction)captureInfo:(id)sender;
-(IBAction)deleteInfo:(id)sender;
-(IBAction)editInfo:(id)sender;
-(IBAction)antibodyInfo:(id)sender;

@end
