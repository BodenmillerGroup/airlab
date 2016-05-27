//
//  ADBRotatory.h
//  AirLab
//
//  Created by Raul Catena on 11/3/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADBRotatoryProtocol.h"
#import "ADBSector.h"

@interface ADBRotatory : UIControl

@property (weak) id <SMRotaryProtocol> delegate;
@property (nonatomic, strong) UIView *container;
@property int numberOfSections;

@property CGAffineTransform startTransform;
@property (nonatomic, strong) NSMutableArray *sectors;
@property int currentSector;

@property (nonatomic, strong) NSMutableArray *imagesArray;

- (id) initWithFrame:(CGRect)frame andDelegate:(id)del withSections:(int)sectionsNumber;
-(void)rotate;

@end
