//
//  ADBValidationBoxViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 8/13/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBValidationBoxViewController.h"

@interface ADBValidationBoxViewController ()

@property (nonatomic, strong) NSMutableDictionary *json;

@end

@implementation ADBValidationBoxViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andJson:(NSDictionary *)json
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.json = json.mutableCopy;
    }
    return self;
}

-(void)trafficLightSegmentedControl{
    for (int i=0; i<[_valoration.subviews count]; i++)
    {
        UIColor *tintcolor=[UIColor colorWithRed:1-(float)i*0.5f green:(float)i*0.5f blue:0.0f alpha:1.0f];
        [[_valoration.subviews objectAtIndex:i] setTintColor:tintcolor];
        /*if ([[sender.subviews objectAtIndex:i]isSelected] )
        {
            UIColor *tintcolor=[UIColor colorWithRed:127.0/255.0 green:161.0/255.0 blue:183.0/255.0 alpha:1.0];
            [[sender.subviews objectAtIndex:i] setTintColor:tintcolor];
        }
        else
        {
            [[sender.subviews objectAtIndex:i] setTintColor:nil];
        }*/
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self trafficLightSegmentedControl];
    if(_json)[self setPrevious];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.preferredContentSize = self.view.bounds.size;
}

-(void)setPrevious{
    [_notes setText:[_json valueForKey:@"note"]];
    [_application setSelectedSegmentIndex:[[_json valueForKey:@"app"]intValue]];
    [_cellLine setText:[_json valueForKey:@"sample"]];
    [_valoration setSelectedSegmentIndex:[[_json valueForKey:@"val"]intValue]];
    [_validation setOn:[[_json valueForKey:@"isVal"]boolValue]];
}

-(void)done{
    BOOL new = NO;
    if(!_json){
        self.json = [NSMutableDictionary dictionary];
        new = YES;
    }
    
    [_json setValue:_notes.text forKey:@"note"];
    [_json setValue:[NSString stringWithFormat:@"%i", _application.selectedSegmentIndex] forKey:@"app"];
    [_json setValue:_cellLine.text forKey:@"sample"];
    [_json setValue:[NSString stringWithFormat:@"%i", _valoration.selectedSegmentIndex] forKey:@"val"];
    [_json setValue:[NSString stringWithFormat:@"%i", _validation.on] forKey:@"isVal"];
    
    if (new == YES)[self.delegate didAddValidationNote:[NSDictionary dictionaryWithDictionary:_json]];
    else [self.delegate didModifyValidationNote:[NSDictionary dictionaryWithDictionary:_json]];
    
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if (textView.tag == 1) {
        textView.tag = 0;
        textView.text = nil;
    }
}


@end
