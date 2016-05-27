//
//  CustomWebView.h
//  LabPad
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomWebView : UIWebView 
{
    UIScrollView* _view;
    id<UIScrollViewDelegate> origDelegate;
    id<UIScrollViewDelegate> newDelegate;
}

//@property (nonatomic, retain) UIScrollView *view;
+ (CustomWebView *) proxyScrollViewWithScrollView: (UIScrollView*) scrollView;


@end
