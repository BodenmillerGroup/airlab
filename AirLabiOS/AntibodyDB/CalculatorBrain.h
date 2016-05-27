//
//  CalculatorBrain.h
//  Calculator
//
//  Created by admin on 7/24/11.
//  Copyright 2012 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CalculatorBrain : NSObject {

	double operand; //Es una variable de instancia, el n'umero sobre el que se hace la operaci'on
	NSString *waitingOperation;//Estos dos son para hacer operaciones con dos numeros
	double waitingOperand;
	double waitingOperandTwo;
	
	
}

-(void)setOperand:(double)aDouble; //Este es el metodo que va a generar un nuevo operando
-(double)performOperation:(NSString *)operation;//Es es el metodo que hara la operacion en si misma y como tal..

@end
