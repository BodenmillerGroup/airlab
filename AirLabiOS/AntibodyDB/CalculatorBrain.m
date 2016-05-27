#import "CalculatorBrain.h"


@implementation CalculatorBrain


-(void)setOperand:(double)aDouble{
	operand = aDouble;
}

-(void)performWaitingOperation{    //Este es un metodo privado, no va en .h y ademas se declara antes de usar. No lleva argumento!!!
	if ([@"+" isEqual:waitingOperation]) {
		
		operand = waitingOperand + operand;
		
	}else if([@"X" isEqual:waitingOperation]){
		
		operand = waitingOperand * operand;
		
	}else if([@"-" isEqual:waitingOperation]){
		
		operand = waitingOperand - operand;
		
	}else if([@"/" isEqual:waitingOperation]){
		
		if (operand) { //Esto lo mete para evitar problemas con la division por 0
			
			operand = waitingOperand / operand;
		}
	}
}


-(double)performOperation:(NSString *)operation{
	if ([operation isEqual:@"sqrt"]) {
		operand = sqrt(operand);
	}else if ([@"+/-" isEqual:operation]){  //([@"+/-" isEqual:operation]) seria otra manera de decir lo mismo
		operand = -operand;
	}else{
		[self performWaitingOperation];
		waitingOperation = operation;
		waitingOperand = operand;
	}
	return operand;
}

@end
