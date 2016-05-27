//
//  ADBPartView.m
//  AntibodyDB
//
//  Created by Raul Catena on 6/17/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBPartView.h"
#import "UIColor+expanded.h"
#import "UIColor+Custom.h"
#import "CustomWebView.h"
#import "Part.h"
#import "File.h"
#import "ZFilePart.h"
#import "ADBApplicationType.h"

#define GAP 30
#define FONT_SIZE 19.0f
#define CELL_CONTENT_WIDTH 630.0f
#define CELL_CONTENT_MARGIN 10.0f
#define HEADER_HEIGHT 25.0f
#define HEADER_LEFT_MARGIN 5.0f
#define FONT_SIZE_1 17.0f

@interface ADBPartView ()

@property (nonatomic, strong) Part *part;
@property (nonatomic, strong) UIButton *controlButton;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ADBPartView


-(void)setHeaderWithPart:(Part *)part{
    //Header
    _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, HEADER_HEIGHT)];
    _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UILabel *header = [[UILabel alloc]initWithFrame:CGRectMake(HEADER_LEFT_MARGIN, 0, self.bounds.size.width/2, HEADER_HEIGHT)];
    header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    header.text = [NSString stringWithFormat:@"%@ %@",[General getDateFromDescription:part.createdAt], [General getHourFromDescription:part.createdAt]];
    header.textColor = [UIColor orangeColor];
    [_headerView addSubview:header];
    if (part.prtClosedAt.length > 0) {
        header.text = [header.text stringByAppendingString:[NSString stringWithFormat:@"...%@ %@",[General getDateFromDescription:part.prtClosedAt], [General getHourFromDescription:part.prtClosedAt]]];
        
        UIImageView *closed = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"padlock_closed.png"]];
        closed.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        closed.frame = CGRectMake(self.bounds.size.width - 35, 0, HEADER_HEIGHT, HEADER_HEIGHT);
        [_headerView addSubview:closed];
    }else{
        UIButton *buttonClosed = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonClosed.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [buttonClosed setBackgroundImage:[UIImage imageNamed:@"padlock-open.png"] forState:UIControlStateNormal];
        buttonClosed.frame = CGRectMake(self.bounds.size.width - 80, 0, HEADER_HEIGHT, HEADER_HEIGHT);
        [_headerView addSubview:buttonClosed];
        [buttonClosed addTarget:self action:@selector(closePart) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *buttonRemove = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonRemove.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [buttonRemove setBackgroundImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
        buttonRemove.frame = CGRectMake(self.bounds.size.width - HEADER_HEIGHT, 0, HEADER_HEIGHT, HEADER_HEIGHT);
        [_headerView addSubview:buttonRemove];
        [buttonRemove addTarget:self action:@selector(deletePart) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self addSubview:_headerView];
}

- (id)initWithFrame:(CGRect)frame andPart:(Part *)part
{
    self = [super initWithFrame:frame];
    if (self) {
        self.part = part;
        self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        [self setHeaderWithPart:_part];
        
        if ([part.prtType isEqualToString:@"text"]) {
            
            float heigth = [General calculateHeightedLabelForLabelWithText:_part.prtText andWidth:self.bounds.size.width andFontSize:FONT_SIZE_1];
            
            UITextView *txtView = [[UITextView alloc]initWithFrame:CGRectMake(HEADER_LEFT_MARGIN, HEADER_HEIGHT, self.bounds.size.width - 2*HEADER_HEIGHT, MAX(100, heigth + 20))];
            txtView.text = part.prtText;
            txtView.font = [UIFont systemFontOfSize:FONT_SIZE_1];
            txtView.textColor = [UIColor darkGrayColor];
            //Mejora el recálculo
            CGSize sizeRecal = txtView.contentSize;
            self.bounds = CGRectMake(0, 0, self.bounds.size.width, 30+sizeRecal.height);
            txtView.delegate = self;
            [self addSubview:txtView];
            
            if (part.prtClosedAt.length > 0)txtView.userInteractionEnabled = NO;
        }
        
        if ([part.prtType isEqualToString:@"pan"]) {

            self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(HEADER_LEFT_MARGIN, HEADER_HEIGHT, self.bounds.size.width, [self sizeOfTable]) style:UITableViewStylePlain];
            _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            _tableView.delegate = self;
            _tableView.dataSource = self;
            [self addSubview:_tableView];
            self.bounds = CGRectMake(0, 0, self.bounds.size.width, [self sizeOfTable] + 30);
        }
        
        if ([part.prtType isEqualToString:@"pic"]) {
            if(_part.prtClosedAt.length == 0){
                self.controlButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [_controlButton setBackgroundImage:[UIImage imageNamed:@"brush.png"] forState:UIControlStateNormal];
                _controlButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                [_controlButton addTarget:self action:@selector(doodButton:) forControlEvents:UIControlEventTouchUpInside];
                [_controlButton addTarget:self action:@selector(doodButton:) forControlEvents:UIControlEventTouchUpInside];
                _controlButton.frame = CGRectMake(self.bounds.size.width - 125, 0, HEADER_HEIGHT, HEADER_HEIGHT);
                [_headerView addSubview:_controlButton];
            }
            
            __block UIImage *image = [UIImage imageWithData:[[(ZFilePart *)part.fileparts.anyObject file] zetData]];
            if (image) {
                [self setImage:image];
            }else{
                if (part.fileparts.count > 0) {
                    dispatch_queue_t down = dispatch_queue_create("downQ", NULL);
                    dispatch_async(down, ^{
                        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.raulcatena.com/apiLabPad/app_photos/%@.jpg", [(ZFilePart *)part.fileparts.anyObject file].filHash]]]];
                        NSLog(@"Trying to download http://www.raulcatena.com/apiLabPad/app_photos/%@.jpg", [(ZFilePart *)part.fileparts.anyObject file].filHash);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (image) [self setImage:image];
                        });
                        
                    });
                }
            }
            
        }
        if ([part.prtType isEqualToString:@"fil"]) {
            if (part.zetUnscrolled.boolValue) {
                self.controlButton = [UIButton buttonWithType:UIButtonTypeCustom];
                __block NSData *file = [(ZFilePart *)part.fileparts.anyObject file].zetData;
                if (file) {
                    NSLog(@"Lengt is %i", file.length);
                    [self setFile:file];
                }else{
                    if (part.fileparts.count > 0) {
                        dispatch_queue_t down = dispatch_queue_create("downQ", NULL);
                        dispatch_async(down, ^{
                            file = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.raulcatena.com/apiLabPad/app_photos/%@.%@", [(ZFilePart *)part.fileparts.anyObject file].filHash, [(ZFilePart *)part.fileparts.anyObject file].filExtension]]];
                            NSLog(@"Trying to download http://www.raulcatena.com/apiLabPad/app_photos/%@.%@", [(ZFilePart *)part.fileparts.anyObject file].filHash, [(ZFilePart *)part.fileparts.anyObject file].filExtension);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self setFile:file];
                            });
                            
                        });
                    }
                }
            }else{
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                if([[(ZFilePart *)part.fileparts.anyObject file].filExtension hasPrefix:@"ppt"])[button setBackgroundColor:[UIColor orangeColor]];
                if([[(ZFilePart *)part.fileparts.anyObject file].filExtension hasPrefix:@"doc"])[button setBackgroundColor:[UIColor blueColor]];
                if([[(ZFilePart *)part.fileparts.anyObject file].filExtension hasPrefix:@"xls"])[button setBackgroundColor:[UIColor greenColor]];
                if([[(ZFilePart *)part.fileparts.anyObject file].filExtension hasPrefix:@"pdf"])[button setBackgroundColor:[UIColor grayColor]];
                button.frame = CGRectMake(10, 30, 50, 70);
                [button setBackgroundImage:[UIImage imageNamed:@"fileb.png"] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(unscrolled) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:button];
                UILabel *titleFile = [[UILabel alloc]initWithFrame:CGRectMake(70, 30, self.bounds.size.width - 80, 70)];
                [titleFile addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(unscrolled)]];
                titleFile.textColor = [UIColor darkGrayColor];
                titleFile.text = [(ZFilePart *)part.fileparts.anyObject file].catchedInfo;
                [self addSubview:titleFile];
            }
        }
    }
    return self;
}

