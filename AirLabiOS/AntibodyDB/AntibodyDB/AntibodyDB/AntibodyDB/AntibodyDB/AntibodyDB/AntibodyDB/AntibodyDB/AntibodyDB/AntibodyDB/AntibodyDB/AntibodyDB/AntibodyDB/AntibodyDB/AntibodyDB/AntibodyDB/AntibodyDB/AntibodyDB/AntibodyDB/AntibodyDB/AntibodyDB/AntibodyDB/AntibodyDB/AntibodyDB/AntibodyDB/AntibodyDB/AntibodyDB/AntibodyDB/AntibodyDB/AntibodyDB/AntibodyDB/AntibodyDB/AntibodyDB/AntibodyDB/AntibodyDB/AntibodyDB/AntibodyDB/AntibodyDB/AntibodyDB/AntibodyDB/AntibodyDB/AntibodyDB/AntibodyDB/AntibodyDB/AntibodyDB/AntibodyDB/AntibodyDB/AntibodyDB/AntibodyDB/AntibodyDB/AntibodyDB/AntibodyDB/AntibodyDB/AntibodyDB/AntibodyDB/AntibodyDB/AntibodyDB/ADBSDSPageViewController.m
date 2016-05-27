    //
//  GelCalculatorViewController.m
//  LabPad
//
//  Created by Raul Catena on 5/10/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBSDSPageViewController.h"


@implementation ADBSDSPageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
	self.reagentsSDS = [NSArray arrayWithObjects:@"Water", @"1.5M Tris (pH8.8)", @"Acrylamide stock", @"10% SDS", @"10% APS", @"TEMED", nil];
	self.reagentsSDSB = [NSArray arrayWithObjects:@"Water", @"0.5M Tris (pH6.8)", @"Acrylamide stock", @"10% SDS", @"10% APS", @"TEMED", nil];
    self.preferredContentSize = self.view.frame.size;
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:YES];
	[self sliderChangesGel:self.resolvingSlider];
	[self sliderChangesGel:self.stackingSlider];
	self.resolvingVolume.selectedSegmentIndex = 1;
	self.valuesResolving = [self calculateResolving:self.thirtyForty.on withPercentage:(int)self.resolvingSlider.value andVolume:self.resolvingVolume.selectedSegmentIndex];
	self.valuesStacking = [self calculateStacking:self.thirtyForty.on withPercentage:(int)self.stackingSlider.value andVolume:self.stackingVolume.selectedSegmentIndex];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [_reagentsSDS count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellSDS";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (tableView.tag == 0) {
		
		cell.textLabel.text = [_reagentsSDS objectAtIndex:indexPath.row];
		
		float value = [[self.valuesResolving objectAtIndex:indexPath.row] floatValue];NSLog(@"%.4f", value);
		if (value < 1) {
			value = value * 1000;
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f uL", value];
		}else {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f mL", value];
		}
	}else{
		
		cell.textLabel.text = [_reagentsSDSB objectAtIndex:indexPath.row];
		
		float value = [[self.valuesStacking objectAtIndex:indexPath.row] floatValue];
		if (value < 1) {
			value = value * 1000;
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f uL", value];
		}else {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f mL", value];
		}
	}
	
	cell.detailTextLabel.textColor = [UIColor orangeColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
}

#pragma mark Gelmethods

-(void)toggleSwitch:(id)sender{
    [self.tableView reloadData];
    [self.tableView2 reloadData];
}

-(void)sliderChangesGel:(UISlider *)sender{
	if (sender.tag == 0){
		self.resolvingLabel.text = [NSString stringWithFormat:@"Gel Percentage: %i %%", (int)sender.value];
		self.valuesResolving = [self calculateResolving:self.thirtyForty.on withPercentage:(int)self.resolvingSlider.value andVolume:self.resolvingVolume.selectedSegmentIndex];
		[self.tableView reloadData];
	}else {
		self.stackingLabel.text = [NSString stringWithFormat:@"Gel Percentage: %i %%", (int)sender.value];
		self.valuesStacking = [self calculateStacking:self.thirtyForty.on withPercentage:(int)self.stackingSlider.value andVolume:self.stackingVolume.selectedSegmentIndex];
		[self.tableView2 reloadData];
	}
}

