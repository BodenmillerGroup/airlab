//
//  ADBAddPlaceViewController.m
// AirLab
//
//  Created by Raul Catena on 5/16/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBAddPlaceViewController.h"

@interface ADBAddPlaceViewController (){
    float heightShelves;
    float heightRacks;
    float heightBoxess;
    float heightLayout;
    
    float thickShelves;
    float thickRacks;
    float thickBoxess;
    float thickLayout;
}

@property (nonatomic, strong) Place *place;
@property (nonatomic, strong) Place *parent;
@property (nonatomic, strong) NSString *x;
@property (nonatomic, strong) NSString *y;

@end

@implementation ADBAddPlaceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withParent:(Place *)parentPlace withX:(NSString *)x andY:(NSString *)y
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.parent = parentPlace;
        _x = x;
        _y = x;
    }
    return self;
}

-(void)filterSegmentController{
    if([self.parent.plaType isEqualToString:@"cupboard"]){
        [self.typePlace setEnabled:NO forSegmentAtIndex:0];
        [self.typePlace setEnabled:NO forSegmentAtIndex:1];
        [self.typePlace setEnabled:NO forSegmentAtIndex:2];
        [self.typePlace setEnabled:NO forSegmentAtIndex:5];
        [self.typePlace setSelectedSegmentIndex:3];
    }
    if([self.parent.plaType isEqualToString:@"shelf"]){
        [self.typePlace setEnabled:NO forSegmentAtIndex:0];
        [self.typePlace setEnabled:NO forSegmentAtIndex:1];
        [self.typePlace setEnabled:NO forSegmentAtIndex:2];
        [self.typePlace setSelectedSegmentIndex:3];
    }
    if([self.parent.plaType isEqualToString:@"fridge"] || [self.parent.plaType isEqualToString:@"freezer"] || [self.parent.plaType isEqualToString:@"nitrogen"]){
        [self.typePlace setEnabled:NO forSegmentAtIndex:0];
        [self.typePlace setEnabled:NO forSegmentAtIndex:1];
        [self.typePlace setEnabled:NO forSegmentAtIndex:2];
        [self.typePlace setEnabled:NO forSegmentAtIndex:5];
        [self.typePlace setSelectedSegmentIndex:3];
    }
    if([self.parent.plaType isEqualToString:@"rack"]){
        [self.typePlace setEnabled:NO forSegmentAtIndex:0];
        [self.typePlace setEnabled:NO forSegmentAtIndex:1];
        [self.typePlace setEnabled:NO forSegmentAtIndex:2];
        [self.typePlace setEnabled:NO forSegmentAtIndex:3];
        [self.typePlace setSelectedSegmentIndex:4];
    }
    if([self.parent.plaType isEqualToString:@"box"]){//Should not show up
        [self.typePlace setEnabled:NO forSegmentAtIndex:0];
        [self.typePlace setEnabled:NO forSegmentAtIndex:1];
        [self.typePlace setEnabled:NO forSegmentAtIndex:2];
        [self.typePlace setEnabled:NO forSegmentAtIndex:3];
        [self.typePlace setEnabled:NO forSegmentAtIndex:4];
        [self.typePlace setEnabled:NO forSegmentAtIndex:5];
        [self.typePlace setSelectedSegmentIndex:6];
    }
}

-(void)recordHeights{
    heightShelves = self.shelvesPanel.frame.origin.y;
    heightRacks = self.racksPanel.frame.origin.y;
    heightBoxess = self.boxesPanel.frame.origin.y;
    heightLayout = self.layoutPanel.frame.origin.y;
    thickShelves = self.shelvesPanel.frame.size.height;
    thickRacks = self.racksPanel.frame.size.height;
    thickBoxess = self.boxesPanel.frame.size.height;
    thickLayout = self.layoutPanel.frame.size.height;
}

