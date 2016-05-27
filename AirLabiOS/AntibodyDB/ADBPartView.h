//
//  ADBPartView.h
// AirLab
//
//  Created by Raul Catena on 6/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VistaPint.h"

@class ADBPartView;

@protocol PartViewDelegate <NSObject>

-(void)textViewActive:(UITextView *)textView;
-(void)textViewInActive:(UITextView *)textView;
-(void)moveFromIndex:(int)index pixels:(float)pixels;
-(void)isDoodling:(BOOL)isDood;
-(void)didDeleteSection:(ADBPartView *)part;
-(void)reload;
-(void)detailedFile:(File *)file;

@end

@interface ADBPartView : UIView <UITextViewDelegate, Pintado, UIWebViewDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id<PartViewDelegate>delegate;
@property (nonatomic, strong) UIWebView *webView;

- (id)initWithFrame:(CGRect)frame andPart:(Part *)part;

@end
