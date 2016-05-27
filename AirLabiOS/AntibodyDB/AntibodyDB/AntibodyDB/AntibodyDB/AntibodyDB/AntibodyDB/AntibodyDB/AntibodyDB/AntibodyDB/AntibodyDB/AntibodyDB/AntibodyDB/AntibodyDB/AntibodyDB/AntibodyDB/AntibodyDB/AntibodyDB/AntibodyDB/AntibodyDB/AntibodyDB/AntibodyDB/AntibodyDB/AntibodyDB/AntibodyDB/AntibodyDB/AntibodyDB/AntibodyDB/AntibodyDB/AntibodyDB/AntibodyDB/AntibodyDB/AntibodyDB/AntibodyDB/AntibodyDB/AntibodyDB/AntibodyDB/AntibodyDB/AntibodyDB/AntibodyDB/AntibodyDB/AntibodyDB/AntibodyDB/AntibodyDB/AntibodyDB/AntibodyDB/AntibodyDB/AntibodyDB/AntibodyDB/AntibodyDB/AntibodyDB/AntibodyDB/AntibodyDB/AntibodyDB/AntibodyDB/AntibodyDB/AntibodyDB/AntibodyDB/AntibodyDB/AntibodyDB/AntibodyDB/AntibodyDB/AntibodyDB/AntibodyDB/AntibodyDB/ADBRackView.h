//
//  ADBRackView.h
//  AntibodyDB
//
//  Created by Raul Catena on 5/19/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RackViewDelegate <NSObject>

-(void)didTouchButtonWithPlace:(Place *)place;
-(void)didTouchButtonAtX:(NSString *)x andY:(NSString *)y withFrame:(CGRect )frame;

@end

@interface ADBRackView : UIView <UIScrollViewDelegate>

@property (nonatomic, assign) id<RackViewDelegate>delegate;

- (id)initWithFrame:(CGRect)frame andPlace:(Place *)place;

@end
