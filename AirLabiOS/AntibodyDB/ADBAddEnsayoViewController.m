//
//  ADBAddEnsayoViewController.m
// AirLab
//
//  Created by Raul Catena on 6/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddEnsayoViewController.h"

@interface ADBAddEnsayoViewController ()

@end

@implementation ADBAddEnsayoViewController

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
}

-(void)done{
    if (_titleField.text.length == 0) {
        [General showOKAlertWithTitle:@"Please add a title" andMessage:nil delegate:self];
        return;
    }else{
        if (_titleField.text.length > 200) {
            [General showOKAlertWithTitle:@"Title is too long" andMessage:nil delegate:self];
        }
    }
    
    if (_purpose.text.length == 0) {
        [General showOKAlertWithTitle:@"Please add a purpose" andMessage:nil delegate:self];
        return;
    }
    
    if (_hypothesis.text.length == 0) {
        [General showOKAlertWithTitle:@"Please add a hypothesis" andMessage:nil delegate:self];
        return;
    }
    Ensayo *ensayo = (Ensayo *)[General newObjectOfType:ENSAYO_DB_CLASS saveContext:YES];
    ensayo.enyTitle = _titleField.text;
    ensayo.enyPurpose = _purpose.text;
    ensayo.enyHypothesis = _hypothesis.text;
    [self.delegate didAddEnsayo:ensayo];
    
}

@end
