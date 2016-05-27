//
//  Object+Utilities.h
// AirLab
//
//  Created by Raul Catena on 6/26/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "Object.h"

@interface Object (Utilities)

+(NSString *)codeStringForObject:(Object *)object;
+(UIImage *)imageQRForObject:(Object *)object;

@end
