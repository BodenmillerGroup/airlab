//
//  ADBLabelsForBox.h
// AirLab
//
//  Created by Raul Catena on 6/2/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADBLabelsForBox : NSObject

+(void)generatePDFforBox:(Place *)box showIn:(UIViewController *)controller;
+(void)generatePDFforCapsBox:(Place *)box showIn:(UIViewController *)controller;

@end
