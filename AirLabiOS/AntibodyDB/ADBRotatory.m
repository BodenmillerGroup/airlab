//
//  ADBRotatory.m
//  AirLab
//
//  Created by Raul Catena on 11/3/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

//http://www.raywenderlich.com/9864/how-to-create-a-rotating-wheel-control-with-uikit

#import "ADBRotatory.h"

@interface ADBRotatory(){
    CGPoint touchPointAtBegining;
}

@property (nonatomic, strong) NSMutableArray *renderedImageViews;

- (void)drawWheel;
- (float) calculateDistanceFromCenter:(CGPoint)point;
- (void) buildSectorsEven;
- (void) buildSectorsOdd;
- (UIImageView *) getSectorByValue:(int)value;
@end

static float minAlphavalue = 0.6;
static float maxAlphavalue = 1.0;

@implementation ADBRotatory

static float deltaAngle;

@synthesize delegate, container, numberOfSections;

- (id) initWithFrame:(CGRect)frame andDelegate:(id)del withSections:(int)sectionsNumber images:(NSArray *)images andTitles:(NSArray *)titles
{
    // 1 - Call super init
    if ((self = [super initWithFrame:frame])) {
        // 2 - Set properties
        if (sectionsNumber != images.count || sectionsNumber != titles.count) {
            abort();
        }
        _names = titles;
        _imagesArray = images;
        self.numberOfSections = sectionsNumber;
        self.delegate = del;
        // 3 - Draw wheel
        [self drawWheel];
        
        self.currentSector = 0;
        

    }
    return self;
}

- (void) rotate {
    CGAffineTransform t = CGAffineTransformRotate(container.transform, -0.78);
    container.transform = t;
}

- (float) calculateDistanceFromCenter:(CGPoint)point {
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    float dx = point.x - center.x;
    float dy = point.y - center.y;
    return sqrt(dx*dx + dy*dy);
}



- (NSString *) getSectorName:(int)position {
    return [_names objectAtIndex:position];
}

- (void) drawWheel {
    // 1
    container = [[UIView alloc] initWithFrame:self.frame];
    // 2
    CGFloat angleSize = 2*M_PI/numberOfSections;
    // 3
    
    for (int i = 0; i < numberOfSections; i++) {
        // 4
        UIView *im = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.height/2, 40)];
        im.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
        im.layer.position = CGPointMake(container.bounds.size.width/2.0-container.frame.origin.x,
                                        container.bounds.size.height/2.0-container.frame.origin.y);
        im.transform = CGAffineTransformMakeRotation(angleSize*i);
        im.alpha = minAlphavalue;
        im.tag = i;
        if (i == 0) {
            im.alpha = maxAlphavalue;
        }
        // 5 - Set sector image
        
        
        UIImageView *sectorImage = [[UIImageView alloc] initWithFrame:CGRectMake(im.bounds.size.width - 40, 0, 40, 40)];
        _startTransform = container.transform;
        sectorImage.transform = CGAffineTransformRotate(_startTransform, i* -2*M_PI/numberOfSections);
        sectorImage.tag = i;
        UIImage *image = [UIImage imageNamed:[_imagesArray objectAtIndex:i]];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        sectorImage.image = image;
        if(_currentSector == i)sectorImage.tintColor = [UIColor orangeColor];
        else sectorImage.tintColor = [UIColor darkGrayColor];
        [im addSubview:sectorImage];
        // 6 - Add image view to container
        if(!_renderedImageViews)_renderedImageViews = [NSMutableArray arrayWithCapacity:_imagesArray.count];
        [_renderedImageViews addObject:sectorImage];
        [container addSubview:im];
    }
    // 7
    container.userInteractionEnabled = NO;
    [self addSubview:container];
    
    // 7.1 - Add background image
    //UIImageView *bg = [[UIImageView alloc] initWithFrame:self.frame];
    //bg.image = [UIImage imageNamed:@"swiss.png"];
    //[self addSubview:bg];
    UIImageView *mask = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 72, 72)];
    mask.image =[UIImage imageNamed:@"Icon-72.png"] ;
    mask.center = self.center;
    mask.center = CGPointMake(mask.center.x, mask.center.y+3);
    [self addSubview:mask];
    
    _sectors = [NSMutableArray arrayWithCapacity:numberOfSections];
    if (numberOfSections % 2 == 0) {
        [self buildSectorsEven];
    } else {
        [self buildSectorsOdd];
    }
}


- (void) buildSectorsOdd {
    // 1 - Define sector length
    CGFloat fanWidth = M_PI*2/numberOfSections;
    // 2 - Set initial midpoint
    CGFloat mid = 0;
    // 3 - Iterate through all sectors
    for (int i = 0; i < numberOfSections; i++) {
        ADBSector *sector = [[ADBSector alloc] init];
        // 4 - Set sector values
        sector.midValue = mid;
        sector.minValue = mid - (fanWidth/2);
        sector.maxValue = mid + (fanWidth/2);
        sector.sector = i;
        mid -= fanWidth;
        if (sector.minValue < - M_PI) {
            mid = -mid;
            mid -= fanWidth;
        }
        // 5 - Add sector to array
        [_sectors addObject:sector];
        NSLog(@"cl is %@", sector);
    }
}

- (void) buildSectorsEven {
    // 1 - Define sector length
    CGFloat fanWidth = M_PI*2/numberOfSections;
    // 2 - Set initial midpoint
    CGFloat mid = 0;
    // 3 - Iterate through all sectors
    for (int i = 0; i < numberOfSections; i++) {
        ADBSector *sector = [[ADBSector alloc] init];
        // 4 - Set sector values
        sector.midValue = mid;
        sector.minValue = mid - (fanWidth/2);
        sector.maxValue = mid + (fanWidth/2);
        sector.sector = i;
        if (sector.maxValue-fanWidth < - M_PI) {
            mid = M_PI;
            sector.midValue = mid;
            sector.minValue = fabsf(sector.maxValue);
            
        }
        mid -= fanWidth;
        NSLog(@"cl is %@", sector);
        // 5 - Add sector to array
        [_sectors addObject:sector];
    }
}

