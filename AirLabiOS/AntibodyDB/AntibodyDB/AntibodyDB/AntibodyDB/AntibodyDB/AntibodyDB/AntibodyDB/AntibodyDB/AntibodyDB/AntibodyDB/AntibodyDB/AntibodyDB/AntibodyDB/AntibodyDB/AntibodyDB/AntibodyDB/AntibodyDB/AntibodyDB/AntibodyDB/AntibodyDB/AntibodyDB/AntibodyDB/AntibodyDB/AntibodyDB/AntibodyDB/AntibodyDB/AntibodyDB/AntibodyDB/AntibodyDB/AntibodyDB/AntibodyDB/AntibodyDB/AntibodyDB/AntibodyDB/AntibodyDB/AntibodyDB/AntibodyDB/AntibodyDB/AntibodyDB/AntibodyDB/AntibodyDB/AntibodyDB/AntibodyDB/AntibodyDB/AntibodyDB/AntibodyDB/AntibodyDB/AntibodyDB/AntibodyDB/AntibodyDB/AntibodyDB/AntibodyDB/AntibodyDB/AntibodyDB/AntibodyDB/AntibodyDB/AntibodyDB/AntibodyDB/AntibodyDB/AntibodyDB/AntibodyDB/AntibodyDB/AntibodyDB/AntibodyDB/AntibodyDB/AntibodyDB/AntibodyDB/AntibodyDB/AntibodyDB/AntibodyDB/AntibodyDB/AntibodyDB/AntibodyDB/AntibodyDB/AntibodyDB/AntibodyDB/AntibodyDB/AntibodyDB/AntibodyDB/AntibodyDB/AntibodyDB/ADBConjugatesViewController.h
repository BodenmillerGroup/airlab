//
//  ADBConjugatesViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 3/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBRightControllerViewController.h"
#import "ADBAddConjugateViewController.h"

@interface ADBConjugatesViewController : ADBRightControllerViewController <AddConjugateProtocol, UINavigationControllerDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andLot:(Lot *)lot;

@end
