//
//  PSInstagramPhotoTaken.m
//  ERA-EDTA2013
//
//  Created by Raul Catena on 10/10/13.
//  Copyright (c) 2013 Raul Catena. All rights reserved.
//

#import "PSInstagramPhotoTaken.h"

@interface PSInstagramPhotoTaken ()

@end

@implementation PSInstagramPhotoTaken


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andImage:(UIImage *)image
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.image = image;
    }
    return self;
}

-(void)setTheSwitches{
    //LanguageController *instance = [LanguageController getInstance];
    
    //self.saveToCameraRollLabel.text = @"";//[instance getIdiomForKey:INSTAGRAM_SAVE_CAMERA_ROLL];
    //self.uploadToInstagramLabel.text = @"";//[instance getIdiomForKey:INSTAGRAM_UPLOAD];
    //self.emailAFriendLabel.text = @"";//[instance getIdiomForKey:INSTAGRAM_EMAIL];
    self.saveToCameraRoll.onTintColor = [UIColor orangeColor];
    self.uploadToInstagram.onTintColor = [UIColor orangeColor];
    self.emailAFriend.onTintColor = [UIColor orangeColor];
    
    //[self.doneButton setTitle:[instance getIdiomForKey:DONE_BUTTON] forState:UIControlStateNormal];// Do any additional setup after loading the view from its nib.
    self.doneButton.layer.borderColor = [UIColor blueColor].CGColor;
    self.doneButton.layer.borderWidth = 1.0f;
    self.doneButton.layer.cornerRadius = 4.0f;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = _image;
    [self setTheSwitches];
}

-(void)doneButton:(id)sender{
    
}


@end
