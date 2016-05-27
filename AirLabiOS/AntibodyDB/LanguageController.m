//
//  LanguageController.m
//  JazzAldia
//
//  Created by Raul Catena on 7/7/13.
//  Copyright (c) 2013 Raul Catena. All rights reserved.
//

#import "LanguageController.h"

@implementation LanguageController

@synthesize chosenLanguage = _chosenLanguage;

+ (LanguageController *)getInstance {
    static dispatch_once_t pred = 0;
    __strong static LanguageController* _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
        /*if ([[NSUserDefaults standardUserDefaults]valueForKey:NSUSERDEFAULTS_LANGUAGE_CHOSEN]) {
            _sharedObject.chosenLanguage = [[NSUserDefaults standardUserDefaults]valueForKey:NSUSERDEFAULTS_LANGUAGE_CHOSEN];
        }
        else*/
        _sharedObject.chosenLanguage = @"en";
    });
    return _sharedObject;
}

-(NSString *)getIdiomForKey:(NSString *)key{
    NSString *idiom = nil;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Strings" ofType:@"plist"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSDictionary *optionsArray = [NSDictionary dictionaryWithContentsOfURL:url];
    NSDictionary *valuesForKey = [optionsArray valueForKey:key];
    NSString *translation = [valuesForKey valueForKey:[[LanguageController getInstance]chosenLanguage]];
    if (translation) {
        idiom = translation;
    }
    return idiom;
}

@end
