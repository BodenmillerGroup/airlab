//
//  ADBPasoCellTableViewCell.h
//  AntibodyDB
//
//  Created by Raul Catena on 6/4/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADBPasoCellTableViewCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *paso;
@property (nonatomic, weak) IBOutlet UILabel *pasoTexto;
@property (nonatomic, weak) IBOutlet UILabel *indice;
@property (nonatomic, weak) IBOutlet UILabel *temporizador;
@property (nonatomic, strong) Recipe *recipe;

@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,assign) int cuenta;
@property (nonatomic,assign) BOOL inprocess;

-(IBAction)resumeTimer:(id)sender;
-(IBAction)finish:(id)sender;

@end
