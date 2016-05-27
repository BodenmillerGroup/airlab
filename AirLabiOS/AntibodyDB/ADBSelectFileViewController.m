//
//  ADBDropBoxViewController.h
// AirLab
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBSelectFileViewController.h"
//#import "CustomWebView.h"


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
        request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                                 [NSPredicate predicateWithFormat:@"catchedInfo.length > 0"],
                                                                                 [NSPredicate predicateWithFormat:@"groupPerson = %@", [[ADBAccountManager sharedInstance]currentGroupPerson]]
                                                                                 ]];
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
    cell.tintColor = [UIColor orangeColor];
    [self setGrayColorInTableText:cell];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    File *file = [_fetchedResultsController objectAtIndexPath:indexPath];
    if (file) {
        [General showFile:file AndPushInNavigationController:self.navigationController];
    }
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
    
    NSArray *previous = [General searchDataBaseForClass:FILE_DB_CLASS sortBy:[[IPImporter getInstance]keyOfObject:FILE_DB_CLASS] ascending:YES inMOC:self.managedObjectContext];
    if (previous.count > 0) {
        for (File *file in previous) {
            if (data.length == [[[file.catchedInfo componentsSeparatedByString:@"|"]lastObject]intValue]) {
                [General showOKAlertWithTitle:@"This file has been already downloaded from Dropbox into AirLab" andMessage:[NSString stringWithFormat:@"%@.%@", name, extension] delegate:self];
                return;
            }
        }
    }
    
    File *aFile = (File *)[General newObjectOfType:FILE_DB_CLASS saveContext:YES];
    aFile.zetData = data;
    aFile.catchedInfo = [NSString stringWithFormat:@"%@|%lu", name, (unsigned long)data.length];
    aFile.filSize = [NSString stringWithFormat:@"%lu", (unsigned long)data.length];
    aFile.filExtension = extension;
    aFile.filHash = [NSString stringWithFormat:@"%@_%@", [General randomStringWithLength:2], [General randomStringWithLength:18]];
    [General saveContextAndRoll];
    
    aFile.zetUploadData = data;
    [General saveContextAndRoll];
}

//This needs Subclass
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [super filterContentForSearchText:searchText scope:scope];
    
    if (searchText != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"catchedInfo contains [cd] %@", searchText];
        
        [self.fetchedResultsController.fetchRequest setPredicate:[NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, nil]]];
        [NSFetchedResultsController deleteCacheWithName:@"allCache"];
        
    }else {
        [self.fetchedResultsController.fetchRequest setPredicate:self.previousPredicate];
        [NSFetchedResultsController deleteCacheWithName:@"allCache"];
    }
    [self refreshTable];
    NSLog(@"results: %lu", (unsigned long)[[self.fetchedResultsController fetchedObjects]count]);
    self.searchDisplayController.searchBar.showsCancelButton = YES;
}


@end