-(void)addButtonsToCell:(UITableViewCell *)cell atIP:(NSIndexPath *)indexPath{
    
    
    UIButton *works = [UIButton buttonWithType:UIButtonTypeCustom];
    works.tag = indexPath.row;
    [General addBorderToButton:works withColor:[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1]];
    [works setTitle:@"Works" forState:UIControlStateNormal];
    [works setTitleColor:[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1] forState:UIControlStateNormal];
    [works setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    works.frame = CGRectMake(cell.contentView.bounds.size.width - 330, 5, 100, 30);
    works.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [cell.contentView addSubview:works];
    [works addTarget:self action:@selector(yes:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *soso = [UIButton buttonWithType:UIButtonTypeCustom];
    soso.tag = indexPath.row;
    [General addBorderToButton:soso withColor:[UIColor colorWithRed:0.5 green:0.5 blue:0 alpha:1]];
    [soso setTitle:@"So so..." forState:UIControlStateNormal];
    [soso setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0 alpha:1] forState:UIControlStateNormal];
    [soso setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    soso.frame = CGRectMake(cell.contentView.bounds.size.width - 220, 5, 100, 30);
    soso.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [cell.contentView addSubview:soso];
    [soso addTarget:self action:@selector(soso:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *doesnot = [UIButton buttonWithType:UIButtonTypeCustom];
    doesnot.tag = indexPath.row;
    [General addBorderToButton:doesnot withColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]];
    [doesnot setTitle:@"Does not" forState:UIControlStateNormal];
    [doesnot setTitleColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:1] forState:UIControlStateNormal];
    [doesnot setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    doesnot.frame = CGRectMake(cell.contentView.bounds.size.width - 110, 5, 110, 30);
    doesnot.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [cell.contentView addSubview:doesnot];
    [doesnot addTarget:self action:@selector(no:) forControlEvents:UIControlEventTouchUpInside];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *title = @"iPhoneCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:title];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:title];
    }
    for (UIView *aView in cell.contentView.subviews) {
        if ([aView isMemberOfClass:[UIButton class]]) {
            [aView removeFromSuperview];
        }
    }
    
    NSDictionary *dict = [self dictForAbAtIndexPath:indexPath];

    cell.textLabel.text = [NSString stringWithFormat:@"%@ (Clone %@) - Tube# %@ | %@ ug/mL",
                           [dict valueForKey:@"Protein name"],
                           [dict valueForKey:@"Clone name"],
                           [dict valueForKey:@"Tube number"],
                           [dict valueForKey:@"Concentration"]];
    
    LabeledAntibody *lab = [self getLabeledAntibodyWithIndex:[dict valueForKey:@"LabeledAb"]];
    if (lab) {
        NSArray *validationInfo = [NSJSONSerialization JSONObjectWithData:[lab.labCellsUsedForValidation dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        BOOL found = NO;
        UIColor *color = [UIColor grayColor];
        for (NSDictionary *valiationDict in validationInfo) {
            if ([[valiationDict valueForKey:@"part"]intValue] == _part.prtPartId.intValue){
                found = YES;
                int val = [[valiationDict valueForKey:@"val"]intValue];
                switch (val) {
                    case 0:
                        color = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
                        break;
                    case 1:
                        color = [UIColor orangeColor];
                        break;
                    case 2:
                        color = [UIColor redColor];
                        break;
                    default:
                        break;
                }
            }
        }
        if(!found){
            [self addButtonsToCell:cell atIP:indexPath];
        }
        cell.textLabel.textColor = color;
        
    }else{
        cell.textLabel.textColor = [UIColor grayColor];
    }

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *catchedInfo = [NSJSONSerialization JSONObjectWithData:[_part.catchedInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    return catchedInfo.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSDictionary *catchedInfo = [NSJSONSerialization JSONObjectWithData:[_part.catchedInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    return [NSString stringWithFormat:@"Antibody panel run: %@ on %@", [ADBApplicationType applicationForInt:[[catchedInfo valueForKey:@"app"]intValue]],[catchedInfo valueForKey:@"sample"]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0f;
}

-(CGFloat)sizeOfTable{
    return [self tableView:_tableView numberOfRowsInSection:0]*[self tableView:nil heightForRowAtIndexPath:nil];
}

#pragma mark Handle the validation in Journal. BB lab
-(NSDictionary *)dictForAbAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *catchedInfo = [NSJSONSerialization JSONObjectWithData:[_part.catchedInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSDictionary *dict = [catchedInfo valueForKey:[NSString stringWithFormat:@"%li",(long)indexPath.row]];
    
    return dict;
}

-(LabeledAntibody *)getLabeledAntibodyWithIndex:(NSString *)indexInt{
    NSArray *array = [General searchDataBaseForClass:LABELEDANTIBODY_DB_CLASS withTerm:indexInt inField:@"labLabeledAntibodyId" sortBy:@"labLabeledAntibodyId" ascending:YES inMOC:[(ADBAppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext]];
    return array.lastObject;
}

-(NSDictionary *)dictionaryToAddWithOption:(int)option{
     NSDictionary *catchedInfo = [NSJSONSerialization JSONObjectWithData:[_part.catchedInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"See experiment below" forKey:@"note"];
    [dic setValue:[catchedInfo valueForKey:@"app"] forKey:@"app"];
    [dic setValue:[catchedInfo valueForKey:@"sample"] forKey:@"sample"];
    [dic setValue:[NSNumber numberWithInt:option] forKey:@"val"];
    [dic setValue:[NSNumber numberWithInt:_part.prtPartId.intValue] forKey:@"part"];
    return [NSDictionary dictionaryWithDictionary:dic];
}

-(void)addDictToNotes:(NSDictionary *)dictionary forLabeledAb:(LabeledAntibody *)lab{
    NSMutableArray *mutArray = [NSMutableArray arrayWithArray:[General arrayOfValidationNotesForLot:lab.lot andConjugate:lab]];
    [mutArray addObject:dictionary];
    NSError *error;
    if (lab) {
        lab.labCellsUsedForValidation = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:mutArray options:NSJSONWritingPrettyPrinted error:&error] encoding:NSUTF8StringEncoding];
        [[IPExporter getInstance]updateInfoForObject:lab withBlock:nil];
    }
    if (error)[General logError:error];
    
    ZLotEnsayo *linker = (ZLotEnsayo *)[General newObjectOfType:ZLOTENSAYO_DB_CLASS saveContext:YES];
    [General doLinkForProperty:@"ensayo" inObject:linker withReceiverKey:@"lenEnsayoId" fromDonor:_part.ensayo withPK:@"enyEnsayoId"];
    [General doLinkForProperty:@"lot" inObject:linker withReceiverKey:@"lenLotId" fromDonor:lab.lot withPK:@"lotLotId"];
    
    [General saveContextAndRoll];
}

-(void)addValidationWithSender:(UIButton *)sender andIndex:(int)indexVal{
    sender.selected = !sender.selected;
    if (sender.selected) {
        sender.backgroundColor = [UIColor colorWithCGColor:sender.layer.borderColor];
    }else{
        sender.backgroundColor = [UIColor whiteColor];
    }
    NSDictionary *dict = [self dictForAbAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    NSDictionary *secondDict = [self dictionaryToAddWithOption:indexVal];
    LabeledAntibody *lab = [self getLabeledAntibodyWithIndex:[dict valueForKey:@"LabeledAb"]];
    [self addDictToNotes:secondDict forLabeledAb:lab];
    
    [self.tableView reloadData];
}

-(void)yes:(UIButton *)sender{
    [self addValidationWithSender:sender andIndex:0];
}
-(void)soso:(UIButton *)sender{
    [self addValidationWithSender:sender andIndex:1];
}
-(void)no:(UIButton *)sender{
    [self addValidationWithSender:sender andIndex:2];
}





-(void)unscrolled{
    _part.zetUnscrolled = [NSNumber numberWithBool:YES];
    [self.delegate reload];
    //[General saveContextAndRoll];
}

-(void)scrollBack{
    _part.zetUnscrolled = [NSNumber numberWithBool:NO];
    [self.delegate reload];
    //[General saveContextAndRoll];
}

-(void)closePart{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Are you sure" message:@"This part will not be modifiable any longer" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = 2;
    [alert show];
    
}

-(void)deletePart{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Are you sure" message:@"This action is irreversible" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = 1;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1 && buttonIndex == 1){
        _part.prtEnsayoId = @"0";
        _part.ensayo = nil;
        [[IPExporter getInstance]updateInfoForObject:_part withBlock:nil];
        [self.delegate didDeleteSection:self];
    }
    if(alertView.tag == 2 && buttonIndex == 1){
        self.part.prtClosedAt = [NSDate date].description;
        [_headerView removeFromSuperview];
        _headerView = nil;
        [[IPExporter getInstance]updateInfoForObject:_part withBlock:nil];
        [self setHeaderWithPart:_part];
    }
}

-(void)setImage:(UIImage *)image{
    UIImageView *base = [[UIImageView alloc]initWithImage:image];
    VistaPint *iv = [[VistaPint alloc]initWithFrame:CGRectMake(5, 25, self.bounds.size.width - 10, image.size.height) andData:nil orImage:image];
    float ratio = image.size.width/self.bounds.size.width;
    
    float delta = image.size.height/ratio + 30 - self.bounds.size.height;
    
    iv.delegate = self;
    iv.frame = CGRectMake(HEADER_LEFT_MARGIN, HEADER_HEIGHT, self.bounds.size.width - 2*HEADER_HEIGHT, image.size.height/ratio);
    base.frame = iv.frame;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, 30+base.bounds.size.height);
    [self addSubview:base];
    [self addSubview:iv];
    
    if(delta>0)[self.delegate moveFromIndex:self.tag+1 pixels:delta];
}

-(void)setFile:(NSData *)data{
    if (![(ZFilePart *)_part.fileparts.anyObject file].zetData) {
        [[(ZFilePart *)_part.fileparts.anyObject file]setZetData:data];
        [General saveContextAndRoll];
    }
    NSString *mimeType = [General determineMimeType:[(ZFilePart *)_part.fileparts.anyObject file].filExtension];
    CustomWebView *preWebView = [[CustomWebView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 100)];
    preWebView.delegate = self;
    
    [preWebView loadData:data MIMEType:mimeType textEncodingName:@"utf-8" baseURL:[NSURL URLWithString:@"http://localhost/"]];
    
    CFRunLoopRunInMode((CFStringRef)NSDefaultRunLoopMode, 1, NO);
    
    CGSize contentSize = CGSizeMake([[preWebView stringByEvaluatingJavaScriptFromString:@"document.body.scrollWidth;"] floatValue],
                                    [[preWebView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"] floatValue]);
    
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, GAP, self.bounds.size.width, contentSize.height)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scrollBack)];
    tap.numberOfTouchesRequired = 2;
    [self.webView addGestureRecognizer:tap];
    
    if ([mimeType isEqualToString:@"application/pdf"]) {
        self.webView.frame = CGRectMake(0, GAP, self.bounds.size.width, preWebView.scrollView.contentSize.height);
        //[self.webView.scrollView scrollsToTop];
    }
    _webView.delegate = self;
    
    [_webView loadData:data MIMEType:mimeType textEncodingName:@"utf-8" baseURL:[NSURL URLWithString:@"http://localhost/"]];
    CFRunLoopRunInMode((CFStringRef)NSDefaultRunLoopMode, 1, NO);
    
    [self addSubview:_webView];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _webView.scrollView.scrollEnabled = NO;
    
    float delta = _webView.scrollView.contentSize.height + GAP - self.bounds.size.height;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, _webView.bounds.size.width, _webView.scrollView.contentSize.height+ GAP);
    
    if (delta > 0)[self.delegate moveFromIndex:self.tag+1 pixels:delta];
}

-(void) stopRunLoop
{
	CFRunLoopRef runLoop = [[NSRunLoop currentRunLoop] getCFRunLoop];
	CFRunLoopStop(runLoop);
	
}
-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
	[self stopRunLoop];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    //if ([NSThread isMainThread]) {
    //}
    [self stopRunLoop];
}

-(void)doodButton:(UIButton *)sender{
    sender.selected = !sender.selected;
    if(sender.selected)sender.backgroundColor = [UIColor lightGrayColor];
    else sender.backgroundColor = [UIColor clearColor];
    [self.delegate isDoodling:sender.selected];
}

-(BOOL)isDoodling{
    return _controlButton.selected;
}

-(void)dataToSave:(NSData *)data{
    [(ZFilePart *)self.part.fileparts.anyObject file].zetData = data;
    [(ZFilePart *)self.part.fileparts.anyObject file].zetUploadData = data;
    [General saveContextAndRoll];
}

-(int)colorInt{
    return 1;
}

-(void)checkTextView:(UITextView *)textV{
    CGSize size = textV.contentSize;
    textV.frame = CGRectMake(textV.frame.origin.x, textV.frame.origin.y, size.width, size.height);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height + 30);
}

-(float)calculateDeltaForFrame:(CGRect)rectBefore andAfter:(CGSize)afterSize{
    return afterSize.height - rectBefore.size.height;
}

-(void)textViewDidChange:(UITextView *)textView{
    _part.prtText = textView.text;
    [[IPExporter getInstance]updateInfoForObject:_part withBlock:nil];
    float delta = [self calculateDeltaForFrame:textView.frame andAfter:textView.contentSize];
    if (delta != 0.0f) {
         [self.delegate moveFromIndex:self.tag+1 pixels:delta];
    }
   
    [self checkTextView:textView];
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    [self.delegate textViewActive:textView];
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    [self.delegate textViewInActive:textView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
