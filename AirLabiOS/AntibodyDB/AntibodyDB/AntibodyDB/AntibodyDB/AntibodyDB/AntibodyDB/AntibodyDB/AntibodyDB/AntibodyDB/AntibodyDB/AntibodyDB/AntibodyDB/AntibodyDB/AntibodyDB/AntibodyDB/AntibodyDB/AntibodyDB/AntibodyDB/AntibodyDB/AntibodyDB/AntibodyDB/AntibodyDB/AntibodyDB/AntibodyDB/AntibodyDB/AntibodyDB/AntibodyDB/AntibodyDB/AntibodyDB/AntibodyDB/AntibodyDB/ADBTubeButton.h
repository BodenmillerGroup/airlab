//
//  ADBTubeButton.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/20/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADBTubeButton : UIButton

@property (nonatomic, strong) id tube;

- (id)initWithFrame:(CGRect)frame andTube:(id)tube;

@end
