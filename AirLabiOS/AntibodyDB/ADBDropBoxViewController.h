//
//  ADBDropBoxViewController.h
// AirLab
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol DropboxFileAdd <NSObject>

-(void)fileAddedFromDB:(NSData *)data extension:(NSString *)extension name:(NSString *)name;

@end

@interface ADBDropBoxViewController : ADBMasterViewController

@property (nonatomic, retain) NSArray *arrayOfMetadata;
@property (nonatomic, retain) NSString *extension;
@property (nonatomic, strong) id<DropboxFileAdd>delegate;

@end
