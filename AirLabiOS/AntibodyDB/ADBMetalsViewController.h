//
//  ADBMetalsViewController.h
// AirLab
//
//  Created by Raul Catena on 5/7/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMetalCellTableViewCell.h"
#import "ADBMetalPanelViewController.h"


@interface ADBMetalsViewController : ADBMetalPanelViewController <ConjugateSelected>

@property (nonatomic, strong) NSMutableArray *selectedConjugates;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPanel:(Panel *)panel;

@end
