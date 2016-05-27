//
//  ADBScatolaView.m
// AirLab
//
//  Created by Raul Catena on 5/19/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBScatolaView.h"
#import "ADBTubeButton.h"

#define WIDTH_GRID 90.0f

@interface ADBScatolaView(){
    
    int rows;
    int columns;
}

@property (nonatomic, strong) Place *place;
@property (nonatomic, strong) NSArray *scope;

@end

@implementation ADBScatolaView

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

- (id)initWithFrame:(CGRect)frame andPlace:(Place *)place andScope:(NSArray *)scope{
    self = [super initWithFrame:frame];
    if (self) {
        self.place = place;
        self.scope = scope;
        rows = place.plaRows.intValue;
        columns = place.plaColumns.intValue;
        self.backgroundColor = [UIColor whiteColor];
        self.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	CGContextSetLineWidth(context, 1.0);
	[[UIColor blackColor] setStroke];
	
    // Draw a connected sequence of line segments
	
	CGFloat width = self.bounds.size.width;
    /*CGPoint addLines[] =
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
    CGContextStrokePath(context);*/
	
	CGFloat gapColumns = (width - WIDTH_GRID*2)/columns;
	CGFloat gapRows = (width - WIDTH_GRID*2)/rows;
	
	// Adding columns
	/*int x;
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
	}*/
    
    int rowNumber = 0;
    int columnNumber = 0;
    ADBAppDelegate *delegate = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    for(int x = 0; x<columns*rows; x++){
        
        NSArray *array = [General searchDataBaseForClass:PLACE_DB_CLASS withDictionaryOfTerms:[NSDictionary dictionaryWithObjects:@[[NSString stringWithFormat:@"%i", x], self.place] forKeys:@[@"plaX", @"parent"]] sortBy:@"plaY" ascending:YES inMOC:delegate.managedObjectContext];
        
        
        CGRect aFrame = CGRectMake(WIDTH_GRID + columnNumber * gapColumns + 2, WIDTH_GRID + rowNumber * gapRows + 2, gapColumns - 4, gapRows - 4);
        if(array.count > 0 && [(Place *)array.lastObject tubes].count > 0){
            Tube * tube = [[(Place *)array.lastObject tubes]anyObject];
            ADBTubeButton *placeView = [[ADBTubeButton alloc]initWithFrame:aFrame andTube:tube];
            placeView.tag = x;
            [placeView addTarget:self action:@selector(touchedPlace:) forControlEvents:UIControlEventTouchUpInside];
            [General addBorderToButton:placeView withColor:[UIColor lightGrayColor]];
            [self addSubview:placeView];
            
            for (Place *scopePlace in _scope) {
                if ([placeView.tube isMemberOfClass:[LabeledAntibody class]]) {
                    if ([(LabeledAntibody *)placeView.tube place] == scopePlace) {
                        placeView.backgroundColor = [UIColor orangeColor];
                        [placeView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    }
                }
            }
            
        }else{
            UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
            but.tag = x;
            but.frame = aFrame;
            [but addTarget:self action:@selector(touchedEmpty:) forControlEvents:UIControlEventTouchUpInside];
            [but setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            [General addBorderToButton:but withColor:[UIColor lightGrayColor]];
            [self addSubview:but];
        }
        if((x+1)%columns == 0 && x!=0){rowNumber++;columnNumber = 0;}
        else columnNumber++;
    }
}

-(void)touchedEmpty:(UIButton *)sender{
    [self.delegate didTouchScatolaButtonAtX:[NSString stringWithFormat:@"%li", (long)sender.tag] andY:nil withFrame:sender.frame];
}

-(void)touchedPlace:(ADBTubeButton *)sender{
    [self.delegate didTouchScatolaButtonWithTube:sender.tube andFrame:sender.frame];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
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