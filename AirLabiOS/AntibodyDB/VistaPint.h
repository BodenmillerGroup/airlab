//
//  DrawingView.h
//  LabPad
//
//  Created by Raul Catena on 6/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sitio.h"

@protocol Pintado;

@interface VistaPint : UIView{

    CGContextRef offScreenBuffer;
    BOOL doneLoading;
    CGPoint point0;
    CGPoint point1;
    CGPoint point2;
    CGPoint point3;
}

//@property (nonatomic, retain) NSMutableArray *pointArray;
@property (nonatomic, retain) Sitio *unlugar;
@property (nonatomic, retain) Sitio *lugaranterior;
@property (nonatomic, retain) NSData *previousData;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) id<Pintado>delegate;
@property (nonatomic, retain) UIColor *color;

-(CGContextRef)setUpBuffer;
-(void)resetupBuffer;
-(void)drawToBuffer;
-(id)initWithFrame:(CGRect)frame andData:(NSData *)data orImage:(UIImage *)imageToInit;
-(void)save;
-(void)getColor;

@end

@protocol Pintado <NSObject>

-(int)colorInt;
-(BOOL)isDoodling;
-(void)dataToSave:(NSData *)data;

@end