-(void)redistributePanels{
    NSArray *allPanels = @[_shelvesPanel, _racksPanel, _boxesPanel, _layoutPanel];
    
    for(UIView *panel in allPanels){
        if(panel == _shelvesPanel){
            CGRect frame = panel.frame;
            panel.frame = CGRectMake(frame.origin.x, heightShelves, frame.size.width, thickShelves);
        }
        if(panel == _racksPanel){
            CGRect frame = panel.frame;
            panel.frame = CGRectMake(frame.origin.x, heightShelves, frame.size.width, thickRacks);
        }
        if(panel == _boxesPanel){
            CGRect frame = panel.frame;
            panel.frame = CGRectMake(frame.origin.x, heightShelves, frame.size.width, thickBoxess);
        }
        if(panel == _layoutPanel){
            CGRect frame = panel.frame;
            panel.frame = CGRectMake(frame.origin.x, heightShelves, frame.size.width, thickLayout);
        }
    }
    
    float cumHeight = 0;
    for(UIView *panel in allPanels){
        if (!panel.hidden){
            panel.frame = CGRectOffset(panel.frame, 0, cumHeight);
            cumHeight = cumHeight + panel.bounds.size.height + 2;
        }
    }
}

-(void)filterPanels{
    int selected = (int)self.typePlace.selectedSegmentIndex;
    NSArray *selection;
    switch(selected){
        case 0:
            selection = @[@"1", @"0", @"0", @"0"];
            break;
        case 1:
            selection = @[@"1", @"0", @"0", @"0"];
            break;
        case 2:
            selection = @[@"0", @"1", @"0", @"0"];
            break;
        case 3:
            selection = @[@"0", @"0", @"0", @"1"];
            break;
        case 4:
            selection = @[@"0", @"0", @"0", @"1"];
            break;
        case 5:
            selection = @[@"0", @"0", @"0", @"0"];
            break;
        case 6:
            selection = @[@"0", @"0", @"0", @"1"];
            break;
        default:
            break;
    }
    self.shelvesPanel.hidden = ![[selection objectAtIndex:0]boolValue];
    self.racksPanel.hidden = ![[selection objectAtIndex:1]boolValue];
    self.boxesPanel.hidden = ![[selection objectAtIndex:2]boolValue];
    self.layoutPanel.hidden = ![[selection objectAtIndex:3]boolValue];
    
    [self redistributePanels];
    
    NSArray *steppers = @[_shelvesSwitch, _racksSwitch, _boxesSwitch, _layoutSwitch, _layout2Switch];
    for(UIStepper *step in steppers){
        [self stepperChanged:step];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.preferredContentSize = self.view.bounds.size;
    [General addBorderToButton:_createButton withColor:[UIColor orangeColor]];
    
    [self recordHeights];
    
    self.temperature.hidden = YES;

    [self filterSegmentController];
    [self filterPanels];
}

-(void)stepperChanged:(UIStepper *)sender{
    if(sender == _shelvesSwitch){
        self.shelvesLabel.text = [NSString stringWithFormat:@"Number of shelves: %i", (int)sender.value];
    }
    if(sender == _racksSwitch){
        self.racksLabel.text = [NSString stringWithFormat:@"Number of racks per shelf: %i", (int)sender.value];
    }
    if(sender == _boxesSwitch){
        self.boxesLabel.text = [NSString stringWithFormat:@"Number of boxes per rack: %i", (int)sender.value];
    }
    if(sender == _layoutSwitch){
        self.layoutLabel.text = [NSString stringWithFormat:@"Number of rows: %i", (int)sender.value];
    }
    if(sender == _layout2Switch){
        self.layout2Label.text = [NSString stringWithFormat:@"Number of columns: %i", (int)sender.value];
    }
}

-(void)switchChanged:(UISwitch *)sender{

}

-(void)typeChanged:(UISegmentedControl *)sender{
    if(sender.selectedSegmentIndex == 1){
        self.temperature.hidden = NO;
    }else{
        self.temperature.hidden = YES;
    }
    [self filterPanels];
}

-(void)addPlace{
    NSString *message = [General returnMessageAftercheckName:_name.text lenghtTo:20];
    if(message){[General showOKAlertWithTitle:message andMessage:nil delegate:self];return;}
    if(!_place){
        self.place = (Place *)[General newObjectOfType:PLACE_DB_CLASS saveContext:NO];
    }
    self.place.plaName = _name.text;
    
    //Adding the type
    int selected = (int)self.typePlace.selectedSegmentIndex;
    switch(selected){
        case 0:
            self.place.plaType = @"cupboard";
            break;
        case 1:
            if(self.temperature.selectedSegmentIndex == 0)
            self.place.plaType = @"fridge";
            else self.place.plaType = @"freezer";
            break;
        case 2:
            self.place.plaType = @"nitrogen";
            break;
        case 3:
            self.place.plaType = @"rack";
            break;
        case 4:
            self.place.plaType = @"box";
            break;
        case 5:
            self.place.plaType = @"cage";
            break;
        case 6:
            self.place.plaType = @"other";
            break;
        default:
            break;
    }
    
    if(_y)self.place.plaY = _y;
    if(_x)self.place.plaX = _x;
    
    //Adding shelves
    if(selected < 2){//Cupboard or freedge
        self.place.plaSelves = [NSString stringWithFormat:@"%i", (int)_shelvesSwitch.value];
        /*for(int x= 0; x< _place.plaSelves.intValue; x++){
            Place *place = (Place *)[General newObjectOfType:PLACE_DB_CLASS saveContext:NO];
            place.plaType = @"shelf";
            place.plaY = [NSString stringWithFormat:@"%i",x];
            place.parent = _place;
            if (_place.plaPlaceId)place.plaParentId = _place.plaPlaceId;
            else place.plaParentId = _place.offlineId;
            
        }*/
    }
    if(selected == 2){//Cupboard or freedge
        self.place.plaSelves = @"1";
        /*for(int x= 0; x< _place.plaRows.intValue; x++){
            Place *place = (Place *)[General newObjectOfType:PLACE_DB_CLASS saveContext:NO];
            place.plaY = [NSString stringWithFormat:@"%i",x];
            place.plaType = @"rack";
            place.parent = _place;
            if (_place.plaPlaceId)place.plaParentId = _place.plaPlaceId;
            else place.plaParentId = _place.offlineId;
        }*/
    }
    if(selected == 3){
        self.place.plaRows = [NSString stringWithFormat:@"%i", (int)_layoutSwitch.value];
        self.place.plaColumns = [NSString stringWithFormat:@"%i", (int)_layout2Switch.value];
        /*for(int x= 0; x< _place.plaRows.intValue; x++){
            Place *place = [NSEntityDescription insertNewObjectForEntityForName:PLACE_DB_CLASS inManagedObjectContext:self.managedObjectContext];
            place.plaY = [NSString stringWithFormat:@"%i",x];
            place.plaType = @"box";
            place.parent = _place;
        }*/
    }
    if(selected == 4 || selected == 6){
        self.place.plaRows = [NSString stringWithFormat:@"%i", (int)_layoutSwitch.value];
        self.place.plaColumns = [NSString stringWithFormat:@"%i", (int)_layout2Switch.value];
    }
    
    [General doLinkForProperty:@"parent" inObject:_place withReceiverKey:@"plaParentId" fromDonor:_parent withPK:@"plaPlaceId"];
    
    [self.delegate didAddPlace:self.place];
    [[IPExporter getInstance]uploadNewObject:self.place withBlock:^(NSURLResponse *response, NSData *data, NSError *error){
        if ([_place.plaType isEqualToString:@"cupboard"] || [_place.plaType isEqualToString:@"fridge"] || [_place.plaType isEqualToString:@"freezer"]) {
            for(int x= 0; x< _place.plaSelves.intValue; x++){
                Place *aplace = (Place *)[General newObjectOfType:PLACE_DB_CLASS saveContext:NO];
                aplace.plaType = @"shelf";
                aplace.plaY = [NSString stringWithFormat:@"%i",x];
                [General doLinkForProperty:@"parent" inObject:aplace withReceiverKey:@"plaParentId" fromDonor:_place withPK:@"plaPlaceId"];
            }
        }
        
        if ([_place.plaType isEqualToString:@"nitrogen"]) {
            for(int x= 0; x< _place.plaSelves.intValue; x++){
                Place *aplace = (Place *)[General newObjectOfType:PLACE_DB_CLASS saveContext:NO];
                aplace.plaY = [NSString stringWithFormat:@"%i",x];
                aplace.plaType = @"rack";
                [General doLinkForProperty:@"parent" inObject:aplace withReceiverKey:@"plaParentId" fromDonor:_place withPK:@"plaPlaceId"];
                
            }
        }
    }];
}

@end
