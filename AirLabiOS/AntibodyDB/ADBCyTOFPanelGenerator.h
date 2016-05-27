//
//  ADBCyTOFPanelGenerator.h
//  AirLab
//
//  Created by Raul Catena on 6/29/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADBMasterViewController.h"

@interface ADBCyTOFPanelGenerator : NSObject

-(void)generateCyTOFString:(int)cytofVersion withPanel:(Panel *)panel andLinkers:(NSArray *)linkers fromVC:(ADBMasterViewController *)controller;

@end
