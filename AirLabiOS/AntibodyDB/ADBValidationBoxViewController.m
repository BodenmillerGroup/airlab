//
//  ADBValidationBoxViewController.m
// AirLab
//
//  Created by Raul Catena on 8/13/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBValidationBoxViewController.h"

@interface ADBValidationBoxViewController ()

@property (nonatomic, strong) NSMutableDictionary *json;

@end

@implementation ADBValidationBoxViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andJson:(NSDictionary *)json
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.json = json.mutableCopy;
    }
    return self;
}

-(void)trafficLightSegmentedControl{
    for (int i=0; i<[_valoration.subviews count]; i++)
    {
        UIColor *tintcolor=[UIColor colorWithRed:1-(float)i*0.5f green:(float)i*0.5f blue:0.0f alpha:1.0f];
        [[_valoration.subviews objectAtIndex:i] setTintColor:tintcolor];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[IPFetchObjects getInstance]addFilesForGroupServerWithBlock:nil];
    
    [self trafficLightSegmentedControl];
    if(_json)[self setPrevious];
    else self.json = [NSMutableDictionary dictionary];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.preferredContentSize = self.view.bounds.size;
    
    [General addBorderToButton:_addFile withColor:[UIColor orangeColor]];
}

-(void)fileButton{
    [_fileArea setImage:[UIImage imageNamed:@"fileb.png"] forState:UIControlStateNormal];
    [_fileArea addTarget:self action:@selector(showFile) forControlEvents:UIControlEventTouchUpInside];
}

-(void)showFile{
    NSArray *results = [General searchDataBaseForClass:FILE_DB_CLASS withTerm:[_json valueForKey:@"file"] inField:@"filFileId" sortBy:@"filFileId" ascending:YES inMOC:self.managedObjectContext];
    File *file = results.lastObject;
    
    if (file) {
        [General showFile:file AndPushInNavigationController:self.navigationController];
    }
}

-(void)setPrevious{
    [_notes setText:[_json valueForKey:@"note"]];
    [_application setSelectedSegmentIndex:[[_json valueForKey:@"app"]intValue]];
    if([_json valueForKey:@"surface"])[_surface setSelectedSegmentIndex:[[_json valueForKey:@"surface"]intValue]];
    else [_surface setSelectedSegmentIndex:2];
    if([_json valueForKey:@"saponin"])[_saponin setSelectedSegmentIndex:[[_json valueForKey:@"saponin"]intValue]];
    else [_saponin setSelectedSegmentIndex:2];
    if([_json valueForKey:@"metoh"])[_metoh setSelectedSegmentIndex:[[_json valueForKey:@"metoh"]intValue]];
    else [_metoh setSelectedSegmentIndex:2];
    [_cellLine setText:[_json valueForKey:@"sample"]];
    [_negCellLine setText:[_json valueForKey:@"negSample"]];
    [_valoration setSelectedSegmentIndex:[[_json valueForKey:@"val"]intValue]];
    [_validation setOn:[[_json valueForKey:@"isVal"]boolValue]];
    if ([_json valueForKey:@"file"]) {
        [self fileButton];
    }
}

-(void)done{
    BOOL new = NO;
    if(_json.allKeys.count <=1){//Only picture maybe
        new = YES;
    }
    
    if(_validation.isOn){
        NSLog(@"Val is on %i %i", _cellLine.text.length, _negCellLine.text.length);
        if(_cellLine.text.length == 0 || _negCellLine.text.length == 0){
            [General showOKAlertWithTitle:@"If you mark this as a validation note, please indicate the positive and negative cell lines / samples" andMessage:nil delegate:self];
            return;
        }
    }
    
    [_json setValue:_notes.text forKey:@"note"];
    [_json setValue:[NSString stringWithFormat:@"%i", _application.selectedSegmentIndex] forKey:@"app"];
    [_json setValue:_cellLine.text forKey:@"sample"];
    [_json setValue:_negCellLine.text forKey:@"negSample"];
    [_json setValue:[NSString stringWithFormat:@"%i", _valoration.selectedSegmentIndex] forKey:@"val"];
    [_json setValue:[NSString stringWithFormat:@"%i", _surface.selectedSegmentIndex] forKey:@"surface"];
    [_json setValue:[NSString stringWithFormat:@"%i", _saponin.selectedSegmentIndex] forKey:@"saponin"];
    [_json setValue:[NSString stringWithFormat:@"%i", _metoh.selectedSegmentIndex] forKey:@"metoh"];
    [_json setValue:[NSString stringWithFormat:@"%i", _validation.on] forKey:@"isVal"];
    [_json setValue:[[[ADBAccountManager sharedInstance]currentGroupPerson]gpeGroupPersonId] forKey:@"grp"];
    
    if (new == YES)[self.delegate didAddValidationNote:[NSDictionary dictionaryWithDictionary:_json]];
    else [self.delegate didModifyValidationNote:[NSDictionary dictionaryWithDictionary:_json]];
    
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if (textView.tag == 1) {
        textView.tag = 0;
        textView.text = nil;
    }
}

-(void)addFile:(id)sender{
    ADBSelectFileViewController *files = [[ADBSelectFileViewController alloc]init];
    files.delegate = self;
    [self showModalWithCancelButton:files fromVC:self withPresentationStyle:UIModalPresentationFormSheet];
}

-(void)selectedFile:(File *)file{
    [_json setValue:file.filFileId forKey:@"file"];
    [self fileButton];
    [self dismissModalOrPopover];
}


@end
