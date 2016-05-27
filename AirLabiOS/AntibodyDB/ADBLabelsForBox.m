//
//  ADBLabelsForBox.m
// AirLab
//
//  Created by Raul Catena on 6/2/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBLabelsForBox.h"

#define WIDTH_LABEL 130.0f
#define HEIGTH_LABEL 50.0f
#define GAP 31.0f
#define GAPV 21.0f
#define MARGIN 25.0f

#define WIDTH_LABEL_CAP 39.0f
#define HEIGTH_LABEL_CAP 39.0f
#define GAP_CAP 15.0f
#define GAPV_CAP 15.0f
#define MARGIN_CAP 25.0f

@implementation ADBLabelsForBox

+(void)generatePDFforBox:(Place *)box showIn:(UIViewController *)controller{
    UIView *aView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 800, 1200)];
    int row = 0;
    int column = 0;
    int count = 0;
    int columns = 5;
    
    NSSortDescriptor *aSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"plaX" ascending:YES comparator:^(id obj1, id obj2) {
        
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    NSArray *ordered = [NSMutableArray arrayWithArray:[box.children.allObjects sortedArrayUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]]];
    
    for(Place *aPlace in ordered){
        if(aPlace.tubes.count == 0)continue;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(MARGIN + ((WIDTH_LABEL+GAP) * column), MARGIN/2 + ((HEIGTH_LABEL+GAPV) * row), WIDTH_LABEL, HEIGTH_LABEL)];
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByTruncatingMiddle;
        label.font = [UIFont systemFontOfSize:10.0f];
        label.numberOfLines = 6;
        label.text = [General titleForSideOfTube:aPlace.tubes.allObjects.lastObject];
        
        if ([[aPlace.tubes.allObjects lastObject]isMemberOfClass:[LabeledAntibody class]]) {
            //Add H and M
            LabeledAntibody *lab = (LabeledAntibody *)aPlace.tubes.allObjects.lastObject;
            
        }
        
        [aView addSubview:label];
        if((count+1)%columns == 0 && count!=0){row++;column = 0;}
        else column++;
        count ++;
    }
    NSData *data = [General generatePDFData:aView];
    [General sendToFriend:nil withData:data withSubject:@"Labels for box" fileName:[NSDate date].description fromVC:controller];
//    [General generatePDFFromScrollView:aView onVC:controller];
}

+(void)generatePDFforCapsBox:(Place *)box showIn:(UIViewController *)controller{
    UIView *aView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 800, 1200)];
    int row = 0;
    int column = 0;
    int count = 0;
    int columns = 8;
    
    NSSortDescriptor *aSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"plaX" ascending:YES comparator:^(id obj1, id obj2) {
        
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    NSArray *ordered = [NSMutableArray arrayWithArray:[box.children.allObjects sortedArrayUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]]];
    
    for(Place *aPlace in ordered){
        if(aPlace.tubes.count == 0)continue;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(MARGIN_CAP + ((WIDTH_LABEL_CAP+GAP_CAP) * column), MARGIN_CAP/2 + ((HEIGTH_LABEL_CAP+GAPV_CAP) * row), WIDTH_LABEL_CAP, HEIGTH_LABEL_CAP)];
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByTruncatingMiddle;
        label.font = [UIFont systemFontOfSize:10.0f];
        label.numberOfLines = 2;
        label.text = [General titleForTube:aPlace.tubes.allObjects.lastObject];
        
        [aView addSubview:label];
        if((count+1)%columns == 0 && count!=0){row++;column = 0;}
        else column++;
        count ++;
    }
    NSData *data = [General generatePDFData:aView];
    [General sendToFriend:nil withData:data withSubject:@"Labels for box" fileName:[NSDate date].description fromVC:controller];
    //    [General generatePDFFromScrollView:aView onVC:controller];
}

@end