//Overriding
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    // 1 - Get touch position
    CGPoint touchPoint = [touch locationInView:self];
    touchPointAtBegining = touchPoint;
    _startTransform = container.transform;
    
    // 1.1 - Get the distance from the center
    float dist = [self calculateDistanceFromCenter:touchPoint];
    // 1.2 - Filter out touches too close to the center
    if (dist < 40 || dist > self.bounds.size.width/2)
    {
        [self.delegate tapped:_currentSector];
        // forcing a tap to be on the ferrule
        NSLog(@"ignoring tap (%f,%f)", touchPoint.x, touchPoint.y);
        return NO;
    }
    
    // 2 - Calculate distance from center
    float dx = touchPoint.x - container.center.x;
    float dy = touchPoint.y - container.center.y;
    // 3 - Calculate arctangent value
    deltaAngle = atan2(dy,dx);
    // 4 - Save current transform
    
    
    // 5 - Set current sector's alpha value to the minimum value
    UIImageView *im = [self getSectorByValue:_currentSector];
    im.alpha = minAlphavalue;
    
    return YES;
}

-(void)checkSectors:(CGFloat)radians{
    for (ADBSector
         *s in _sectors) {
        if (s.minValue > 0 && s.maxValue < 0) {
            if (s.maxValue > radians || s.minValue < radians) {
                _currentSector = s.sector;
            }
        }
        else if (radians > s.minValue && radians < s.maxValue) {
            _currentSector = s.sector;
        }
    }
    for(UIImageView *iv in _renderedImageViews){
        iv.tintColor = [UIColor darkGrayColor];
        iv.transform = CGAffineTransformRotate(container.transform, radians);
    }
    UIImageView *rendered = [_renderedImageViews objectAtIndex:_currentSector];
    rendered.tintColor = [UIColor orangeColor];
}

- (BOOL)continueTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    
    CGPoint pt = [touch locationInView:self];
    float dx = pt.x  - container.center.x;
    float dy = pt.y  - container.center.y;
    float ang = atan2(dy,dx);
    float angleDifference = deltaAngle - ang;
    container.transform = CGAffineTransformRotate(_startTransform, -angleDifference);
    
    CGFloat radians = atan2f(container.transform.b, container.transform.a);
    //NSLog(@"rad is %f", radians);
    [self checkSectors:radians];
    
    [self.delegate wheelDidChangeValue:[self getSectorName:_currentSector] index:_currentSector];
    
    return YES;
}

-(void)resetSectorsWithRadians:(CGFloat)radians{
    CGFloat newVal = 0.0;
    for (ADBSector
         *s in _sectors) {
        // 4 - Check for anomaly (occurs with even number of sectors)
        if (s.minValue > 0 && s.maxValue < 0) {
            if (s.maxValue > radians || s.minValue < radians) {
                // 5 - Find the quadrant (positive or negative)
                if (radians > 0) {
                    newVal = radians - M_PI;
                } else {
                    newVal = M_PI + radians;
                }
                _currentSector = s.sector;
            }
        }
        // 6 - All non-anomalous cases
        else if (radians > s.minValue && radians < s.maxValue) {
            newVal = radians - s.midValue;
            _currentSector = s.sector;
        }
    }
    
    //[self checkSectors:radians];
    
    // 7 - Set up animation for final rotation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    CGAffineTransform t = CGAffineTransformRotate(container.transform, -newVal);
    container.transform = t;
    [UIView commitAnimations];
}

- (void)endTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    CGPoint point = [touch locationInView:self];
    
    if (fabsf(point.x - touchPointAtBegining.x) <= 10.0f && fabsf(point.y - touchPointAtBegining.y) <= 10) {
        
        CGFloat radians = atan2f(container.transform.b, container.transform.a);
        
        //[self resetSectorsWithRadians:radians];
        
        CGFloat radiansTouch = atan2f(point.y-self.bounds.size.height/2, point.x - self.bounds.size.width/2);
        if(radians<0.0f)radians = radians + 2*M_PI;
        if(radiansTouch<0.0f)radiansTouch = radiansTouch + 2*M_PI;
        
        CGFloat delta = radians - radiansTouch - 2*M_PI/numberOfSections/2;//To have around the piece;
        if(delta > 0.0f)delta = delta - 2*M_PI;
        
        int sector = (int)fabsf(delta*numberOfSections/(2*M_PI));//Calculate and cast to int
        
        NSLog(@"Radioans wheel %f radioans touch %f", radians, radiansTouch);
        NSLog(@"Om sector %i delta %f", sector, delta);
        if(sector == numberOfSections)sector = 0;//There is chance to go +1. Security here
        [self.delegate tapped:(int)fabsf(sector)];
        return;
    }
    
    // 1 - Get current container rotation in radians
    CGFloat radians = atan2f(container.transform.b, container.transform.a);
    // 2 - Initialize new value
    // 3 - Iterate through all the sectors
    
    [self resetSectorsWithRadians:radians];
    
    UIImageView *im = [self getSectorByValue:_currentSector];
    im.alpha = maxAlphavalue;
    [self.delegate wheelDidChangeValue:[self getSectorName:_currentSector] index:_currentSector];
}

- (UIImageView *) getSectorByValue:(int)value {
    UIImageView *res;
    NSArray *views = [container subviews];
    for (UIImageView *im in views) {
        if (im.tag == value)
            res = im;
    }
    return res;
}

@end
