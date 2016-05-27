//
//  ADBButtonWithIndexPath.h
//  AntibodyDB
//
//  Created by Raul Catena on 6/24/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADBButtonWithIndexPath : UIButton

@property (nonatomic, strong) NSIndexPath *indexPath;
- (id)initWithFrame:(CGRect)frame andIndexPath:(NSIndexPath *)ip;

@end
