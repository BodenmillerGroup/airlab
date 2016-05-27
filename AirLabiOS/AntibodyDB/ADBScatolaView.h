//
//  ADBScatolaView.h
// AirLab
//
//  Created by Raul Catena on 5/19/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScatolaViewDelegate <NSObject>

-(void)didTouchScatolaButtonWithTube:(id)tube andFrame:(CGRect)frame;
-(void)didTouchScatolaButtonAtX:(NSString *)x andY:(NSString *)y withFrame:(CGRect )frame;

@end

@interface ADBScatolaView : UIView <UIScrollViewDelegate>

@property (nonatomic, assign) id<ScatolaViewDelegate>delegate;

- (id)initWithFrame:(CGRect)frame andPlace:(Place *)place;
- (id)initWithFrame:(CGRect)frame andPlace:(Place *)place andScope:(NSArray *)scope;

@end
