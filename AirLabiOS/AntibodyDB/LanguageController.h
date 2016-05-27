//
//  LanguageController.h
//  JazzAldia
//
//  Created by Raul Catena on 7/7/13.
//  Copyright (c) 2013 Raul Catena. All rights reserved.
//

//#import <UIKit/UIKit.h>

@class LanguageController;

@interface LanguageController : NSObject{
    NSString *_chosenLanguage;

}

@property (nonatomic,retain) NSString *chosenLanguage;

+(LanguageController *)getInstance;
-(NSString *)getIdiomForKey:(NSString *)key;

@end
