//
//  ADBNewCampioniViewController.m
// AirLab
//
//  Created by Raul Catena on 6/16/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBNewCampioniViewController.h"
#import "Object+Utilities.h"

@interface ADBNewCampioniViewController ()

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) Sample *sample;
@property (nonatomic, strong) Sample *parent;
@property (nonatomic, strong) NSMutableDictionary *properties;
@property (nonatomic, strong) UIImage *image;

@end

@implementation ADBNewCampioniViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andType:(NSString *)type orParent:(Sample *)parent
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.type = type;
        self.parent = parent;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andType:(NSString *)type orSample:(Sample *)sample
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.type = type;
        self.sample = sample;
    }
    return self;
}

-(void)touchedSegmented:(UISegmentedControl *)sender{
    if (sender == _molar || sender == _gramsLiter) {
        if (sender == _molar) {
            [_gramsLiter setSelectedSegmentIndex:UISegmentedControlNoSegment];
        }else{
            [_molar setSelectedSegmentIndex:UISegmentedControlNoSegment];
        }
    }
    if (sender == _volume || sender == _amount) {
        if (sender == _volume) {
            [_amount setSelectedSegmentIndex:UISegmentedControlNoSegment];
        }else{
            [_volume setSelectedSegmentIndex:UISegmentedControlNoSegment];
        }
    }
}

-(void)evaluateConcAmount{
    if (_sample.samAmount) {
        NSArray *array = [_sample.samAmount componentsSeparatedByString:@" "];
        self.quantity.text = [array objectAtIndex:0];
        if (array.count == 2) {
            NSString *units = [array objectAtIndex:1];
            if ([units isEqualToString:@"nL"]) {
                [_volume setSelectedSegmentIndex:0];
            }else if([units isEqualToString:@"uL"]){
                [_volume setSelectedSegmentIndex:1];
            }else if([units isEqualToString:@"mL"]){
                [_volume setSelectedSegmentIndex:2];
            }else if([units isEqualToString:@"L"]){
                [_volume setSelectedSegmentIndex:3];
            }else if([units isEqualToString:@"pg"]){
                [_amount setSelectedSegmentIndex:1];
            }else if([units isEqualToString:@"ng"]){
                [_volume setSelectedSegmentIndex:2];
            }else if([units isEqualToString:@"ug"]){
                [_volume setSelectedSegmentIndex:3];
            }else if([units isEqualToString:@"mg"]){
                [_volume setSelectedSegmentIndex:4];
            }else if([units isEqualToString:@"g"]){
                [_volume setSelectedSegmentIndex:5];
            }
        }
        

    }
    if (_sample.samConcentration) {
        NSArray *array = [_sample.samConcentration componentsSeparatedByString:@" "];
        self.conc.text = [array objectAtIndex:0];
        if (array.count == 2) {
            NSString *units = [array objectAtIndex:1];
            if ([units isEqualToString:@"pM"]) {
                [_molar setSelectedSegmentIndex:0];
            }else if([units isEqualToString:@"nM"]){
                [_molar setSelectedSegmentIndex:1];
            }else if([units isEqualToString:@"uM"]){
                [_molar setSelectedSegmentIndex:2];
            }else if([units isEqualToString:@"mM"]){
                [_molar setSelectedSegmentIndex:3];
            }else if([units isEqualToString:@"M"]){
                [_molar setSelectedSegmentIndex:4];
            }else if([units isEqualToString:@"ng/mL"]){
                [_gramsLiter setSelectedSegmentIndex:0];
            }else if([units isEqualToString:@"ug/mL"]){
                [_gramsLiter setSelectedSegmentIndex:1];
            }else if([units isEqualToString:@"mg/mL"]){
                [_gramsLiter setSelectedSegmentIndex:2];
            }
        }
    }
}

