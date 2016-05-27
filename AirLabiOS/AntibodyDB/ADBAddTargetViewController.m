//
//  ADBAddTargetViewController.m
// AirLab
//
//  Created by Raul Catena on 5/22/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddTargetViewController.h"

@interface ADBAddTargetViewController ()

@property (nonatomic, strong) Protein *protein;

@end

@implementation ADBAddTargetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andProtein:(Protein *)protein
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.protein = protein;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [General addBorderToButton:self.createButton withColor:[UIColor orangeColor]];
}

- (IBAction)create:(UIButton *)sender {
    NSString *message;
    message = [General returnMessageAftercheckName:_name.text lenghtTo:20];
    if(message){
        [General showOKAlertWithTitle:message andMessage:nil delegate:self];
        return;
    }
    NSArray *check  = [General searchDataBaseForClass:PROTEIN_DB_CLASS withTerm:_name.text inField:@"proName" sortBy:@"proName" ascending:YES inMOC:self.managedObjectContext];
    if(check.count > 0){
        [General showOKAlertWithTitle:@"Protein exists" andMessage:@"This protein already exists in the database, make sure is a different one and then use a different name" delegate:self];
        return;
    }
    Protein *protein = (Protein *)[General newObjectOfType:PROTEIN_DB_CLASS saveContext:NO];
    protein.proName = _name.text;
    protein.proDescription = _protDescription.text;
    NSString *code = [_name.text stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    protein.openBisCode = code.uppercaseString;
        
    [self.delegate didAddTarget:protein];
}

@end
