//
//  ADBPlaceView.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/19/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ADBPlaceView : UIView

@property (nonatomic, weak) IBOutlet UIButton *button;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, strong) Place *place;

- (id)initWithFrame:(CGRect)frame andPlace:(Place *)aPlace;

@end
