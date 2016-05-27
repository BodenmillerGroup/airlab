//
//  ADBDropBoxViewController.m
// AirLab
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBDropBoxViewController.h"

@interface ADBDropBoxViewController (){
    int counter;
}

@property (nonatomic, strong) NSString *nameOfFile;
@property (nonatomic, strong) NSMutableArray *arraySelected;

@end

@implementation ADBDropBoxViewController

@synthesize arrayOfMetadata;
@synthesize delegate;
@synthesize extension = _extension;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Select File From your Dropbox's Apps/AirLab folder";
    [self setTheTableviewWithStyle:UITableViewStyleGrouped];
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc]initWithTitle:@"Disconnect DB" style:UIBarButtonItemStyleDone target:self action:@selector(unlinkDropBoxB)], [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)]];
}

-(void)unlinkDropBoxB{
    [self unlinkDropBox];
    [(ADBMasterViewController *)[[(UINavigationController *)self.presentingViewController viewControllers]lastObject] dismissModalOrPopover];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [arrayOfMetadata count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [(DBMetadata *)[self.arrayOfMetadata objectAtIndex:indexPath.row]filename];
    cell.tintColor = [UIColor orangeColor];
    
    if([_arraySelected containsObject:[NSNumber numberWithInt:(int)indexPath.row]])cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[tableView cellForRowAtIndexPath:indexPath] isSelected]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    if(!_arraySelected)_arraySelected = [NSMutableArray arrayWithCapacity:self.arrayOfMetadata.count];
    NSNumber *selected;
    for(NSNumber *number in _arraySelected){
        if(number.integerValue == indexPath.row)selected = number;
    }
    if(selected)[_arraySelected removeObject:selected];
    else [_arraySelected addObject:[NSNumber numberWithInt:(int)indexPath.row]];
    
    [self.tableView reloadData];
}

-(void)done{
    
    NSNumber *number = _arraySelected.lastObject;
    DBMetadata *pathMD = [self.arrayOfMetadata objectAtIndex:number.intValue];
    NSArray *comps = [pathMD.filename componentsSeparatedByString:@"."];
    self.extension = [comps lastObject];
    self.nameOfFile = [pathMD filename];
    [[self restClient]loadFile:pathMD.path intoPath:[self filePath]];
    
    [_arraySelected removeLastObject];
    
    counter = (int)_arraySelected.count;
}


- (NSString*)filePath {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"DBFolderCacheT"];
}

-(void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath{
    NSData *data = [NSData dataWithContentsOfFile:destPath];
    [self.delegate fileAddedFromDB:data extension:_extension name:_nameOfFile];
    if(counter == 0)[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    else [self done];
}

-(void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error{
    [General showOKAlertWithTitle:@"Download failed" andMessage:@"Check your Dropbox and internet connections" delegate:self];
}

@end