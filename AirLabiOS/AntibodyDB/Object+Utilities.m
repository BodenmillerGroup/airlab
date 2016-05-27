//
//  Object+Utilities.m
// AirLab
//
//  Created by Raul Catena on 6/26/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "Object+Utilities.h"
#import "Barcode.h"

@implementation Object (Utilities)

+(NSString *)codeStringForObject:(Object *)object{
    if ([object valueForKey:[[IPImporter getInstance]keyOfObject:NSStringFromClass([object class])]]) {
        return [NSString stringWithFormat:@"%@%@", NSStringFromClass([object class]), [object valueForKey:[[IPImporter getInstance]keyOfObject:NSStringFromClass([object class])]]];
    }else{
        return [NSString stringWithFormat:@"%@%@", NSStringFromClass([object class]), [object valueForKey:@"offlineId"]];
    }
}
+(UIImage *)imageQRForObject:(Object *)object{
    //QRCode Stuff
    
    NSString *code = [Object codeStringForObject:object];
    Barcode *barcode = [[Barcode alloc] init];
    [barcode setupQRCode:code];
    UIImage *image = barcode.qRBarcode;
    return image;
    //    Uncomment for one dimensional code 128 barcode.
    //[barcode setupOneDimBarcode:code type:CODE_128];
    //self.imageView.image = barcode.oneDimBarcode;
    
    //    Uncomment for one dimensional ean 13 barcode.
    //    [barcode setupOneDimBarcode:code type:EAN_13];
    //    self.imageView.image = barcode.oneDimBarcode;
}

@end