-(void)setImage:(UIImage *)image{
    _image = image;
    [_objectPicture setBackgroundImage:_image forState:UIControlStateNormal];
    if (!_image) {
        [self.objectPicture setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [self.objectPicture setTitle:@"Add photo" forState:UIControlStateNormal];
        _sample.objectPictureId = nil;
        [General saveContextAndRoll];
    }else{
        
        [self.objectPicture setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.objectPicture setTitle:@"Edit..." forState:UIControlStateNormal];
    }
}

-(File *)getTheFile{
    if(_sample.objectPictureId){
        NSArray *array = [General searchDataBaseForClass:@"File" withTerm:[_sample.objectPictureId componentsSeparatedByString:@"."].firstObject inField:@"filHash" sortBy:@"filHash" ascending:YES inMOC:self.managedObjectContext];
        
        if (array.count > 0) {
            return (File *)array.firstObject;
        }
    }
    return nil;
}

-(void)pictures{
    [self.objectPicture addTarget:self action:@selector(addPicture) forControlEvents:UIControlEventTouchUpInside];
    
    File *file = [self getTheFile];
    if (file) {
        if ([file obtainZetData]) {
            self.image = [UIImage imageWithData:file.zetData];
        }
    }
}

-(void)addPreviousProperties{
    NSData *data;
    if (_parent) {
        data = [self.parent.samData dataUsingEncoding:NSUTF8StringEncoding];
    }else{
        data = [self.sample.samData dataUsingEncoding:NSUTF8StringEncoding];
    }
    if (data) {
        NSError *error;
        self.properties = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        [General logError:error];
    }else{
        self.properties = [NSMutableDictionary dictionary];
    }
    self.type = _sample.samType;
    
    [self pictures];
}

-(void)addPicture{
    if (_image) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Edit picture" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Remove picture" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            UIAlertController *second = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *noAct = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:nil];
            [second addAction:noAct];
            
            UIAlertAction *yesAct = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                self.image = nil;
            }];
            [second addAction:yesAct];
            second.view.tintColor = [UIColor orangeColor];
            [self presentViewController:second animated:yesAct completion:nil];
        }];
        [alert addAction:delete];

        UIAlertAction *addPicture = [UIAlertAction actionWithTitle:@"Change picture" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            [General showCameraWithDelegate:self inVC:self];
        }];
        [alert addAction:addPicture];
    
        UIAlertAction *showPicture = [UIAlertAction actionWithTitle:@"Show Picture" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            [General showFile:[self getTheFile] AndPushInNavigationController:self.navigationController];
        }];
        [alert addAction:showPicture];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            
        }];
        [alert addAction:cancel];
    
        
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [General showCameraWithDelegate:self inVC:self];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:^{
        self.image = image;
    }];
}

