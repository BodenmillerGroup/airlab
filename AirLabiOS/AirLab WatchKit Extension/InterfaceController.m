//
//  InterfaceController.m
//  AirLab WatchKit Extension
//
//  Created by Raul Catena on 7/1/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import "InterfaceController.h"
//#import "General.h"
#import "Recipe.h"
#import "IPImporter.h"
#import "ADBCellProt.h"
#import <UIKit/UIKit.h>


@interface InterfaceController()

@property (nonatomic, strong) NSArray *protocols;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [WKInterfaceController openParentApplication:@{@"request": @"refreshData"} reply:^(NSDictionary *replyInfo, NSError *error){
        NSLog(@"Reply info %@", replyInfo);
    }];
    
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    _protocols = @[@"1", @"2", @"3", @"4", @"5"];

    [_table setNumberOfRows:_protocols.count withRowType:@"ProtocolRow"];
    for (NSString *pro in _protocols) {
            NSLog(@"3");
        ADBCellProt *cell = [_table rowControllerAtIndex:[_protocols indexOfObject:pro]];
        [cell.titleL setText:pro.description];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