-(IBAction)segmentsChanged:(UISegmentedControl *)sender{
	if (sender.tag == 0) {
		self.valuesResolving = [self calculateResolving:self.thirtyForty.on withPercentage:(int)self.resolvingSlider.value andVolume:self.resolvingVolume.selectedSegmentIndex];
	}else if (sender.tag == 1) {
		self.valuesStacking = [self calculateStacking:self.thirtyForty.on withPercentage:(int)self.stackingSlider.value andVolume:self.stackingVolume.selectedSegmentIndex];
	}else{
		self.valuesResolving = [self calculateResolving:self.thirtyForty.on withPercentage:(int)self.resolvingSlider.value andVolume:self.resolvingVolume.selectedSegmentIndex];
		self.valuesStacking = [self calculateStacking:self.thirtyForty.on withPercentage:(int)self.stackingSlider.value andVolume:self.stackingVolume.selectedSegmentIndex];
	}
    [self.tableView reloadData];
    [self.tableView2 reloadData];

}

-(NSArray *)calculateResolving:(BOOL)is30or40 withPercentage:(int)resolvingPercentage andVolume:(int)resolvingGelVolume{
	
	float acrylValue;
	float volume;
	
	if (is30or40) {
		acrylValue = 30;
	}else {
		acrylValue = 40;
	}
	
    volume = resolvingGelVolume * 10;
    if(volume == 0)volume = 5;
    if(volume > 50)volume = 100;
	
    NSNumber *theAcryl = [NSNumber numberWithFloat:(float)(resolvingPercentage/acrylValue)* volume];
    NSNumber *theTris = [NSNumber numberWithFloat:(float)(volume/4)];
    NSNumber *theAps = [NSNumber numberWithFloat:(float)(volume/100)];
    NSNumber *theSds = [NSNumber numberWithFloat:(float)(volume/100)];
    NSNumber *theTemed = [NSNumber numberWithFloat:(float)(volume/2500)];
    NSNumber *theWater = [NSNumber numberWithFloat:(float)(volume - (theAcryl.floatValue + theAcryl.floatValue + theAps.floatValue + theSds.floatValue + theTemed.floatValue))];
    
	return @[theWater, theTris, theAcryl, theSds, theAps, theTemed];
}

-(NSArray *) calculateStacking:(int)acrylStockValue withPercentage:(int)stackingPercentage andVolume:(int)stackingGelVolume{
	float stockAcryl;
	float volume;
	
	if (_thirtyForty.on) {
		stockAcryl = 30;
	}else {
		stockAcryl = 40;
	}
	
    volume = stackingGelVolume * 10;
    if(volume == 0)volume = 5;
    if(volume > 50)volume = 100;

	
	NSNumber *theAcryl = [NSNumber numberWithFloat:(float)(stackingPercentage/stockAcryl)* volume];
	NSNumber *theTris = [NSNumber numberWithFloat:(float)(volume/4)];
	NSNumber *theAps = [NSNumber numberWithFloat:(float)(volume/100)];
	NSNumber *theSds = [NSNumber numberWithFloat:(float)(volume/100)];
	NSNumber *theTemed = [NSNumber numberWithFloat:(float)(volume/2500)];
	NSNumber *theWater = [NSNumber numberWithFloat:(float)(volume - (theAcryl.floatValue + theAcryl.floatValue + theAps.floatValue + theSds.floatValue + theTemed.floatValue))];
	
	return @[theWater, theTris, theAcryl, theSds, theAps, theTemed];
}


-(void)log{
    
}


@end
