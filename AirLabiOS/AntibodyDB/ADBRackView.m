//
//  ADBRackView.m
// AirLab
//
//  Created by Raul Catena on 5/19/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBRackView.h"
#import "ADBPlaceView.h"

#define WIDTH_GRID 90.0f

@interface ADBRackView(){
    int rows;
    int columns;
}

@property (nonatomic, strong) Place *place;

@end

@implementation ADBRackView

- (id)initWithFrame:(CGRect)frame andPlace:(Place *)place
{
    self = [super initWithFrame:frame];
    if (self) {
        self.place = place;
        rows = place.plaRows.intValue;
        columns = place.plaColumns.intValue;
        self.backgroundColor = [UIColor whiteColor];
        self.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        
    }
    return self;
}

-(void)setUpButtons{
    /*ADBAppDelegate *delegate = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    CGFloat width = self.bounds.size.width;
    CGFloat gapColumns = (width - WIDTH_GRID*2)/columns;
	CGFloat gapRows = (width - WIDTH_GRID*2)/rows;
    int rowNumber = 0;
    int columnNumber = 0;
    
    NSLog(@"Row number %i, column number %i", rowNumber, columnNumber);
    
    for(int x = 0; x<columns*rows; x++){
        
        NSLog(@"Row number %i, column number %i", rowNumber, columnNumber);
        
        NSArray *array = [General searchDataBaseForClass:@"Place" withDictionaryOfTerms:[NSDictionary dictionaryWithObjects:@[[NSString stringWithFormat:@"%i", x], self.place] forKeys:@[@"plaX", @"parent"]] sortBy:@"plaY" ascending:YES inMOC:delegate.managedObjectContext];
        
        CGRect aFrame = CGRectMake(WIDTH_GRID + columnNumber * gapColumns + 2, WIDTH_GRID + rowNumber * gapRows + 2, gapColumns - 4, gapRows - 4);
        
        if(array.count > 0){
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ADBPlaceView" owner:self options:nil];
            ADBPlaceView *placeView = [topLevelObjects objectAtIndex:0];
            placeView.frame = aFrame;
            placeView.place = (Place *)array.lastObject;
            placeView.tag = x;
            placeView.backgroundColor = [UIColor yellowColor];
            [self addSubview:placeView];
            
        }else{
            UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
            but.tag = x;
            but.frame = aFrame;//CGRectMake(WIDTH_GRID + x * 30, WIDTH_GRID + rowNumber * 30, 25, 25);
            but.backgroundColor = [UIColor yellowColor];
            [but setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            [General addBorderToButton:but withColor:[UIColor orangeColor]];
            [self addSubview:but];
        }
        if((x+1)%columns == 0 && x!=0){rowNumber++;columnNumber = 0;}
        if(x%columns == 0 && x != 0)rowNumber++;
    }*/
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	CGContextSetLineWidth(context, 1.0);
	[[UIColor blackColor] setStroke];
	
    // Draw a connected sequence of line segments
	
	CGFloat width = self.bounds.size.width;
    CGPoint addLines[] =
    {
        CGPointMake(WIDTH_GRID, WIDTH_GRID),
        CGPointMake((width - WIDTH_GRID), WIDTH_GRID),
        CGPointMake((width - WIDTH_GRID), (width - WIDTH_GRID)),
        CGPointMake(WIDTH_GRID, (width - WIDTH_GRID)),
        CGPointMake(WIDTH_GRID, WIDTH_GRID),
    };
	// Bulk call to add lines to the current path.
    // Equivalent to MoveToPoint(points[0]); for(i=1; i<count; ++i) AddLineToPoint(points[i]);
    CGContextAddLines(context, addLines, sizeof(addLines)/sizeof(addLines[0]));
    CGContextStrokePath(context);
	
	CGFloat gapColumns = (width - WIDTH_GRID*2)/columns;
	CGFloat gapRows = (width - WIDTH_GRID*2)/rows;
	
	// Adding columns
	int x;
	for (x=0; x<(columns - 1); x++) {
		CGContextMoveToPoint(context, ((gapColumns + WIDTH_GRID) + (gapColumns *x)), WIDTH_GRID);
		CGContextAddLineToPoint(context, (gapColumns + WIDTH_GRID) + (gapColumns *x), (width - WIDTH_GRID));
		CGContextStrokePath(context);
	}
	
	// Adding columns
	for (x=0; x<(rows - 1); x++) {
		CGContextMoveToPoint(context, WIDTH_GRID, ((gapRows + WIDTH_GRID) + (gapRows *x)));
		CGContextAddLineToPoint(context, (width - WIDTH_GRID), ((gapRows + WIDTH_GRID) + (gapRows *x)));
		CGContextStrokePath(context);
	}
    
    ADBAppDelegate *delegate = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    int rowNumber = 0;
    int columnNumber = 0;
    
    for(int x = 0; x<columns*rows; x++){
        
        NSArray *array = [General searchDataBaseForClass:PLACE_DB_CLASS withDictionaryOfTerms:[NSDictionary dictionaryWithObjects:@[[NSString stringWithFormat:@"%i", x], self.place] forKeys:@[@"plaX", @"parent"]] sortBy:@"plaY" ascending:YES inMOC:delegate.managedObjectContext];
        
        CGRect aFrame = CGRectMake(WIDTH_GRID + columnNumber * gapColumns + 2, WIDTH_GRID + rowNumber * gapRows + 2, gapColumns - 4, gapRows - 4);
        
        if(array.count > 0){
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ADBPlaceView" owner:self options:nil];
            ADBPlaceView *placeView = [topLevelObjects objectAtIndex:0];
            [placeView.button addTarget:self action:@selector(touchedPlace:) forControlEvents:UIControlEventTouchUpInside];
            placeView.frame = aFrame;
            placeView.place = (Place *)array.lastObject;
            placeView.tag = x;
            [self addSubview:placeView];
            
        }else{
            UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
            but.tag = x;
            but.frame = aFrame;//CGRectMake(WIDTH_GRID + x * 30, WIDTH_GRID + rowNumber * 30, 25, 25);
            //[but setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            [but addTarget:self action:@selector(touchedEmpty:) forControlEvents:UIControlEventTouchUpInside];
            [General addBorderToButton:but withColor:[UIColor orangeColor]];
            [self addSubview:but];
        }
        if (columns == 1 && x == 0) {
            rowNumber ++;
        }else if((x+1)%columns == 0 && x!=0){rowNumber++;columnNumber = 0;}
        else columnNumber ++;
        //if(x%columns == 0 && x != 0)rowNumber++;
    }
}

-(void)touchedEmpty:(UIButton *)sender{
    [self.delegate didTouchButtonAtX:[NSString stringWithFormat:@"%li", (long)sender.tag] andY:nil withFrame:sender.frame];
}

-(void)touchedPlace:(UIButton *)sender{
    ADBPlaceView *placeV = (ADBPlaceView *)sender.superview;
    [self.delegate didTouchButtonWithPlace:placeV.place];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{
	for (UIView *aView in self.subviews) {
		aView.contentMode = UIViewContentModeRedraw;
		[aView setNeedsDisplay];
		if ([aView isKindOfClass:[UIButton class]]) {
			[[(UIButton *)aView titleLabel]setContentScaleFactor:scale];
			[[(UIButton *)aView titleLabel]setNeedsDisplay];
		}
	}
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return self;
}

@end
