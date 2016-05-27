//
//  DrawingViewNew.m
//  LabPad
//
//  Created by Raul Catena on 6/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "VistaPint.h"
#import <QuartzCore/QuartzCore.h>

@implementation VistaPint

@synthesize unlugar = _unlugar;
@synthesize lugaranterior = _lugaranterior;
//@synthesize previousData = _previousData;
@synthesize image = _image;
@synthesize delegate;
@synthesize color = _color;



-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self resetupBuffer];
}

- (id)initWithFrame:(CGRect)frame andData:(NSData *)data orImage:(UIImage *)imageToInit
{
    self = [super initWithFrame:frame];
    if (self) {
        doneLoading = NO;
        self.backgroundColor = [UIColor clearColor];
        self.previousData = data;
        self.image = imageToInit;
        self.color = [UIColor blackColor];
        offScreenBuffer = [self setUpBuffer];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        offScreenBuffer = [self setUpBuffer];
    }
    return self;
}

-(CGContextRef)setUpBuffer{
    CGSize size = self.bounds.size;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(CFBridgingRetain(_previousData), size.width, size.height, 8, size.width * 4, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    return context;
}

-(void)resetupBuffer{
    offScreenBuffer = [self setUpBuffer];
}

-(void)save{NSLog(@"Saving part_____%@ %i", NSStringFromClass([self.superview class]), self.superview.subviews.count);
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    //UIGraphicsBeginImageContext(self.bounds.size);
    for (UIView *aView in self.superview.subviews) {
        if([aView isMemberOfClass:[VistaPint class]] || [aView isMemberOfClass:[UIImageView class]]){
            NSLog(@"Fundiendo %@", NSStringFromClass([aView class]));
            [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
        }
    }
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    NSData *data = UIImageJPEGRepresentation(outputImage, 0.2);
    [self.delegate dataToSave:data];
    [General saveContextAndRoll];
    UIGraphicsEndImageContext();
}

-(void)drawToBuffer{
    if(point1.x > -1){
        float thickness = 3.5;
        if (self.color == [UIColor whiteColor]) {
            thickness = 25;
        }
        CGContextSetStrokeColorWithColor(offScreenBuffer, [_color CGColor]);
        CGContextSetLineCap(offScreenBuffer, kCGLineCapRound);
        CGContextSetLineWidth(offScreenBuffer, thickness);
        
        double x0 = (point0.x > -1) ? point0.x : point1.x; //after 4 touches we should have a back anchor point, if not, use the current anchor point
        double y0 = (point0.y > -1) ? point0.y : point1.y; //after 4 touches we should have a back anchor point, if not, use the current anchor point
        double x1 = point1.x;
        double y1 = point1.y;
        double x2 = point2.x;
        double y2 = point2.y;
        double x3 = point3.x;
        double y3 = point3.y;
        // Assume we need to calculate the control
        // points between (x1,y1) and (x2,y2).
        // Then x0,y0 - the previous vertex,
        //      x3,y3 - the next one.
        
        double xc1 = (x0 + x1) / 2.0;
        double yc1 = (y0 + y1) / 2.0;
        double xc2 = (x1 + x2) / 2.0;
        double yc2 = (y1 + y2) / 2.0;
        double xc3 = (x2 + x3) / 2.0;
        double yc3 = (y2 + y3) / 2.0;
        
        double len1 = sqrt((x1-x0) * (x1-x0) + (y1-y0) * (y1-y0));
        double len2 = sqrt((x2-x1) * (x2-x1) + (y2-y1) * (y2-y1));
        double len3 = sqrt((x3-x2) * (x3-x2) + (y3-y2) * (y3-y2));
        
        double k1 = len1 / (len1 + len2);
        double k2 = len2 / (len2 + len3);
        
        double xm1 = xc1 + (xc2 - xc1) * k1;
        double ym1 = yc1 + (yc2 - yc1) * k1;
        
        double xm2 = xc2 + (xc3 - xc2) * k2;
        double ym2 = yc2 + (yc3 - yc2) * k2;
        double smooth_value = 0.8;
        // Resulting control points. Here smooth_value is mentioned
        // above coefficient K whose value should be in range [0...1].
        float ctrl1_x = xm1 + (xc2 - xm1) * smooth_value + x1 - xm1;
        float ctrl1_y = ym1 + (yc2 - ym1) * smooth_value + y1 - ym1;
        
        float ctrl2_x = xm2 + (xc2 - xm2) * smooth_value + x2 - xm2;
        float ctrl2_y = ym2 + (yc2 - ym2) * smooth_value + y2 - ym2;
        
        CGContextMoveToPoint(offScreenBuffer, point1.x, point1.y);
        CGContextAddCurveToPoint(offScreenBuffer, ctrl1_x, ctrl1_y, ctrl2_x, ctrl2_y, point2.x, point2.y);
        CGContextStrokePath(offScreenBuffer);
        
        CGRect dirtyPoint1 = CGRectMake(point1.x-10, point1.y-10, 20, 20);
        CGRect dirtyPoint2 = CGRectMake(point2.x-10, point2.y-10, 20, 20);
        [self setNeedsDisplayInRect:CGRectUnion(dirtyPoint1, dirtyPoint2)];
        //[self setNeedsDisplay];
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    UITouch *touch = [touches anyObject];
    point0 = CGPointMake(-1, -1);
    point1 = CGPointMake(-1, -1); // previous previous point
    point2 = CGPointMake(-1, -1); // previous touch point
    point3 = [touch locationInView:self]; // current touch point
    [self getColor];
}

-(void)getColor{
    int colorCode = [self.delegate colorInt];
    if (colorCode == 2) {
        self.color = [UIColor greenColor];
    }else if (colorCode == 3){
        self.color = [UIColor redColor];
    }else if (colorCode == 4){
        self.color = [UIColor blueColor];
    }else if (colorCode == 5){
        self.color = [UIColor blackColor];
    }else if (colorCode == 6){
        self.color = [UIColor whiteColor];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self getColor];
    [self save];//No need if I call in journal viewWillDissapear
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (![self.delegate isDoodling]) {
        return;
    }
    UITouch *touch = [touches anyObject];
    point0 = point1;
    point1 = point2;
    point2 = point3;
    point3 = [touch locationInView:self];
    
    [self drawToBuffer];
}


- (void)drawRect:(CGRect)rect
{
    CGImageRef cgImage = CGBitmapContextCreateImage(offScreenBuffer);
    UIImage *imager = [[UIImage alloc]initWithCGImage:cgImage];
    CGImageRelease(cgImage);
    [imager drawInRect:self.bounds];
}

@end