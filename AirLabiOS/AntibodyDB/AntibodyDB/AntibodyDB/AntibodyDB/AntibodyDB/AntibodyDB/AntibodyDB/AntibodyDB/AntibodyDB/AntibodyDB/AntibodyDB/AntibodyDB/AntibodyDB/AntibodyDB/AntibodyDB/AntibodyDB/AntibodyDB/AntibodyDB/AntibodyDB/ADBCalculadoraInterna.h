//
//  CalculadoraInterna.h
//  CalcuParo Pro
//
//  Created by admin on 2/23/12.
//  Copyright 2012 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CalculatorBrain.h"
#import "ADBMasterViewController.h"



@interface ADBCalculadoraInterna : ADBMasterViewController <UIActionSheetDelegate, UITabBarControllerDelegate>{
	
	IBOutlet UILabel *display;
	CalculatorBrain *brain;
	BOOL userIsInTheMiddleOfTypingANumber;
	BOOL userHasTypedAPeriod;
	BOOL userHasPressedOperation;
	
}

@property (nonatomic, weak) IBOutlet UIButton *igual;
@property (nonatomic, weak) IBOutlet UIButton *pasar;
@property (nonatomic, retain) NSString *lastOp;

-(IBAction)digitPressed:(UIButton *)sender;  
-(IBAction)operationPressed:(UIButton *)sender;
-(IBAction)reset:(UIButton *)sender;

-(void)reset;


@end
