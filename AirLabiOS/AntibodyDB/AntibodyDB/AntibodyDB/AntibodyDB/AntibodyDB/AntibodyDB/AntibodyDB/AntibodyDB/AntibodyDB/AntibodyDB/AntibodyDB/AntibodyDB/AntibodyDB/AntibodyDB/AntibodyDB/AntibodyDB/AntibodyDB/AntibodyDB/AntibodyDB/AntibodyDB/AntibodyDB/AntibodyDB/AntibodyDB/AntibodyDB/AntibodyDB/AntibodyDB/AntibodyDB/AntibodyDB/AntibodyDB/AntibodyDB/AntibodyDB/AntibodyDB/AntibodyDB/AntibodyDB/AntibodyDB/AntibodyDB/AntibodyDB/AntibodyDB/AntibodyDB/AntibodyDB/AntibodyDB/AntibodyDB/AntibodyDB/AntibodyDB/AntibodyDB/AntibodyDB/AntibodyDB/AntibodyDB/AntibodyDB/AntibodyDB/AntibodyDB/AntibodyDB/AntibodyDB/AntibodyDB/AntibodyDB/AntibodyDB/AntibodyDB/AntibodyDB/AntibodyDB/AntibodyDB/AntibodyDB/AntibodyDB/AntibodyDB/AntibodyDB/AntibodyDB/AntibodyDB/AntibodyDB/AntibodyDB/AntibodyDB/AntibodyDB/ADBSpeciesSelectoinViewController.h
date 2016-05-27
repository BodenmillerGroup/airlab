//
//  ADBSpeciesSelectoinViewController.h
//  AntibodyDB
//
//  Created by Raul Catena on 4/1/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol SpeciesSelection;
@class Species;

@interface ADBSpeciesSelectoinViewController : ADBMasterViewController


@property (nonatomic, weak) id<SpeciesSelection>delegate;
@property (nonatomic, assign) BOOL multiselector;
@property (nonatomic, strong) NSMutableArray *selection;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andMultiSelector:(BOOL)multisel;

@end

@protocol SpeciesSelection <NSObject>

-(void)didSelectSpecies:(Species *)species;
-(void)didSelectSpeciesArray:(NSMutableArray *)speciesArray;

@end
