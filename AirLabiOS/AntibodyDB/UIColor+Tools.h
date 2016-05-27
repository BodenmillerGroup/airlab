//
//  UIColor+Tools.h
// AirLab
//
//  Created by Raul Catena on 8/6/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Tools)
- (UIColor *)colorByDarkeningColor;
- (UIColor *)colorByChangingAlphaTo:(CGFloat)newAlpha;
@end
