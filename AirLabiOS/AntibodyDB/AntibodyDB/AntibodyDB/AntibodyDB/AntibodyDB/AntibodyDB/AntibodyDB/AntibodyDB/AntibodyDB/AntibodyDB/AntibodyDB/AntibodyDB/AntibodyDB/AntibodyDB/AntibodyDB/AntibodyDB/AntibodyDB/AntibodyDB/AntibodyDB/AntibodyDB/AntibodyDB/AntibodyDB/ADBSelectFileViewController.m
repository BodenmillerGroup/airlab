//
//  ADBDropBoxViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBSelectFileViewController.h"
#import "CustomWebView.h"


@interface ADBSelectFileViewController () <DBRestClientDelegate>

- (NSString*)filePath;

@end

@implementation ADBSelectFileViewController

@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - View lifecycle

- (NSString*)filePath {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"DBFolderCacheT"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Select File";
    [self setTheTableviewWithStyle:UITableViewStyleGrouped];
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    [but setImage:[UIImage imageNamed:@"DB.png"] forState:UIControlStateNormal];
    [but setBounds:CGRectMake(0, 0, 30, 30)];
    [but addTarget:self action:@selector(dropbox:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:but];
}

-(void)dropbox:(UIButton *)sender{
    //Add new file provider using extensions //RCF
    //[self unlinkDropBox];
    if (![self isDropBoxLinked]){
        NSLog(@"Not linked");
        [self linkDropBox];
    }else NSLog(@"linked");
    [[self restClient] loadMetadata:@"/"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:FILE_DB_CLASS];
        request.predicate = [NSPredicate predicateWithFormat:@"catchedInfo.length > 0"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"filFileId" ascending:YES]];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];//TODO add section name keypath with protein or epitope
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fetchedResultsController.fetchedObjects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"PanelCell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    File *file = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [[file.catchedInfo componentsSeparatedByString:@"|"]objectAtIndex:0];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    [self setGrayColorInTableText:cell];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    File *file = [_fetchedResultsController objectAtIndexPath:indexPath];
    ADBMasterViewController *master = [[ADBMasterViewController alloc]init];
    CustomWebView *custom = [[CustomWebView alloc]initWithFrame:self.view.frame];
    master.view = custom;
    NSString *mimeType = [General determineMimeType:file.filExtension];
    if (file.zetData) {
        [custom loadData:file.zetData MIMEType:mimeType textEncodingName:@"utf-8" baseURL:[NSURL URLWithString:@"http://localhost/"]];
    }else{
        [custom loadRequest:[General callToGetAPI:[NSString stringWithFormat:@"http://www.raulcatena.com/apiLabPad/app_photos/%@.%@", file.filHash, file.filExtension]]];
    }
    [self.navigationController pushViewController:master animated:YES];
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[tableView cellForRowAtIndexPath:indexPath] isSelected]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    File *file = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    [self.delegate selectedFile:file];
}

#pragma mark DropBoxDelegate

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    
    NSLog(@"Error loading metadata: %@", error);
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    
    NSArray* validExtensions = [General validExtensionsForFile];
    NSMutableArray* filePaths = [NSMutableArray new];
    for (DBMetadata* child in metadata.contents) {
        NSString* extension = [[child.path pathExtension] lowercaseString];
        if (!child.isDirectory && [validExtensions indexOfObject:extension] != NSNotFound) {
            [filePaths addObject:child];
        }
    }
    ADBDropBoxViewController *selectDB = [[ADBDropBoxViewController alloc]init];
    selectDB.delegate = self;
    selectDB.arrayOfMetadata = filePaths;
    [self showModalWithCancelButton:selectDB fromVC:self withPresentationStyle:UIModalPresentationPageSheet];
}

#pragma mark DropboxAddDelegate

-(void)fileAddedFromDB:(NSData *)data extension:(NSString *)extension name:(NSString *)name{
    File *aFile = (File *)[General newObjectOfType:FILE_DB_CLASS saveContext:YES];
    aFile.zetData = data;
    aFile.catchedInfo = [NSString stringWithFormat:@"%@|%i", name, data.length];
    aFile.filExtension = extension;
    aFile.filHash = [General randomStringWithLength:18];
    [General saveContextAndRoll];
    
    NSMutableURLRequest *request = [General fileUpload:data withName:aFile.filHash andExtension:extension];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response_, NSData *data_, NSError *error_){
        if (!data || [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]intValue] == 0) {
            aFile.zetUploadData = data;
        }else{
            [self refreshTable];
        }
    }];
    [self dismissModalOrPopover];
}


@end
