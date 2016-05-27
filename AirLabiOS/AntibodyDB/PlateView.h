//
//  PlateView.h
//  LabPad
//
//  Created by Raul Catena on 5/10/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlateView : UIView

@property (nonatomic, assign) int rows;
@property (nonatomic, assign) int columns;

- (id)initWithFrame:(CGRect)frame andRows:(int)rowNumber andColumns:(int)columnNumber;

@end
