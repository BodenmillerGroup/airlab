//
//  ADBDropBoxViewController.h
// AirLab
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "ADBMasterViewController.h"
#import "ADBDropBoxViewController.h"

@protocol AddFileToPart <NSObject>

-(void)selectedFile:(File *)file;

@end

@interface ADBSelectFileViewController : ADBMasterViewController<DropboxFileAdd>

@property (nonatomic, assign) id<AddFileToPart>delegate;


@end


