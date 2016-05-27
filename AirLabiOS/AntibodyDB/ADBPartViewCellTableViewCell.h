//
//  ADBPartViewCellTableViewCell.h
//  AirLab
//
//  Created by Raul Catena on 7/3/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VistaPint.h"

@class ADBPartViewCellTableViewCell;

@protocol PartViewDelegate <NSObject>

-(void)textViewActive:(UITextView *)textView;
-(void)textViewInActive:(UITextView *)textView;
-(void)refreshTable;
-(void)isDoodling:(BOOL)isDood;
-(void)didDeleteSection:(ADBPartViewCellTableViewCell *)part;
-(void)detailedFile:(File *)file;

@end

@interface ADBPartViewCellTableViewCell : UITableViewCell <UITextViewDelegate, Pintado, UIWebViewDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id<PartViewDelegate>delegate;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) Part *part;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andPart:(Part *)part;
- (CGRect)frameCalculated;

@end

