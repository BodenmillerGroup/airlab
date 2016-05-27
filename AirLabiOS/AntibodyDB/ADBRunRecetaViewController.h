//
//  ADBRunRecetaViewController.h
// AirLab
//
//  Created by Raul Catena on 6/14/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"
#import "ADBAddRecipeViewController.h"
#import "ADBPasoCellTableViewCell.h"


@interface ADBRunRecetaViewController : ADBMasterViewController<AddRecipeDelegate, PasoCell>

@property (nonatomic, weak) IBOutlet UITextView *purpose;
@property (nonatomic, weak) IBOutlet UILabel *titleOfRecipe;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andRecipe:(Recipe *)aRecipe;

@end
