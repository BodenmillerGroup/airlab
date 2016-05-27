//
//  ADBAddCommentViewController.m
//  AirLab
//
//  Created by Raul Catena on 11/5/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddCommentViewController.h"

@interface ADBAddCommentViewController ()

@end

@implementation ADBAddCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Lab wall";
    
    [General iPhoneBlock:^{
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)], [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:nil]];
    } iPadBlock:^{
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:nil];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    }];
    
    self.preferredContentSize = self.view.bounds.size;
    
    self.navigationController.navigationBar.barTintColor = [UIColor orangeColor];
    self.navigationController.navigationBar.tintColor =[ UIColor whiteColor];
    
    [_comment becomeFirstResponder];
}

-(void)cancel{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)done{
    CommentWall *comment = (CommentWall *)[General newObjectOfType:COMMENTWALL_DB_CLASS saveContext:YES];
    comment.cwlComment = _comment.text;
    [self.tableView reloadData];
    [self.delegate didAddComment];
}


@end
