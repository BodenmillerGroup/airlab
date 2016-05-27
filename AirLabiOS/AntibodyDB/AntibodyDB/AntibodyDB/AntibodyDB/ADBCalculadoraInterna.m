//
//  CalculadoraInterna.m
//  CalcuParo Pro
//
//  Created by admin on 2/23/12.
//  Copyright 2012 CatApps. All rights reserved.
//

#import "ADBCalculadoraInterna.h"
//#import "ExperimentInstanceViewController.h"


@implementation ADBCalculadoraInterna

-(BOOL)canBecomeFirstResponder{
	return YES;
}
- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:YES];
	[self becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [General addBorderToButton:_igual withColor:[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1]];
    self.preferredContentSize = self.view.frame.size;
	
}
-(CalculatorBrain *)brain{
	if (!brain) brain = [[CalculatorBrain alloc]init];
	return brain;
}

-(IBAction)digitPressed:(UIButton *)sender{
	NSString *digit = [[sender titleLabel] text];
	userHasPressedOperation = NO;
	
	if (userIsInTheMiddleOfTypingANumber == YES){

        if([[display text]length]<11) {
            if (userHasTypedAPeriod == YES) {
                if (![@"." isEqual:digit]){
                    [display setText:[[display text] stringByAppendingString:digit]];
                }
            }else{
                [display setText:[[display text] stringByAppendingString:digit]];
                if ([@"." isEqual:digit])userHasTypedAPeriod = YES;
            }
        }
	}else{
		if (digit.intValue == 0){
			if (userHasPressedOperation == NO) {
				[display setText:digit];
            } else display.text = [display.text stringByAppendingString:digit];
			
		}else{
			if([@"." isEqual:digit]){
                NSString *stringForCeroComa = [NSString stringWithFormat:@"0%@", digit];
                [display setText:stringForCeroComa];
                userHasTypedAPeriod = YES;
                userIsInTheMiddleOfTypingANumber = YES;
            }else{
                [display setText:digit];
                userIsInTheMiddleOfTypingANumber = YES;
			}	
		}
	}
}

-(IBAction)operationPressed:(UIButton *)sender{
	userHasTypedAPeriod = NO;
	if (userHasPressedOperation == NO) {
			
		if (userIsInTheMiddleOfTypingANumber) { 
			[[self brain] setOperand:display.text.doubleValue]; //Aqui se le pasa el operando a Brain
			userIsInTheMiddleOfTypingANumber = NO;//Resetea la entrada a 0
		
			NSString *operation = sender.titleLabel.text;
			double result = [[self brain] performOperation:operation];
			[display setText:[NSString stringWithFormat:@"%g", result]];
		}else{
			NSString *operation = sender.titleLabel.text;
			double result = [[self brain] performOperation:operation];
			[display setText:[NSString stringWithFormat:@"%g", result]];
		}
		NSString *operation = [[sender titleLabel]text];
		if(![operation isEqual:@"="]){
			userHasPressedOperation = YES;
		}
	}
}

-(void)reset:(UIButton *)sender{
    [self reset];
}

-(void)reset{
    if ([[display text]length] == 1) {
        [display setText:@"0"];
        userIsInTheMiddleOfTypingANumber = NO;
    }else{
        NSMutableString *mutable = [[NSMutableString alloc]initWithString:display.text];
        [mutable replaceCharactersInRange:NSMakeRange([display.text length]-1, 1) withString:@""];
        display.text = mutable;
    }
	userHasTypedAPeriod = NO;
	[[self brain] setOperand:0];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (event.type == UIEventSubtypeMotionShake) {
		[self reset];
 	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 11) ? NO : YES;
}



@end
