//
//  ADBPartView.h
//  AntibodyDB
//
//  Created by Raul Catena on 6/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VistaPint.h"

@class ADBPartView;

@protocol PartViewDelegate <NSObject, UITableViewDataSource, UITableViewDelegate>

-(void)textViewActive:(UITextView *)textView;
-(void)textViewInActive:(UITextView *)textView;
-(void)moveFromIndex:(int)index pixels:(float)pixels;
-(void)isDoodling:(BOOL)isDood;
-(void)didDeleteSection:(ADBPartView *)part;
-(void)reload;

@end

@interface ADBPartView : UIView <UITextViewDelegate, Pintado, UIWebViewDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) id<PartViewDelegate>delegate;
@property (nonatomic, strong) UIWebView *webView;

- (id)initWithFrame:(CGRect)frame andPart:(Part *)part;

@end
