//
//  ADBJsonDicEditorViewController.h
//  AirLab
//
//  Created by Raul Catena on 7/13/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol JsonEditor <NSObject>

-(void)didEditJsonDict:(NSMutableDictionary *)jsonDict;

@end

@interface ADBJsonDicEditorViewController : ADBMasterViewController

@property (nonatomic, weak) id<JsonEditor>delegate;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andJsonDict:(NSDictionary *)dict;

@end
