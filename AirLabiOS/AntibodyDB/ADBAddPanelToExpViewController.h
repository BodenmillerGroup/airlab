//
//  ADBAddPanelToExpViewController.h
// AirLab
//
//  Created by Raul Catena on 10/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol PanelToExp <NSObject>

-(void)didAddDetailsForPanel:(Panel *)panel expType:(int)type andTissue:(NSString *)tissue isValidation:(BOOL)isVal;

@end

@interface ADBAddPanelToExpViewController : ADBMasterViewController

@property (nonatomic, weak) id<PanelToExp>delegate;
@property (nonatomic, weak) IBOutlet UISegmentedControl *typeOfExp;
@property (nonatomic, weak) IBOutlet UITextField *tissueType;
@property (nonatomic, weak) IBOutlet UIButton *doneBut;
@property (nonatomic, weak) IBOutlet UISwitch *validation;

-(IBAction)done;
-(id)initWithPanel:(Panel *)panel;

@end
