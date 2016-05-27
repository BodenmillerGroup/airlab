//
//  PlateView.m
//  LabPad
//
//  Created by Raul Catena on 5/10/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "PlateView.h"

@implementation PlateView

- (id)initWithFrame:(CGRect)frame andRows:(int)rowNumber andColumns:(int)columnNumber{
    self = [super initWithFrame:frame];
    if (self) {
        self.columns = columnNumber;
        self.rows = rowNumber;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect{
     CGContextRef context = UIGraphicsGetCurrentContext();
     
     CGContextSetLineWidth(context, 1.0);
     [[UIColor blackColor] setStroke];
     
     // Draw a connected sequence of line segments
     
     CGFloat width = self.bounds.size.width;
     CGFloat height = self.bounds.size.height;
     CGPoint addLines[] =
     {
         CGPointMake(1, 1),
         CGPointMake(width -1, 1),
         CGPointMake(width -1, height -1),
         CGPointMake(1, height -1),
         CGPointMake(1, 1),
     };
     // Bulk call to add lines to the current path.
     // Equivalent to MoveToPoint(points[0]); for(i=1; i<count; ++i) AddLineToPoint(points[i]);
     CGContextAddLines(context, addLines, sizeof(addLines)/sizeof(addLines[0]));
     CGContextStrokePath(context);
     
     CGFloat gapColumns = width/_columns;
     CGFloat gapRows = height/_rows;
     
     // Adding columns
     int x;
     for (x=0; x<(_columns - 1); x++) {
         CGContextMoveToPoint(context, (gapColumns + 1  + (gapColumns *x)), 1);
         CGContextAddLineToPoint(context, gapColumns + (gapColumns *x), width - 1);
         CGContextStrokePath(context);
     }
     
     // Adding rows
     for (x=0; x<(_rows - 1); x++) {
         CGContextMoveToPoint(context, 1, (gapRows + 1  + (gapRows *x)));
         CGContextAddLineToPoint(context, (width - 1), gapRows + (gapRows *x));
         CGContextStrokePath(context);
     }
}

@end
