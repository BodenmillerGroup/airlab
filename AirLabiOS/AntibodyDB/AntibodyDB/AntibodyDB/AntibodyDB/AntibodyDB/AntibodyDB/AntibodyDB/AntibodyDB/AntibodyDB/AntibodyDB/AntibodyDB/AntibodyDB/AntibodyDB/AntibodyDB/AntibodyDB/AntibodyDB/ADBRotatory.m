//
//  ADBRotatory.m
//  AirLab
//
//  Created by Raul Catena on 11/3/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBRotatory.h"

@interface ADBRotatory()
- (void)drawWheel;
- (float) calculateDistanceFromCenter:(CGPoint)point;
- (void) buildSectorsEven;
- (void) buildSectorsOdd;
@end

@implementation ADBRotatory

static float deltaAngle;

@synthesize delegate, container, numberOfSections;

- (id) initWithFrame:(CGRect)frame andDelegate:(id)del withSections:(int)sectionsNumber {
    // 1 - Call super init
    if ((self = [super initWithFrame:frame])) {
        // 2 - Set properties
        self.numberOfSections = sectionsNumber;
        self.delegate = del;
        // 3 - Draw wheel
        [self drawWheel];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0
                                         target:self
                                       selector:@selector(rotate)
                                       userInfo:nil
                                        repeats:YES];
        
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

//Overriding
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    
    // 1 - Get touch position
    CGPoint touchPoint = [touch locationInView:self];
    
    // 1.1 - Get the distance from the center
    float dist = [self calculateDistanceFromCenter:touchPoint];
    // 1.2 - Filter out touches too close to the center
    if (dist < 40 || dist > 100)
    {
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
    _startTransform = container.transform;
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    CGFloat radians = atan2f(container.transform.b, container.transform.a);
    NSLog(@"rad is %f", radians);
    
    CGPoint pt = [touch locationInView:self];
    float dx = pt.x  - container.center.x;
    float dy = pt.y  - container.center.y;
    float ang = atan2(dy,dx);
    float angleDifference = deltaAngle - ang;
    container.transform = CGAffineTransformRotate(_startTransform, -angleDifference);
    return YES;
}

- (void) drawWheel {
    // 1
    container = [[UIView alloc] initWithFrame:self.frame];
    // 2
    CGFloat angleSize = 2*M_PI/numberOfSections;
    // 3
    for (int i = 0; i < numberOfSections; i++) {
        // 4
        UILabel *im = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        im.backgroundColor = [UIColor redColor];
        im.text = [NSString stringWithFormat:@"%i", i];
        im.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
        // 5
        im.layer.position = CGPointMake(container.bounds.size.width/2.0,
                                        container.bounds.size.height/2.0);
        im.transform = CGAffineTransformMakeRotation(angleSize * i);
        im.tag = i;
        // 6
        [container addSubview:im];
    }
    // 7
    container.userInteractionEnabled = NO;
    [self addSubview:container];
    
    // 7.1 - Add background image
    UIImageView *bg = [[UIImageView alloc] initWithFrame:self.frame];
    bg.image = [UIImage imageNamed:@"swiss.png"];
    [self addSubview:bg];
    
    _sectors = [NSMutableArray arrayWithCapacity:numberOfSections];
    if (numberOfSections % 2 == 0) {
        [self buildSectorsEven];
    } else {
        [self buildSectorsOdd];
    }
    
    [self.delegate wheelDidChangeValue:[NSString stringWithFormat:@"value is %i", self.currentSector]];
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

- (void)endTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    // 1 - Get current container rotation in radians
    CGFloat radians = atan2f(container.transform.b, container.transform.a);
    // 2 - Initialize new value
    CGFloat newVal = 0.0;
    // 3 - Iterate through all the sectors
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
    // 7 - Set up animation for final rotation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    CGAffineTransform t = CGAffineTransformRotate(container.transform, -newVal);
    container.transform = t;
    [UIView commitAnimations];
}

@end
