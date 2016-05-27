//
//  ADBAddRoomViewController.m
// AirLab
//
//  Created by Raul Catena on 5/16/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddRoomViewController.h"

@interface ADBAddRoomViewController ()

@end

@implementation ADBAddRoomViewController

@synthesize delegate;

@synthesize create = _create;
@synthesize nameHab = _nameHab;
@synthesize place = _place;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPlace:(Place *)place
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.place = place;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [General addBorderToButton:_create withColor:[UIColor orangeColor]];
    if(self.place){
        [_create setTitle:@"Update" forState:UIControlStateNormal];
    }
    [_create addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    
    [self.nameHab becomeFirstResponder];
}

-(void)add{
    
    NSString *message = [General returnMessageAftercheckName:_nameHab.text lenghtTo:20];
    if(message){[General showOKAlertWithTitle:message andMessage:nil delegate:self];return;}
    
    if(self.place){
        self.place.plaName = _nameHab.text;
    }else{
        self.place = (Place *)[General newObjectOfType:PLACE_DB_CLASS saveContext:NO];
        self.place.plaType = @"hab";
    }
    _place.plaName = _nameHab.text;
        
    [self.delegate didAddHabitacion:_place];
}


@end
