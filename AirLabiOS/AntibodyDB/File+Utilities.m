//
//  File+Utilities.m
//  AirLab
//
//  Created by Raul Catena on 11/12/15.
//  Copyright © 2015 CatApps. All rights reserved.
//

#import "File+Utilities.h"

@implementation File (Utilities)

-(NSData *)obtainZetData{
    if (!self.zetData) {
        [self resetZetData];
    }
    return self.zetData;
}

-(void)resetZetData{
    dispatch_queue_t download = dispatch_queue_create("Aque", NULL);
    dispatch_async(download, ^{
        NSMutableURLRequest *request = [General callToAPI:[NSString stringWithFormat:@"serveFile/%@", self.filFileId] withPost:[[ADBAccountManager sharedInstance]postForGroup]];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        self.zetData = data;
        [General saveContextAndRoll];
    });
}

@end
