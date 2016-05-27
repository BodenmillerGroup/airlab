//
//  ADBTagsViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 3/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"


@protocol SelectedTagProtocol;

@interface ADBTagsViewController : ADBMasterViewController

@property (nonatomic, weak) id<SelectedTagProtocol>delegate;

@end

@protocol SelectedTagProtocol <NSObject>

-(void)didSelectTag:(Tag *)aTag;

@end
