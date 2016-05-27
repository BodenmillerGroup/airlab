//
//  ADBAddCommentViewController.h
//  AirLab
//
//  Created by Raul Catena on 11/5/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBMasterViewController.h"

@protocol AddToWall<NSObject>

-(void)didAddComment;

@end

@interface ADBAddCommentViewController : ADBMasterViewController
@property (weak, nonatomic) IBOutlet UITextView *comment;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) id<AddToWall>delegate;

@end