-(void)setUpViewAndDictionary{

    if (_sample) {
        [self addPreviousProperties];
        self.nameOfSample.text = _sample.samName;
        [self evaluateConcAmount];
        
    }else if (_parent) {
        [self addPreviousProperties];
        self.parentLabel.text = [NSString stringWithFormat:@"Aliquot from %@", _parent.samName];
        [self evaluateConcAmount];
        
        self.aliquotLabel.hidden = NO;
        self.aliquots.hidden = NO;
        self.addNewPropButton.hidden = YES;
    }else{
        if (!self.properties) {
            self.properties = [NSMutableDictionary dictionary];
        }
        
        NSArray *last = [General searchDataBaseForClass:SAMPLE_DB_CLASS withTerm:_type inField:@"samType" sortBy:@"samSampleId" ascending:YES inMOC:self.managedObjectContext];
        Sample *lastSample = last.lastObject;
        if (lastSample) {
            NSError *error;
            self.properties = [NSJSONSerialization JSONObjectWithData:[lastSample.samData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
            if(error)[General logError:error];
        }
        for (NSString *key in _properties.allKeys) {
            [_properties setValue:@"" forKeyPath:key];
        }
        
        if (_parent) {
            self.parentLabel.text = [NSString stringWithFormat:@"Aliquot from %@", _parent.samName];
            self.type = _parent.samType;
        }
        
        [self.properties setValue:[NSDate date].description forKey:@"Created on"];
        
        if ([_type isEqualToString:@"DNA"]) {
            [self.properties setValue:@"" forKey:@"Species"];
        }else if([_type isEqualToString:@"Cell line"]){
            [self.properties setValue:@"" forKey:@"Species"];
        }else if([_type isEqualToString:@"RNA"]){
            [self.properties setValue:@"" forKey:@"Species"];
        }else if([_type isEqualToString:@"Protein"]){
            [self.properties setValue:@"" forKey:@"Species"];
        }else if([_type isEqualToString:@"Snap Frozen Tissue"]){
            [self.properties setValue:@"" forKey:@"Species"];
        }else if([_type isEqualToString:@"Hybridoma"]){
            [self.properties setValue:@"" forKey:@"Clone name"];
            [self.properties setValue:@"" forKey:@"Target protein"];
        }else if([_type isEqualToString:@"Primer"]){
            [self.properties setValue:@"" forKey:@"Sequence"];
            [self.properties setValue:@"" forKey:@"Tm"];
            [self.properties setValue:@"" forKey:@"Target Gene"];
        }else if([_type isEqualToString:@"PCR Primer set"]){
            [self.properties setValue:@"" forKey:@"Forward Sequence"];
            [self.properties setValue:@"" forKey:@"Reverse Sequence"];
            [self.properties setValue:@"" forKey:@"Tm"];
            [self.properties setValue:@"" forKey:@"Target Gene"];
        }else if([_type isEqualToString:@"Plasmid Prep"]){
            
        }else if([_type isEqualToString:@"Recombinant Protein"]){
            
        }else if([_type isEqualToString:@"Fixed tissue block"]){
            
        }else if([_type isEqualToString:@"Virus Prep"]){
            
        }else if([_type isEqualToString:@"Blood/Serum/Plasma"]){
            
        }else if([_type isEqualToString:@"Mouse"]){
            
        }else if([_type isEqualToString:@"Monkey"]){
            
        }else if([_type isEqualToString:@"Rat"]){
            
        }else if([_type isEqualToString:@"Minipig"]){
            
        }else if([_type isEqualToString:@"Zebra Fish"]){
            
        }else if([_type isEqualToString:@"Bacteria"]){
            
        }else if([_type isEqualToString:@"Yeast"]){
            
        }else if([_type isEqualToString:@"Seed"]){
            
        }else if([_type isEqualToString:@"Plant"]){
            
        }else if([_type isEqualToString:@"Fly"]){
            
        }else if([_type isEqualToString:@"Worm"]){
            
        }else if([_type isEqualToString:@"Other"]){
            
        }
        
        [self.tableView reloadData];
    }
    
    [self pictures];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpViewAndDictionary];
    
    if (_sample) {
        [self.qrImage setBackgroundImage:[Object imageQRForObject:_sample] forState:UIControlStateNormal];
        [self.qrImage addTarget:self action:@selector(tappedQR:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
}

-(void)tappedQR:(UIButton *)sender{
    if (sender.selected) {
        sender.frame = CGRectMake(sender.frame.origin.x, sender.frame.origin.y, sender.frame.size.width/4, sender.frame.size.height/4);
    }else{
        sender.frame = CGRectMake(sender.frame.origin.x, sender.frame.origin.y, sender.frame.size.width*4, sender.frame.size.height*4);
    }
    sender.selected = !sender.selected;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == _conc || textField == _quantity || textField == _aliquots) {
        if([textField.text componentsSeparatedByString:@"."].count>1 && [string isEqualToString:@"."])return NO;
        return [General isANumberCharacter:string];
    }
    [_properties setValue:textField.text forKey:[_properties.allKeys objectAtIndex:textField.tag]];//Maybe this is too much RCF
    return YES;
}

-(void)save{
    
    if (_nameOfSample.text.length == 0 && !_parent) {
        [General showOKAlertWithTitle:@"Please input name" andMessage:nil delegate:self];
        return;
    }
    
    if (_nameOfSample.text.length >40) {
        [General showOKAlertWithTitle:@"Sample name is too long" andMessage:nil delegate:self];
        return;
    }
    Sample *theSample;
    if (!_sample) {
        theSample = (Sample *)[General newObjectOfType:SAMPLE_DB_CLASS saveContext:YES];
    }else{
        theSample = _sample;
    }
    
    theSample.samType = _type;
    if (_parent) {
        theSample.samName = [_parent.samName stringByAppendingString:_nameOfSample.text];
    }else{
        theSample.samName = _nameOfSample.text;
    }
    theSample.samData = [General jsonObjectToString:_properties];
    
    if (_conc.text.length > 0) {
        theSample.samConcentration = _conc.text;
        NSString *unit;
        if (_molar.selectedSegmentIndex >=0) {
            unit = [_molar titleForSegmentAtIndex:_molar.selectedSegmentIndex];
        }
        if (_gramsLiter.selectedSegmentIndex >= 0) {
            unit = [_gramsLiter titleForSegmentAtIndex:_gramsLiter.selectedSegmentIndex];
        }
        if(unit.length > 0)theSample.samConcentration = [theSample.samConcentration stringByAppendingString:[NSString stringWithFormat:@" %@",unit]];
    }
    
    if (_quantity.text.length > 0) {
        theSample.samAmount = _quantity.text;
        NSString *unit;
        if (_volume.selectedSegmentIndex >= 0) {
            unit = [_volume titleForSegmentAtIndex:_volume.selectedSegmentIndex];
        }
        if (_amount.selectedSegmentIndex >= 0) {
            unit = [_amount titleForSegmentAtIndex:_amount.selectedSegmentIndex];
        }
        if(unit.length > 0)theSample.samAmount = [theSample.samAmount stringByAppendingString:[NSString stringWithFormat:@" %@",unit]];
    }
    
    if (_parent) {
        [General doLinkForProperty:@"parent" inObject:theSample withReceiverKey:@"samParentId" fromDonor:_parent withPK:@"samSampleId"];
        if (_aliquots.text.length > 0  && _aliquots.text.intValue > 1 && _aliquots.text.intValue < 100) {
            for (int x = 1; x<_aliquots.text.intValue; x++) {
                Sample *clone = (Sample *)[IPCloner clone:theSample inContext:self.managedObjectContext];
                clone.samName = [theSample.samName stringByAppendingString:[NSString stringWithFormat:@"_%i", x+1]];
                clone.samData = theSample.samData.copy;
                NSLog(@"The name of the clone %@", clone.samName);
                [General doLinkForProperty:@"parent" inObject:clone withReceiverKey:@"samParentId" fromDonor:_parent withPK:@"samSampleId"];
            }
        }
        theSample.samName = [theSample.samName stringByAppendingString:@"_1"];
    }
    
    if (_image) {
        [General forObject:theSample CreateImage:_image];
    }
    
    if (_sample) {
        [[IPExporter getInstance]updateInfoForObject:theSample withBlock:nil];
    }
    
    [self.delegate didAddSample:theSample];
}

- (IBAction)addNewProperty:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Name of property" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    UITextField *tv = [alertView textFieldAtIndex:0];
    return tv.text.length > 0? YES:NO;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self.properties setValue:@"" forKey:[alertView textFieldAtIndex:0].text];
        [self.tableView reloadData];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.properties.allKeys.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"User defined properties";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    for (UIView *aview in cell.contentView.subviews) {
        if ([aview isMemberOfClass:[UITextField class]]) {
            [aview removeFromSuperview];
        }
    }
    
    cell.textLabel.text = [_properties.allKeys objectAtIndex:indexPath.row];
    UITextField *field = [[UITextField alloc]initWithFrame:CGRectMake(cell.contentView.bounds.size.width - 300, 0, 280, cell.bounds.size.height)];
    field.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    field.tag = indexPath.row;
    field.delegate = self;
    field.text = [_properties valueForKey:cell.textLabel.text];
    [cell.contentView addSubview:field];
    
    [self setGrayColorInTableText:cell];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"A %@", _properties);
    if(_properties.allKeys.count-1 >= textField.tag && _properties.allKeys)
    [_properties setValue:textField.text forKey:[_properties.allKeys objectAtIndex:textField.tag]];
    NSLog(@"B");
}

@end
