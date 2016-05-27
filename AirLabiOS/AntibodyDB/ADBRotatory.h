//
//  ADBRotatory.h
//  AirLab
//
//  Created by Raul Catena on 11/3/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

// The rebase worked!

#import <UIKit/UIKit.h>
#import "ADBSector.h"

@protocol ADBRotaryProtocol <NSObject>

- (void) wheelDidChangeValue:(NSString *)newValue index:(int)index;
@optional
-(void)tapped:(int)index;
-(void)doubledTap:(int)index;

@end

@interface ADBRotatory : UIControl



@property (weak) id <ADBRotaryProtocol> delegate;
@property (nonatomic, strong) UIView *container;
@property int numberOfSections;

@property CGAffineTransform startTransform;
@property (nonatomic, strong) NSMutableArray *sectors;
@property int currentSector;

@property (nonatomic, strong) NSArray *imagesArray;
@property (nonatomic, strong) NSArray *names;

- (id) initWithFrame:(CGRect)frame andDelegate:(id)del withSections:(int)sectionsNumber images:(NSArray *)images andTitles:(NSArray *)titles;
-(void)rotate;

@end
