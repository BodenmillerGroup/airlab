//
//  PSInstagramViewController.h
//  PrimaveraSound
//
//  Created by Raul Catena on 5/13/13.
//  Copyright (c) 2013 Raul Catena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSInstagramDetailViewController.h"
#import "Instagram.h"
#import "IGRequest.h"


@interface PSInstagramViewController : ADBMasterViewController <IGSessionDelegate, IGRequestDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    NSMutableDictionary *_photos;
}

@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) Instagram *instagram;
@property (nonatomic, weak) IBOutlet UIToolbar *lowerToolBar;

-(IBAction)takePicture;
-(IBAction)reload;

@end
