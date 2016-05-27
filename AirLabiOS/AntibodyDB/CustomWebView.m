//
//  CustomWebView.m
//  LabPad
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "CustomWebView.h"

@implementation CustomWebView

- (id) initWithScrollView: (UIScrollView*) scrollView
{
    if(self != nil)
    {
        _view = scrollView;
        origDelegate = _view.delegate;
        [_view setDelegate:self];
        newDelegate = nil;
        
        return self;
    }
    
    return nil;
}


+ (CustomWebView *) proxyScrollViewWithScrollView: (UIScrollView*) scrollView
{
    CustomWebView* retVal = [[CustomWebView alloc] initWithScrollView:scrollView];
    
    return retVal;
}

- (BOOL)isKindOfClass:(Class)aClass
{
    return [_view isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass
{
    return [_view isMemberOfClass:aClass];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ( [super respondsToSelector:aSelector] )
        return YES;
    else {
        /* Here, test whether the aSelector message can     *
         * be forwarded to another object and whether that  *
         * object can respond to it. Return YES if it can.  */
        if([_view respondsToSelector:aSelector])
            return YES;
    }
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSMethodSignature *sig = [super methodSignatureForSelector:sel];
    
    if(!sig)
    {
        sig = [_view methodSignatureForSelector:sel];
    }
    
    return sig;
}

- (void)forwardInvocation:(NSInvocation *)inv
{
    NSLog(@"inv.selector: %@", NSStringFromSelector(inv.selector));
    
    if([_view respondsToSelector: inv.selector])
    {
        [inv invokeWithTarget: _view];
    }
}

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate
{
    newDelegate = delegate; 
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([origDelegate respondsToSelector:_cmd])
        [origDelegate performSelector:_cmd withObject:scrollView];
    if([newDelegate respondsToSelector:_cmd])
        [newDelegate performSelector:_cmd withObject:scrollView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView 
{
    if([origDelegate respondsToSelector:_cmd])
        [origDelegate performSelector:_cmd withObject:scrollView];
    if([newDelegate respondsToSelector:_cmd])
        [newDelegate performSelector:_cmd withObject:scrollView];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if([origDelegate respondsToSelector:_cmd])
        [origDelegate performSelector:_cmd withObject:scrollView];
    if([newDelegate respondsToSelector:_cmd])
        [newDelegate performSelector:_cmd withObject:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if([origDelegate respondsToSelector:_cmd])
        [origDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    if([newDelegate respondsToSelector:_cmd])
        [newDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if([origDelegate respondsToSelector:_cmd])
        [origDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if([newDelegate respondsToSelector:_cmd])
        [newDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if([origDelegate respondsToSelector:_cmd])
        [origDelegate performSelector:_cmd withObject:scrollView];
    if([newDelegate respondsToSelector:_cmd])
        [newDelegate performSelector:_cmd withObject:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if([origDelegate respondsToSelector:_cmd])
        [origDelegate performSelector:_cmd withObject:scrollView];
    if([newDelegate respondsToSelector:_cmd])
        [newDelegate performSelector:_cmd withObject:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if([origDelegate respondsToSelector:_cmd])
        [origDelegate performSelector:_cmd withObject:scrollView];
    if([newDelegate respondsToSelector:_cmd])
        [newDelegate performSelector:_cmd withObject:scrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if([newDelegate respondsToSelector:_cmd])
        [newDelegate performSelector:_cmd withObject:scrollView];
    if([origDelegate respondsToSelector:_cmd])
        return [origDelegate performSelector:_cmd withObject:scrollView];
    
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_2)
{
    if([origDelegate respondsToSelector:_cmd])
        [origDelegate performSelector:_cmd withObject:scrollView withObject:view];
    if([newDelegate respondsToSelector:_cmd])
        [newDelegate performSelector:_cmd withObject:scrollView withObject:view];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    if([origDelegate respondsToSelector:_cmd])
        [origDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    if([newDelegate respondsToSelector:_cmd])
        [newDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if([newDelegate respondsToSelector:_cmd])
        [newDelegate scrollViewShouldScrollToTop:scrollView];
    if([origDelegate respondsToSelector:_cmd])
        return [origDelegate scrollViewShouldScrollToTop:scrollView];
    
    return false;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    if([origDelegate respondsToSelector:_cmd])
        [origDelegate performSelector:_cmd withObject:scrollView];
    if([newDelegate respondsToSelector:_cmd])
        [newDelegate performSelector:_cmd withObject:scrollView];
}

@end
