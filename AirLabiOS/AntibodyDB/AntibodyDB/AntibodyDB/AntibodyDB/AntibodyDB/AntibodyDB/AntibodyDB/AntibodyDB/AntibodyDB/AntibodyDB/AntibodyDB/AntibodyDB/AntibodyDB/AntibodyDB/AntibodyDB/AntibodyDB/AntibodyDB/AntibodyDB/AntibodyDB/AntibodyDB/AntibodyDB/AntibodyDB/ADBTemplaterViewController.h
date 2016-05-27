//
//  PlateLayoutViewController.h
//  LabPad
//
//  Created by Raul Catena on 5/10/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ADBMasterViewController.h"
#import "ADBSavedPlatesViewController.h"


@class PlateView;

@protocol PlateGenerator <NSObject>

-(void)generatedPlateImage:(UIImage *)image;

@end


@interface ADBTemplaterViewController : ADBMasterViewController <UIPopoverControllerDelegate, UIScrollViewDelegate, MFMailComposeViewControllerDelegate, UIPrintInteractionControllerDelegate, UIAlertViewDelegate, SelectedPlate>{
    int currentWell;
}

@property (nonatomic, weak) IBOutlet UIButton *aNewButton;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
@property (nonatomic, weak) IBOutlet UIButton *saveButton;
@property (nonatomic, weak) IBOutlet UISlider *rowsSlider;
@property (nonatomic, weak) IBOutlet UISlider *columnsSlider;
@property (nonatomic, weak) IBOutlet UILabel *filas;
@property (nonatomic, weak) IBOutlet UILabel *columnas;
@property (nonatomic, weak) IBOutlet UIScrollView *plateView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *typeOfPlate;
@property (nonatomic, retain) PlateView *thePlateView;
@property (nonatomic, assign) id<PlateGenerator>delegate;

-(IBAction)createPlate:(UIButton *)sender;
-(IBAction)createPlateWithPrevious:(Plate *)plate;
-(IBAction)start:(id)sender;
-(IBAction)sliderChanged:(UISlider *)sender;
-(IBAction)selectorChanged:(UISegmentedControl *)sender;
-(IBAction)savePlate:(id)sender;
-(IBAction)showSavedPlates:(id)sender;

@end
