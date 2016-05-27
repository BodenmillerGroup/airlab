//
//  General.m
//  LabPad
//
//  Created by Raul Catena on 3/3/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "General.h"
#import <CommonCrypto/CommonDigest.h>
#import <Social/Social.h>

#import "ADBInfoCommertialViewController.h"

@interface General()


@end

@implementation General

#pragma mark CoreData

+(NSManagedObjectContext *)managedObjectContext{
    return [(ADBAppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
}

+(NSArray *)searchDataBaseForClass:(NSString *)className withTerm:(NSString *)term inField:(NSString *)field sortBy:(NSString *)sortFactor ascending:(BOOL)ascending inMOC:(NSManagedObjectContext *)moc{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:className inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", field, term];
    fetchRequest.predicate = predicate;
    if (!term) {
        fetchRequest.predicate = nil;
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortFactor ascending:ascending];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
    NSLog(@"obtained %lu results from query %@ in %@ field of %@", (unsigned long)results.count, term, field, className);
    return results;
}

+(NSArray *)searchDataBaseForClass:(NSString *)className withTermContained:(NSString *)term inField:(NSString *)field sortBy:(NSString *)sortFactor ascending:(BOOL)ascending inMOC:(NSManagedObjectContext *)moc{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:className inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K contains [cd] %@", field, term];
    fetchRequest.predicate = predicate;
    if (!term) {
        fetchRequest.predicate = nil;
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortFactor ascending:ascending];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
    NSLog(@"obtained %lu results from query %@ in %@ field of %@", (unsigned long)results.count, term, field, className);
    return results;
}

+(NSArray *)searchDataBaseForClass:(NSString *)className withBOOL:(BOOL)boolValue inField:(NSString *)field sortBy:(NSString *)sortFactor ascending:(BOOL)ascending inMOC:(NSManagedObjectContext *)moc{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:className inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate;
    if (boolValue) {
        predicate = [NSPredicate predicateWithFormat:@"%K == YES", field];
    }else{
        predicate = [NSPredicate predicateWithFormat:@"%K == NO", field];
    }
    fetchRequest.predicate = predicate;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortFactor ascending:ascending];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
    //NSLog(@"obtained %i results from query %@ in %@ field of %@", results.count, field, className);
    return results;
}

+(NSArray *)searchDataBaseForClass:(NSString *)className withDictionaryOfTerms:(NSDictionary *)dictOfTerms sortBy:(NSString *)sortFactor ascending:(BOOL)ascending inMOC:(NSManagedObjectContext *)moc{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:className inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in dictOfTerms) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", key, [dictOfTerms objectForKey:key]];
        [array addObject:predicate];
    }
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:array];
    fetchRequest.predicate = predicate;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortFactor ascending:ascending];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
    return results;
}

+(NSArray *)searchDataBaseForClass:(NSString *)className sortBy:(NSString *)sortFactor ascending:(BOOL)ascending inMOC:(NSManagedObjectContext *)moc{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:className inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortFactor ascending:ascending];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
    return results;
}


#pragma mark ALERTS

+(void)incorrectDataInput:(ADBMasterViewController *)delegate{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Incorrect Data" message:@"Make sure you type the right email address and password" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [delegate dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:ok];
    [[[(ADBAppDelegate *)[UIApplication sharedApplication].delegate window]visibleViewController]presentViewController:alert animated:YES completion:nil];
    //[delegate presentViewController:alert animated:YES completion:nil];
    
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Incorrect Data" message:@"Make sure you type the right email address and password" delegate:delegate cancelButtonTitle:@"Try again" otherButtonTitles:@"Reset password", nil];
//    alert.tag = 2;
//    [alert show];
}

+(void)noConnection:(ADBMasterViewController *)delegate{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No network" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [delegate dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:ok];
    [[[(ADBAppDelegate *)[UIApplication sharedApplication].delegate window]visibleViewController]presentViewController:alert animated:YES completion:nil];
    //[delegate presentViewController:alert animated:YES completion:nil];
    
    //[[[UIAlertView alloc]initWithTitle:@"No network" message:nil delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
}


#pragma mark connetions

+(NSMutableURLRequest *)callToAPI:(NSString *)urlSuffix withPost:(NSString *)post{
    //NSURL *urlLab = [NSURL URLWithString:[NSString stringWithFormat:@"http:///api/%@", urlSuffix]];
    NSURL *urlLab;
    if([urlSuffix hasPrefix:@"http"]){
        urlLab = [NSURL URLWithString:urlSuffix];
    }else{
        urlLab = [NSURL URLWithString:[NSString stringWithFormat:@"https://yourdomain.com/apiLabPad/api/%@", urlSuffix]];//Add here your own domain where API is deployed
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlLab cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"POST"];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    [request setHTTPBody:postData];
    return request;
}

+(NSMutableURLRequest *)callToGetAPIWithSuffix:(NSString *)urlSuffix{
    NSURL *urlLab = [NSURL URLWithString:[NSString stringWithFormat:@"https://yourdomain.com/apiLabPad/api/%@", urlSuffix]];//Add here your won domain where API is deployed
    NSLog(@"Calling %@", urlLab.absoluteString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlLab cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];
    return request;
}

+(NSMutableURLRequest *)callToGetAPI:(NSString *)url{
    NSLog(@"Calling %@", url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"GET"];
    return request;
}

+(NSMutableURLRequest *)photoUpload:(NSData *)photoData withName:(NSString *)name{
    
    // Dictionary that holds post parameters. You can set your post parameters that your server accepts or programmed to accept.
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = [NSString stringWithFormat:@"----------V2ymHFg03ehbqgZCaKO6jy"];
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant = [NSString stringWithFormat:@"userfile"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    if (photoData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpg\"\r\n", FileParamConstant, name] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:photoData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];

    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set the URL
    NSString *urlString = @"https://yourdomain.com/apiLabPad/api/uploadFileGAE";//Add your own domain here, where API is deployed
    [request setURL:[NSURL URLWithString:urlString]];
    
    /*NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", name] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:photoData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];*/
    
    return request;
}

+(NSMutableURLRequest *)fileUpload:(NSData *)data withName:(NSString *)name andExtension:(NSString *)ext{
    NSLog(@"uploading %@.%@", name, ext);
    // Dictionary that holds post parameters. You can set your post parameters that your server accepts or programmed to accept.
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = [NSString stringWithFormat:@"----------V2ymHFg03ehbqgZCaKO6jy"];
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant = [NSString stringWithFormat:@"userfile"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    if (data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.%@\"\r\n", FileParamConstant, name, ext] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: multipart/form-data\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set the URL
    NSString *urlString = @"https://yourdomain.com/apiLabPad/api/uploadFileGAE";//Add your domain here, where API is deployed
    [request setURL:[NSURL URLWithString:urlString]];
    
    return request;
}

+(BOOL)isDataZero:(NSData *)data{
    return [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] isEqualToString:@"0"];
}

+(BOOL)isJSONEmpty:(NSData *)data{
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if(array.count == 0)return YES;else return NO;
}

#pragma mark dates

+(NSString *)getDateFromDescription:(NSString *)descriptionOfTime{
    NSString *string;
    if (descriptionOfTime != (id)[NSNull null]) {
        NSArray *array = [descriptionOfTime componentsSeparatedByString:@" "];
        if (array.count > 0) {
            string = [array objectAtIndex:0];
        }
    }
    return string;
}

+(NSString *)getHourFromDescription:(NSString *)descriptionOfTime{
    NSString *string;
    if (descriptionOfTime != (id)[NSNull null]) {
        NSArray *array = [descriptionOfTime componentsSeparatedByString:@" "];
        if (array.count > 1) {
            string = [array objectAtIndex:1];
        }
    }
    return string;
}

+(NSDate *)getNSDateFromDescription:(NSString *)descriptionOfTime{
    NSDate *date = nil;
    if (descriptionOfTime != (id)[NSNull null]) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ";
        NSString *putPlusBack = [descriptionOfTime stringByReplacingOccurrencesOfString:@"  " withString:@" +"];
        date = [dateFormatter dateFromString:putPlusBack];
    }
    return date;
}

+(NSArray *)validExtensionsForFile{
    return [NSArray arrayWithObjects:@"jpg", @"png", @"doc", @"docx", @"rtf", @"xls", @"xlsx", @"ppt", @"pptx", @"txt", @"html", @"pdf", nil];
}

#pragma mark encryption

/*+(NSString *)stringToSha1:(NSString *)str{
    NSString *hash;
    
    return hash;
}*/


NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

+(NSString *)randomStringWithLength:(int)len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length]) % [letters length]]];
    }
    
    return randomString;
}

+(NSString *)stringToSha1:(NSString *)str{
    const char *s = [str cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
    
    // This is the destination
    uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
    // This one function does an unkeyed SHA1 hash of your hash data
    CC_SHA1(keyData.bytes, (int)keyData.length, digest);
    
    // Now convert to NSData structure to make it usable again
    NSData *out = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    // description converts to hex but puts <> around it and spaces every 4 bytes
    NSString *hash = [out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    NSLog(@"Hash is %@ for string %@", hash, str);
    
    return hash;
}

+(NSString *)utfEncode:(NSString *)str{
    NSString * encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                   NULL,
                                                                                   (CFStringRef)str,
                                                                                   NULL,
                                                                                   (CFStringRef)@"ÁÉÍÓÚáéíóúÀÈÌÒÙàèìòùçÇñÑ!*'();:@&=$,/?%#[]", //The characters you want to replace go here
                                                                                   kCFStringEncodingUTF8 ));
    return encodedString;
}

/*
 - (NSString *)sha1:(NSString *)str {
 const char *cStr = [str UTF8String];
 unsigned char result[CC_SHA1_DIGEST_LENGTH];
 CC_SHA1(cStr, strlen(cStr), result);
 NSString *s = [NSString  stringWithFormat:
 @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
 result[0], result[1], result[2], result[3], result[4],
 result[5], result[6], result[7],
 result[8], result[9], result[10], result[11], result[12],
 result[13], result[14], result[15],
 result[16], result[17], result[18], result[19]
 ];
 
 return s;
 }
 
 - (NSString *)md5:(NSString *)str {
 const char *cStr = [str UTF8String];
 unsigned char result[CC_MD5_DIGEST_LENGTH];
 CC_MD5(cStr, strlen(cStr), result);
 NSString *s = [NSString  stringWithFormat:
 @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
 result[0], result[1], result[2], result[3], result[4],
 result[5], result[6], result[7],
 result[8], result[9], result[10], result[11], result[12],
 result[13], result[14], result[15]
 ];
 
 return s;
 }
 */
+(void)logError:(NSError *)error{
    NSLog(@"Error %@ %@", error, error.userInfo);
}

+(void)addBorderToButton:(UIButton *)button withColor:(UIColor *)color{
    button.layer.borderColor = color.CGColor;
    button.layer.borderWidth = 1.0f;
    button.layer.cornerRadius = 4.0f;
}

+(void)showOKAlertWithTitle:(NSString *)title andMessage:(NSString *)message delegate:(ADBMasterViewController *)delegate{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [delegate dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:ok];
    
    [[[(ADBAppDelegate *)[UIApplication sharedApplication].delegate window]visibleViewController]presentViewController:alert animated:YES completion:nil];
    
    //[delegate presentViewController:alert animated:YES completion:nil];
    
    //[[[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
}

+(float)calculateHeightedLabelForLabelWithText:(NSString *)text andWidth:(float)width andFontSize:(float)fontSize{
    
	CGSize constraint = CGSizeMake(width, 20000.0f);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    CGRect size3 = [text boundingRectWithSize:constraint
                                      options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                   attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:fontSize], NSParagraphStyleAttributeName : paragraphStyle }
                                      context:nil];
    
    return size3.size.height;
}

+(NSString *)secondsToTime:(int)seconds{
    int horas = seconds/3600;
    int minutos = (seconds - horas*3600)/60;
    int secondsLeft = seconds - horas*3600 - minutos*60;
    NSString *hor = [NSString stringWithFormat:@"%i", horas];
    NSString *min = [NSString stringWithFormat:@"%i", minutos];
    NSString *sec = [NSString stringWithFormat:@"%i", secondsLeft];
    if (hor.length < 2)hor = [@"0" stringByAppendingString:hor];
    if (min.length < 2)min = [@"0" stringByAppendingString:min];
    if (sec.length < 2)sec = [@"0" stringByAppendingString:sec];
    return [NSString stringWithFormat:@"%@:%@:%@", hor, min, sec];
}

+(void)showCameraWithDelegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate inVC:(UIViewController *)viewController{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = delegate;
    picker.view.tintColor = [UIColor orangeColor];
    //picker.modalPresentationStyle = UIModalPresentationFormSheet;
    UIAlertController *controllerAlert = [UIAlertController alertControllerWithTitle:@"Add picture" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *photoRoll = [UIAlertAction actionWithTitle:@"From Camera Roll" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [viewController presentViewController:picker animated:YES completion:nil];
    }];
    [controllerAlert addAction:photoRoll];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"From Live Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }else{
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        };
        [viewController presentViewController:picker animated:YES completion:nil];
    }];
    [controllerAlert addAction:camera];
    
    //Select from filesystem //TODO
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
       
    }];
    [controllerAlert addAction:cancel];
    controllerAlert.view.tintColor = [UIColor orangeColor];
    
    [viewController presentViewController:controllerAlert animated:YES completion:nil];
}

+(NSString *)returnMessageAftercheckName:(NSString *)name lenghtTo:(int)maxLenght{
    NSString *message = nil;
    if(name.length == 0){
        message = @"Name required";
    }
    if(name.length > 20){
        message = @"Name is too long";
    }
    return message;
}

+(NSString *)createDataPostWithDictionary:(NSDictionary *)dictionary{
    NSMutableString *string = [NSMutableString stringWithFormat:@"data={"];
    for(NSString *key in dictionary.allKeys){
        [string appendString:[NSString stringWithFormat:@"\"%@\":\"%@\",", key, [dictionary valueForKey:key]]];
    }
    [string deleteCharactersInRange:NSMakeRange(string.length -1, 1)];
    [string appendString:@"}"];
    NSLog(@"Did generate %@", string);
    return [NSString stringWithString:string];
}

+(BOOL)checkEmailIsValid:(NSString *)email{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isInteger:(NSString *)toCheck {
    if([toCheck intValue] != 0) {
        return true;
    } else if([toCheck isEqualToString:@"0"]) {
        return true;
    } else {
        return false;
    }
}

+(NSString *)titleForTube:(id)tube{
    NSString *theTitle;
    if ([tube isMemberOfClass:[ReagentInstance class]]) {
        ReagentInstance *reag = (ReagentInstance *)tube;
        theTitle = reag.comertialReagent.comName;
    }
    if ([tube isMemberOfClass:[LabeledAntibody class]]) {
        LabeledAntibody *reag = (LabeledAntibody *)tube;
        theTitle = [NSString stringWithFormat:@"%@\n%@%@", reag.labBBTubeNumber, reag.tag.tagName, reag.tag.tagMW];
    }
    if ([tube isMemberOfClass:[Sample class]]) {
        
        Sample *reag = (Sample *)tube;
        
        theTitle = reag.samName;
        
        Sample *superSample = reag.parent;
        
        while (superSample) {
            theTitle = [superSample.samName stringByAppendingString:[NSString stringWithFormat:@" %@", theTitle]];
            superSample = superSample.parent;
        }
        
    }
    return theTitle;
}

+(NSString *)convertAngularDateToNSDateDescription:(NSString *)angDate{
    NSString *theDate;
    NSArray *compsDate = [angDate componentsSeparatedByString:@" "];
    if (compsDate.count> 4) {
        //Do special procesing write function
        theDate = [@"" stringByAppendingString:[compsDate objectAtIndex:3]];
        theDate = [theDate stringByAppendingString:@"-"];
        if ([[compsDate objectAtIndex:1]isEqualToString:@"Jan"]) {
            theDate = [theDate stringByAppendingString:@"01"];
        }
        if ([[compsDate objectAtIndex:1]isEqualToString:@"Feb"]) {
            theDate = [theDate stringByAppendingString:@"02"];
        }
        if ([[compsDate objectAtIndex:1]isEqualToString:@"Mar"]) {
            theDate = [theDate stringByAppendingString:@"03"];
        }
        if ([[compsDate objectAtIndex:1]isEqualToString:@"Apr"]) {
            theDate = [theDate stringByAppendingString:@"04"];
        }
        if ([[compsDate objectAtIndex:1]isEqualToString:@"May"]) {
            theDate = [theDate stringByAppendingString:@"05"];
        }
        if ([[compsDate objectAtIndex:1]isEqualToString:@"Jun"]) {
            theDate = [theDate stringByAppendingString:@"06"];
        }
        if ([[compsDate objectAtIndex:1]isEqualToString:@"Jul"]) {
            theDate = [theDate stringByAppendingString:@"07"];
        }
        if ([[compsDate objectAtIndex:1]isEqualToString:@"Aug"]) {
            theDate = [theDate stringByAppendingString:@"08"];
        }
        if ([[compsDate objectAtIndex:1]isEqualToString:@"Sep"]) {
            theDate = [theDate stringByAppendingString:@"09"];
        }
        if ([[compsDate objectAtIndex:1]isEqualToString:@"Oct"]) {
            theDate = [theDate stringByAppendingString:@"10"];
        }
        if ([[compsDate objectAtIndex:1]isEqualToString:@"Nov"]) {
            theDate = [theDate stringByAppendingString:@"11"];
        }
        if ([[compsDate objectAtIndex:1]isEqualToString:@"Dec"]) {
            theDate = [theDate stringByAppendingString:@"12"];
        }
        theDate = [theDate stringByAppendingString:@"-"];
        theDate = [theDate stringByAppendingString:[compsDate objectAtIndex:2]];
        theDate = [theDate stringByAppendingString:@" "];
        theDate = [theDate stringByAppendingString:[compsDate objectAtIndex:4]];
    }else{
        theDate = angDate;
    }
    return theDate;
}

+(NSString *)titleForSideOfTube:(id)tube{
    NSString *theTitle;
    if ([tube isMemberOfClass:[ReagentInstance class]]) {
        ReagentInstance *reag = (ReagentInstance *)tube;
        Person *orderer = [General searchDataBaseForClass:PERSON_DB_CLASS withTerm:reag.reiOrderedBy inField:@"perPersonId" sortBy:@"perPersonId" ascending:YES inMOC:[General managedObjectContext]].lastObject;
        theTitle = [NSString stringWithFormat:@"%@\n%@", reag.comertialReagent.comName, orderer.perName];
    }
    if ([tube isMemberOfClass:[LabeledAntibody class]]) {
        LabeledAntibody *reag = (LabeledAntibody *)tube;
        NSString *person;
        if ([reag.labContributorId rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound) {
            person = reag.labContributorId;
        }else{
            person = [(Person *)[General searchDataBaseForClass:PERSON_DB_CLASS withTerm:reag.labContributorId inField:@"perPersonId" sortBy:@"perPersonId" ascending:YES inMOC:[General managedObjectContext]].lastObject perName];
        }
        NSString *theDate = [General convertAngularDateToNSDateDescription:reag.labDateOfLabeling];
        
        theTitle = [NSString stringWithFormat:@"%@ | %@%@\n%@ ug/mL\n%@%@|%@\n%@|%@", reag.labBBTubeNumber, reag.tag.tagName, reag.tag.tagMW, reag.labConcentration, reag.lot.clone.cloIsPhospho.boolValue?@"p":@"",reag.lot.clone.protein.proName, reag.lot.clone.cloName, [General getDateFromDescription:theDate], reag.labContributorId];
    }
    if ([tube isMemberOfClass:[Sample class]]) {
        //TODO add sample search support
        Sample *reag = (Sample *)tube;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[reag.samData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSString *values;
        for (NSString *value in dict.allValues) {
            if (!values) {
                values = value;
                continue;
            }
            values = [values stringByAppendingString:[NSString stringWithFormat:@"\n%@", value]];
        }
        theTitle = values;
    }
    return theTitle;
}

#pragma mark PDF and sharing

#pragma pdf generation simple picture of screen
#pragma pdf generation simple picture of screen

/*+(NSData *)generatePDFData:(UIView *)aView{
    
    // Creates a mutable data object for updating with binary data, like a byte array
    NSMutableData *pdfData = [NSMutableData data];
    
    // Points the pdf converter to the mutable data object and to the UIView to be converted
    UIGraphicsBeginPDFContextToData(pdfData, CGRectMake(0, 0, aView.bounds.size.width, aView.bounds.size.height), nil);//aView.bounds, nil);//Cambiar CGRect para cambiar tamanio del pdf
    if ([aView isMemberOfClass:[UIScrollView class]] || [aView isMemberOfClass:[UITableView class]]) {NSLog(@"Is it scrollview");
    
        UIScrollView *scroll = (UIScrollView *)aView;
        
        CGPoint beginning = scroll.contentOffset;

        
        float x = scroll.contentSize.height/aView.bounds.size.height;
        x = ceil((double)x);
        int i = x;
        
        for (int j = 0 ; j< i ; j++){
            if ([scroll isMemberOfClass:[UITableView class]]) {
                if (j*10 < [(UITableView *)scroll numberOfRowsInSection:0]) {
                    [(UITableView *)scroll scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:j*10 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }else{
                    break;
                }
            }else{
                [scroll setContentOffset:CGPointMake(0, j*aView.bounds.size.height) animated:NO];
            }
            UIGraphicsBeginPDFPage();
            CGContextRef pdfContext = UIGraphicsGetCurrentContext();
            [scroll.superview.layer renderInContext:pdfContext];
        }
        //[scroll setContentOffset:beginning animated:YES];
    }else{
        UIGraphicsBeginPDFPage();
        CGContextRef pdfContext = UIGraphicsGetCurrentContext();
        [aView.layer renderInContext:pdfContext];
    }
    
    
    //[aView setContentOffset:CGPointMake(0, aView.bounds.size.height-self.view.bounds.size.height) animated:YES];
    
    UIGraphicsEndPDFContext();
    
    
    return pdfData;
}*/

+(NSData *)generatePDFData:(UIView *)aView{
    
    // Creates a mutable data object for updating with binary data, like a byte array
    NSMutableData *pdfData = [NSMutableData data];
    
    // Points the pdf converter to the mutable data object and to the UIView to be converted
    
    if ([aView isMemberOfClass:[UIScrollView class]] || [aView isMemberOfClass:[UITableView class]]) {
        
        if ([aView isMemberOfClass:[UITableView class]]) {
            UIScrollView *scroll = (UIScrollView *)aView;
            CGRect initialFrame = aView.frame;
            
            scroll.bounds = CGRectMake(0, 0, scroll.contentSize.width, scroll.contentSize.height);
            //Cambiar CGRect para cambiar tamanio del pdf
            //CGRectZero generates A4
            UIGraphicsBeginPDFContextToData(pdfData, CGRectMake(0, 0, scroll.bounds.size.width, scroll.bounds.size.height), nil);//aView.bounds, nil);//
            
            UIGraphicsBeginPDFPage();
            CGContextRef pdfContext = UIGraphicsGetCurrentContext();
            [scroll.layer renderInContext:pdfContext];
            
            scroll.frame = initialFrame;
            //[scroll setContentOffset:beginning animated:YES];
        }
        if ([aView isMemberOfClass:[UIScrollView class]]) {
            UIScrollView *scroll = (UIScrollView *)aView;
            CGRect initialFrame = aView.frame;
            scroll.bounds = CGRectMake(0, 0, scroll.contentSize.width, scroll.contentSize.height);
            CGRect framePage = CGRectMake(0, 0, initialFrame.size.width, 1600);
            
            
            
            NSMutableArray *allViews = aView.subviews.mutableCopy;
            
            UIGraphicsBeginPDFContextToData(pdfData, framePage, nil);//aView.bounds, nil);//
            
            BOOL done = NO;
            
            do{NSLog(@"Loop");
                UIView *printCanvas = [[UIView alloc]initWithFrame:framePage];
                float cumul = 0.0f;
                float firstY = [(UIView *)[allViews firstObject]frame].origin.y;
                
                if (allViews.count == 0) {
                    done = YES;
                    break;
                }
                int initialSize = (int)allViews.count;
                for (int x = 0; x<initialSize; x++) {
                    
                    UIView *alaView = [allViews firstObject];
                    NSLog(@"CumuFrame %f %f", alaView.frame.origin.y, alaView.frame.origin.y - firstY);
                    alaView.frame = CGRectMake(alaView.frame.origin.x, alaView.frame.origin.y - firstY, alaView.frame.size.width, alaView.frame.size.height);
                    cumul = cumul + alaView.bounds.size.height;
                    if (alaView.bounds.size.height > 1600) {
                        alaView.bounds = framePage;
                        for (int y = 0; y<ceil(alaView.bounds.size.height/1600); y++) {
                            //[(UIScrollView *)alaView scrollRectToVisible:CGRectMake(0, 1600*y, initialFrame.size.width, 1600) animated:NO];
                            [printCanvas addSubview:alaView];
                            UIGraphicsBeginPDFPage();
                            CGContextRef pdfContext = UIGraphicsGetCurrentContext();
                            [printCanvas.layer renderInContext:pdfContext];
                            [alaView removeFromSuperview];
                        }
                        [allViews removeObjectAtIndex:0];
                        break;
                    }
                    
                    if (cumul < 1600) {//There is room
                        
                        [printCanvas addSubview:alaView];
                        [allViews removeObjectAtIndex:0];
                    }else break;//Change page
                    
                }
                
                UIGraphicsBeginPDFPage();
                CGContextRef pdfContext = UIGraphicsGetCurrentContext();
                [printCanvas.layer renderInContext:pdfContext];
                
            }while (!done);
            
            scroll.frame = initialFrame;
        }
        
            /**/
        
    }else{
        UIGraphicsBeginPDFContextToData(pdfData, CGRectMake(0, 0, aView.bounds.size.width, aView.bounds.size.height), nil);//aView.bounds, nil);//
        UIGraphicsBeginPDFPage();
        CGContextRef pdfContext = UIGraphicsGetCurrentContext();
        [aView.layer renderInContext:pdfContext];
    }
    
    
    //[aView setContentOffset:CGPointMake(0, aView.bounds.size.height-self.view.bounds.size.height) animated:YES];
    
    UIGraphicsEndPDFContext();
    
    
    return pdfData;
}

#pragma delegate method in pdf generation

+(void)generatePDFFromScrollView:(UIView *)scrollView onVC:(UIViewController *)controller{
    //CGRect previous = self.scrollView.bounds;
    //self.scrollView.bounds = CGRectMake(0, 0, previous.size.width, previous.size.height * 1.3);
    NSData *pdfData = [General generatePDFData:scrollView];
    UIWebView *webView = [[UIWebView alloc]initWithFrame:controller.view.frame];
    [webView loadData:pdfData MIMEType:@"application/pdf" textEncodingName:@"UTF-8" baseURL:nil];
    UIViewController *vc = [[UIViewController alloc]init];
    vc.view.frame = controller.view.frame;
    vc.view = webView;
    [controller.navigationController pushViewController:vc animated:YES];
}


#pragma mark pushPaper

+(void)sendToFriend:(UIButton *)sender withData:(NSData *)data withSubject:(NSString *)subject fileName:(NSString *)fileName fromVC:(UIViewController *)controller{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = controller;
	
	[picker setSubject:subject];
	
	// Fill out the email body text
	NSString *messageBody = [NSString stringWithFormat:@"Generated with AirLab, Inc."];
	[picker setMessageBody:messageBody isHTML:YES];
    [picker addAttachmentData:data mimeType:@"application/pdf" fileName:fileName];
    
	//picker.navigationBar.barStyle = UIBarStyleBlack; // choose your style, unfortunately, Translucent colors behave quirky.
	picker.navigationBar.tintColor = [UIColor colorWithRed:0 green:0.1 blue:0.35 alpha:1];
	picker.modalPresentationStyle = UIModalPresentationFormSheet;
	[controller presentViewController:picker animated:YES completion:nil];
}

+(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			break;
		case MFMailComposeResultFailed:
			break;
			
		default:
		{
            //[General showOKAlertWithTitle:@"Email failed" andMessage:nil];

		}
			
			break;
	}
	[controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

//-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{

//}

#pragma print

+(void)printPDF:(NSData *)data andSender:(UIBarButtonItem *)sender withJobName:(NSString *)jobName{
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    if (pic && [UIPrintInteractionController canPrintData:data]) {
        pic.delegate = self;
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName = jobName;
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        pic.printInfo = printInfo;
        pic.showsPageRange = YES;
        pic.printingItem = data;
        
        void(^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *pic, BOOL completed, NSError *error){
            if (!completed && error) {
                //[General showOKAlertWithTitle:@"Printing failed" andMessage:nil];
            }
        };
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [pic presentFromBarButtonItem:sender animated:YES completionHandler:completionHandler];
        }else{
            [pic presentAnimated:YES completionHandler:completionHandler];
        }
    }
}


+(void)print:(UIScrollView *)aView fromSender:(UIBarButtonItem *)sender withJobName:(NSString *)jobName{
    [self printPDF:[self generatePDFData:aView] andSender:sender withJobName:jobName];
}

//Add offline ID to object

+(void)offlineIdToObject:(Object *)object{
    int random = arc4random_uniform(10000000);
    object.offlineId = [NSString stringWithFormat:@"x-%i",random];
    [General saveContextAndRoll];
}

+(Object *)newObjectOfType:(NSString *)type saveContext:(BOOL)boolsave{
    Object *object;
    object = [NSEntityDescription insertNewObjectForEntityForName:type inManagedObjectContext:[General managedObjectContext]];
    [General offlineIdToObject:object];
    ADBAccountManager *manager = [ADBAccountManager sharedInstance];
    [manager addPersonGroup:[manager currentGroupPerson] toObject:object];
    if (boolsave) {
        [General saveContextAndRoll];
    }
    return object;
}

+(void)doLinkForProperty:(NSString *)property inObject:(Object *)receiver withReceiverKey:(NSString *)receiverKey fromDonor:(Object *)donor withPK:(NSString *)pkDonor{
    [receiver setValue:donor forKey:property];
    
    if ([donor valueForKeyPath:pkDonor]) {
        [receiver setValue:[donor valueForKeyPath:pkDonor] forKey:receiverKey];
    }else{
        [receiver setValue:[donor valueForKeyPath:@"offlineId"] forKey:receiverKey];
    }
}

+(void)saveContextAndRoll{
    NSError *error;
    [[General managedObjectContext] save:&error];
    if (error) {
        [[General managedObjectContext] rollback];
        [General logError:error];
    }
    [[General managedObjectContext] save:&error];
}

+(void)iPhoneBlock:(void(^)())iPhoneBlock iPadBlock:(void(^)())iPadBlock{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if(iPadBlock)iPadBlock();
    }else{
        if(iPhoneBlock)iPhoneBlock();
    }
}

+(BOOL)isIphone{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return NO;
    }else{
        return YES;
    }
}

+(BOOL)isANumberCharacter:(NSString *)string{
    BOOL isAValidCharacter;
	if ([string isEqualToString:@"0"] ||[string isEqualToString:@"1"] || [string isEqualToString:@"2"]
		|| [string isEqualToString:@"3"] || [string isEqualToString:@"4"]|| [string isEqualToString:@"5"]
		|| [string isEqualToString:@"6"] || [string isEqualToString:@"7"] || [string isEqualToString:@"8"]
		|| [string isEqualToString:@"9"] || [string isEqualToString:@"."] || [string isEqualToString:@""])  {
		isAValidCharacter = YES;
	}else {
		isAValidCharacter = NO;
	}
    return isAValidCharacter;
}

+(NSArray *)arrayOfValidationNotesForLot:(Lot *)lot andConjugate:(LabeledAntibody *)conjugate{
    NSMutableArray *mut = [NSMutableArray array];
    NSData *data = [lot.lotCellsValidation dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    if(data){
        [mut addObjectsFromArray:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error]];
        [General logError:error];
        if (conjugate) {
            NSData *data2 = [conjugate.labCellsUsedForValidation dataUsingEncoding:NSUTF8StringEncoding];
            if(data2){
                NSArray *array = [NSJSONSerialization JSONObjectWithData:data2 options:NSJSONReadingAllowFragments error:&error];
                [mut addObjectsFromArray:array];
            }
            
            [General logError:error];
        }
    }
    
    return mut;
}

+(UIColor *)colorForClone:(Clone *)clone forApplication:(int)application{//0 Flow 1 imaging
    
    
    NSArray *array = [General jsonStringToObject:clone.catchedInfo];
    
    if(!array)return nil;
    if(![array respondsToSelector:@selector(count)])return nil;
    if(array.count == 0)return nil;
    
    int red = 0;
    int green = 0;
    
    for (NSDictionary *dictionary in array) {
        int isVal = [[dictionary valueForKey:@"isVal"]intValue];
        if(isVal != 1){
            continue;
        }
        if([[dictionary valueForKey:@"app"]intValue] == 0 && application == 1)continue;
        if([[dictionary valueForKey:@"app"]intValue] == 1 && application == 0)continue;
        if([[dictionary valueForKey:@"app"]intValue] == 2 && application == 1)continue;
        if([[dictionary valueForKey:@"app"]intValue] == 3 && application == 0)continue;
        if([[dictionary valueForKey:@"app"]intValue] == 4 && application == 0)continue;
        
        int worked = [[dictionary valueForKey:@"val"]intValue];
        switch (worked) {
            case 0:
                green++;
                break;
            case 1:
                green++;
                red++;
                break;
            case 2:
                red++;
                break;
                
            default:
                break;
        }
        
    }
    int total = red + green;
    if (total == 0) {
        return nil;
    }
    float theGreen = (float)green/(float)total;
    float theRed = (float)red/(float)total;
    while (theRed >= 1 && theGreen >=1) {
        theGreen = theGreen/2;
        theRed = theRed/2;
    }
    return [UIColor colorWithRed:theRed/1.5 green:theGreen/1.5 blue:0 alpha:1];
}

+(UIColor *)colorForValidationNotesDictionary:(NSDictionary *)dictionary{
    int worked = [[dictionary valueForKey:@"val"]intValue];
    UIColor *color;
    switch (worked) {
        case 0:
            color = [UIColor colorWithRed:0 green:0.6 blue:0 alpha:0.2];
            break;
        case 1:
            color = [UIColor colorWithRed:0.6 green:0.6 blue:0 alpha:0.2];
            break;
        case 2:
            color = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:0.2];
            break;
            
        default:
            break;
    }
    return color;
}

+(UIColor *)colorForValidationNotesDictionaryArray:(NSArray *)dictionaryArray{
    int red = 0;
    int green = 0;
    
    for (NSDictionary *dictionary in dictionaryArray) {
        int isVal = [[dictionary valueForKey:@"isVal"]intValue];
        if(isVal != 1){
            continue;
        }
        /*if(![dictionary isMemberOfClass:[NSDictionary class]]){
            return nil;
        }*/
        int worked = [[dictionary valueForKey:@"val"]intValue];
        
        switch (worked) {
            case 0:
                green++;
                break;
            case 1:
                green++;
                red++;
                break;
            case 2:
                red++;
                break;
                
            default:
                break;
        }
        
    }
    int total = red + green;
    if (total == 0) {
        return [UIColor grayColor];
    }
    float theGreen = (float)green/(float)total;
    float theRed = (float)red/(float)total;
    while (theRed >= 1 && theGreen >=1) {
        theGreen = theGreen/2;
        theRed = theRed/2;
    }
    
    return [UIColor colorWithRed:theRed green:theGreen blue:0 alpha:1];
}

+(NSString *)determineMimeType:(NSString *)extension{
    NSString *mimeType;
    if ([extension isEqualToString:@"pdf"]) {
        mimeType = @"application/pdf";
    }
    if ([extension isEqualToString:@"gif"]) {
        mimeType = @"application/gif";
    }
    if ([extension isEqualToString:@"jpg"]) {
        mimeType = @"application/jpg";
    }
    if ([extension isEqualToString:@"png"]) {
        mimeType = @"application/png";
    }
    if ([extension isEqualToString:@"doc"]) {
        mimeType = @"application/msword";
    }
    if ([extension isEqualToString:@"xls"]) {
        mimeType = @"application/msexcel";
    }
    if ([extension isEqualToString:@"rtf"]) {
        mimeType = @"application/rtf";
    }
    if ([extension isEqualToString:@"ppt"]) {
        mimeType = @"application/vnd.ms-powerpoint";
    }
    if ([extension isEqualToString:@"docx"]) {
        mimeType = @"application/application/vnd.openxmlformats-officedocument.wordprocessingml.document";
    }
    if ([extension isEqualToString:@"xlsx"]) {
        mimeType = @"application/application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
    }
    if ([extension isEqualToString:@"pptx"]) {
        mimeType = @"application/application/vnd.openxmlformats-officedocument.presentationml.presentation";
    }
    if (!extension) {//This will change
        mimeType = @"application/msword";
    }
    return mimeType;
}

+(void)logData:(NSData *)data withHeader:(NSString *)header{
    NSLog(@"%@ %@", header, [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
}

+(BOOL)checkPointersAndText:(NSArray *)stuff{
    for (id test in stuff) {
            if ([(NSString *)test length] == 0) {
                return NO;
            }
    }
    return YES;
}

+(NSString *)coordinatesToString:(CLLocationCoordinate2D)coordinates{
    return [NSString stringWithFormat:@"%f,%f", coordinates.latitude, coordinates.longitude];
}

+(CLLocationCoordinate2D)stringToCoordinates:(NSString *)string{
    CLLocationCoordinate2D coordinate;
    NSArray *comps = [string componentsSeparatedByString:@","];
    
    if (comps.count == 2) {
        coordinate.latitude = [[comps objectAtIndex:0]floatValue];
        coordinate.longitude = [[comps objectAtIndex:1]floatValue];
    }
        
    return coordinate;
}

+(int)checkText:(NSString *)text orExistForObject:(NSString *)objectType inField:(NSString *)field{
    if (!text) {
        return 1;
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:objectType];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:field ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"%k == %@", field, text];
    NSError *error;
    NSArray *array = [[(ADBAppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext]executeFetchRequest:request error:&error];
    if(error)[General logError:error];
    return array.count == 0?2:3;
}

+(void)startBarSpinner{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    ADBAppDelegate *del = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
    UIViewController *root = (UIViewController *)del.window.rootViewController;
    if ([root isMemberOfClass:[UITabBarController class]]) {
        UITabBarController *cont = (UITabBarController *)root;
        BOOL found = NO;
        for (UIView *aView in cont.tabBar.subviews) {
            if ([aView isMemberOfClass:[UIActivityIndicatorView class]]) {
                found = YES;
            }
        }
        if (!found) {
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            spinner.frame = CGRectMake(root.view.bounds.size.width - 50, 5, 40, 40);
            [spinner startAnimating];
            [cont.tabBar addSubview:spinner];
            
            UILabel *loading = [[UILabel alloc]initWithFrame:CGRectMake(root.view.bounds.size.width - 125, 5, 80, 40)];
            loading.text = @"Loading...";
            loading.textColor = [UIColor orangeColor];
            [cont.tabBar addSubview:loading];
        }
    }
}

+(void)barIndicatorWithPercentage:(float)percentage{
    ADBAppDelegate *del = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
    UIViewController *root = (UIViewController *)del.window.rootViewController;
    UIProgressView *progressView;
    UIView *targetView;
    if ([root isMemberOfClass:[UITabBarController class]]) {
        UITabBarController *cont = (UITabBarController *)root;
        targetView = cont.tabBar;
        for (UIView *aView in cont.tabBar.subviews) {
            if ([aView isMemberOfClass:[UIProgressView class]]) {
                progressView = (UIProgressView *)aView;
                break;
            }
        }
    }else{
        targetView = [(UINavigationController *)root navigationBar];
        for (UIView *aView in [(UINavigationController *)root navigationBar].subviews) {
            if ([aView isMemberOfClass:[UIProgressView class]]) {
                progressView = (UIProgressView *)aView;
                break;
            }
        }
    }
    if (!progressView) {
        progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
        progressView.frame = CGRectMake(0, 0, root.view.bounds.size.width, 10);
        progressView.tintColor = [UIColor orangeColor];
        [targetView addSubview:progressView];
    }
    progressView.progress = percentage;
}

+(void)stopBarSpinner{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    ADBAppDelegate *del = (ADBAppDelegate *)[[UIApplication sharedApplication]delegate];
    UIViewController *root = (UIViewController *)del.window.rootViewController;
    if ([root isMemberOfClass:[UITabBarController class]]) {
        UITabBarController *cont = (UITabBarController *)root;
        [cont setSelectedIndex:cont.selectedIndex];
        for (UIView *aView in cont.tabBar.subviews) {
            if ([aView isMemberOfClass:[UIActivityIndicatorView class]] || [aView isMemberOfClass:[UILabel class]]
                || [aView isMemberOfClass:[UIProgressView class]]) {
                //If I do stop animating it may occur in wrong thread an takes time
                [aView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.1] ;
                //[aView removeFromSuperview];
            }
        }
        [root.view setNeedsDisplay];
    }else{
        for (UIView *aView in [(UINavigationController *)root navigationBar].subviews) {
            if ([aView isMemberOfClass:[UIProgressView class]]) {
                [aView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.1] ;
            }
        }
    }
}

+(BOOL)textField:(UITextField *)textField onlyNumbersInRange:(NSRange)range replacementString:(NSString *)string{
    NSArray *arrayOfString = [string componentsSeparatedByString:@"."];
    NSArray *wholeString = [textField.text componentsSeparatedByString:@"."];
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    BOOL isAValidCharacter;
    if ([string isEqualToString:@"0"] ||[string isEqualToString:@"1"] || [string isEqualToString:@"2"]
        || [string isEqualToString:@"3"] || [string isEqualToString:@"4"]|| [string isEqualToString:@"5"]
        || [string isEqualToString:@"6"] || [string isEqualToString:@"7"] || [string isEqualToString:@"8"]
        || [string isEqualToString:@"9"] || [string isEqualToString:@"."] || [string isEqualToString:@""])  {
        isAValidCharacter = YES;
    }else {
        isAValidCharacter = NO;
    }
    
    
    if ([arrayOfString count] == 2 && [wholeString count]>1) {
        return NO;
    }
    if (newLength >8) {
        return NO;
    }
    if (!isAValidCharacter) {
        //[General showOKAlertWithTitle:@"Only number digits (0-9) and '.' are allowed" andMessage:nil];
        return NO;
    }
    return YES;
    
    //NSUInteger newLength = [textField.text length] + [string length] - range.length;
    //return (newLength > 11) ? NO : YES;
}

+ (NSString *)stringByConvertingHTMLToPlainText:(NSString *)htmlString {
    @autoreleasepool {
        
        // Character sets
        NSCharacterSet *stopCharacters = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"< \t\n\r%C%C%C%C", (unichar)0x0085, (unichar)0x000C, (unichar)0x2028, (unichar)0x2029]];
        NSCharacterSet *newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@" \t\n\r%C%C%C%C", (unichar)0x0085, (unichar)0x000C, (unichar)0x2028, (unichar)0x2029]];
        NSCharacterSet *tagNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
        
        // Scan and find all tags
        NSMutableString *result = [[NSMutableString alloc] initWithCapacity:htmlString.length];
        NSScanner *scanner = [[NSScanner alloc] initWithString:htmlString];
        [scanner setCharactersToBeSkipped:nil];
        [scanner setCaseSensitive:YES];
        NSString *str = nil, *tagName = nil;
        BOOL dontReplaceTagWithSpace = NO;
        do {
            
            // Scan up to the start of a tag or whitespace
            if ([scanner scanUpToCharactersFromSet:stopCharacters intoString:&str]) {
                [result appendString:str];
                str = nil; // reset
            }
            
            // Check if we've stopped at a tag/comment or whitespace
            if ([scanner scanString:@"<" intoString:NULL]) {
                
                // Stopped at a comment, script tag, or other tag
                if ([scanner scanString:@"!--" intoString:NULL]) {
                    
                    // Comment
                    [scanner scanUpToString:@"-->" intoString:NULL];
                    [scanner scanString:@"-->" intoString:NULL];
                    
                } else if ([scanner scanString:@"script" intoString:NULL]) {
                    
                    // Script tag where things don't need escaping!
                    [scanner scanUpToString:@"</script>" intoString:NULL];
                    [scanner scanString:@"</script>" intoString:NULL];
                    
                } else {
                    
                    // Tag - remove and replace with space unless it's
                    // a closing inline tag then dont replace with a space
                    if ([scanner scanString:@"/" intoString:NULL]) {
                        
                        // Closing tag - replace with space unless it's inline
                        tagName = nil; dontReplaceTagWithSpace = NO;
                        if ([scanner scanCharactersFromSet:tagNameCharacters intoString:&tagName]) {
                            tagName = [tagName lowercaseString];
                            dontReplaceTagWithSpace = ([tagName isEqualToString:@"a"] ||
                                                       [tagName isEqualToString:@"b"] ||
                                                       [tagName isEqualToString:@"i"] ||
                                                       [tagName isEqualToString:@"q"] ||
                                                       [tagName isEqualToString:@"span"] ||
                                                       [tagName isEqualToString:@"em"] ||
                                                       [tagName isEqualToString:@"strong"] ||
                                                       [tagName isEqualToString:@"cite"] ||
                                                       [tagName isEqualToString:@"abbr"] ||
                                                       [tagName isEqualToString:@"acronym"] ||
                                                       [tagName isEqualToString:@"label"]);
                        }
                        
                        // Replace tag with string unless it was an inline
                        if (!dontReplaceTagWithSpace && result.length > 0 && ![scanner isAtEnd]) [result appendString:@" "];
                        
                    }
                    
                    // Scan past tag
                    [scanner scanUpToString:@">" intoString:NULL];
                    [scanner scanString:@">" intoString:NULL];
                    
                }
                
            } else {
                
                // Stopped at whitespace - replace all whitespace and newlines with a space
                if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
                    if (result.length > 0 && ![scanner isAtEnd]) [result appendString:@" "]; // Dont append space to beginning or end of result
                }
                
            }
            
        } while (![scanner isAtEnd]);
        
        // Cleanup
        
        // Decode HTML entities and return
        ///NSString *retString = [result stringByDecodingHTMLEntities];
        
        // Return
        return result;
        
    }
}

+(void)sendTweet:(NSString *)tweet withImage:(UIImage *)image andURL:(NSString *)urlString fromVC:(UIViewController *)vc{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        controller.view.tintColor = [UIColor orangeColor];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                
                NSLog(@"Cancelled");
                
            } else
                
            {
                NSLog(@"Done");
            }
            
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        controller.completionHandler =myBlock;
        [controller setInitialText:tweet];
        [controller addURL:[NSURL URLWithString:urlString]];
        [controller addImage:image];
        [vc presentViewController:controller animated:YES completion:Nil];
        
    }
    else{
        //[General showOKAlertWithTitle:@"Configure Twitter" andMessage:@"Go to phone settings and set up your account"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

+(void)sendFB:(NSString *)text withImage:(UIImage *)image andURL:(NSString *)urlString fromVC:(UIViewController *)vc{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        controller.view.tintColor = [UIColor orangeColor];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                
                NSLog(@"Cancelled");
                
            } else
                
            {
                NSLog(@"Done");
            }
            
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        controller.completionHandler =myBlock;
        [controller setInitialText:text];
        
        [controller addURL:[NSURL URLWithString:urlString]];
        
        [controller addImage:image];
        
        [vc presentViewController:controller animated:YES completion:Nil];
        
    }
    else{
        //[General showOKAlertWithTitle:@"Configure Facebook" andMessage:@"Go to phone settings and set up your account"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

//Pragma Mark
#pragma mark common actions over tubes

+(void)didExecuteOrderOfReagent:(ComertialReagent *)reagent clone:(Clone *)clone withAmount:(int)amount andPurpose:(NSString *)purpose withBlock:(void(^)())block{
    
    //Add instances
    for (int x = 0; x<amount; x++) {
        
        id instance;
        if (clone) {
            instance = (Lot *)[General newObjectOfType:LOT_DB_CLASS saveContext:NO];
            [(Lot *)instance setClone:clone];
            [(Lot *)instance setLotNumber:@"Pending"];
            [(Lot *)instance setLotDataSheetLink:[(Lot *)reagent.reagentInstances.anyObject lotDataSheetLink]];
            [(Lot *)instance setLotProviderId:[(Lot *)reagent.reagentInstances.anyObject lotProviderId]];
            [General doLinkForProperty:@"clone" inObject:instance withReceiverKey:@"lotCloneId" fromDonor:clone withPK:@"cloCloneId"];
        }else{
            instance = (ReagentInstance *)[General newObjectOfType:REAGENTINSTANCE_DB_CLASS saveContext:NO];
        }
        
        
        if(purpose)[(ReagentInstance *)instance setReiPurpose:purpose];
        
        [General doLinkForProperty:@"comertialReagent" inObject:instance withReceiverKey:@"reiComertialReagentId" fromDonor:reagent withPK:@"comComertialReagentId"];
        [(ReagentInstance *)instance setReiRequestedAt:[NSDate date].description];
        [General doLinkForProperty:@"requester" inObject:instance withReceiverKey:@"reiRequestedBy" fromDonor:[[ADBAccountManager sharedInstance]currentGroupPerson] withPK:@"gpeGroupPersonId"];
        [(ReagentInstance *)instance setReiStatus:@"requested"];
        
        [General saveContextAndRoll];
    }
    if(block)block();
}


+(void)finishedTube:(Tube *)tube withBlock:(void(^)())block{
    if ([tube isMemberOfClass:[ReagentInstance class]]) {
        [(ReagentInstance *)tube setReiStatus:@"finished"];
    }
    tube.tubFinishedAt = [NSDate date].description;
    [General doLinkForProperty:@"finisher" inObject:tube withReceiverKey:@"tubFinishedBy" fromDonor:[[ADBAccountManager sharedInstance]currentGroupPerson] withPK:@"gpeGroupPersonId"];
    [[IPExporter getInstance]updateInfoForObject:tube withBlock:nil];
    if(block)block();
}

+(void)lowlevelsofTube:(Tube *)tube withBlock:(void(^)())block{
    tube.tubIsLow = @"1";
    [[IPExporter getInstance]updateInfoForObject:tube withBlock:nil];
    if(block)block();
}


+(void)reorder:(Tube *)tube withAmount:(int)amount andPurpose:(NSString *)purpose withBlock:(void(^)())block{
    if ([tube isMemberOfClass:[LabeledAntibody class]]) {
        [General didExecuteOrderOfReagent:[(LabeledAntibody *)tube lot].comertialReagent clone:[(LabeledAntibody *)tube lot].clone withAmount:1 andPurpose:purpose withBlock:block];
    }
    if ([tube isMemberOfClass:[Lot class]]) {
        [General didExecuteOrderOfReagent:[(Lot *)tube comertialReagent] clone:[(Lot *)tube clone] withAmount:1 andPurpose:purpose withBlock:block];
    }
    if ([tube isMemberOfClass:[ReagentInstance class]]) {
        [General didExecuteOrderOfReagent:[(ReagentInstance *)tube comertialReagent] clone:nil withAmount:1 andPurpose:purpose withBlock:block];
    }
    if(block)block();
}

+(void)showFile:(File *)file AndPushInNavigationController:(UINavigationController *)navCon{
    ADBMasterViewController *master = [[ADBMasterViewController alloc]init];
    //CustomWebView *custom = [[CustomWebView alloc]initWithFrame:master.view.frame];
    UIWebView *custom = [[UIWebView alloc]initWithFrame:master.view.frame];
    master.view = custom;
    NSString *mimeType = [General determineMimeType:file.filExtension];
    
    if ([file obtainZetData]) {
        [custom loadData:file.zetData MIMEType:mimeType textEncodingName:@"utf-8" baseURL:[NSURL URLWithString:@"http://localhost/"]];
    }else{
        //RCF
        //Try to fetch a noti and reload
    }
    master.preferredContentSize = [[UIScreen mainScreen]bounds].size;
    [navCon pushViewController:master animated:YES];
}

+(NSString *)jsonObjectToString:(id)jsonObject{
    if (!jsonObject) {
        return nil;
    }
    NSError *error;
    NSString *string = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:&error] encoding:NSUTF8StringEncoding];
    if (error)[General logError:error];
    return string;
}

+(id)jsonStringToObject:(NSString *)jsonString{
    NSError *error;
    if (jsonString && ![jsonString isEqualToString:@"0"]) {//TODO handle 0 but then panels stop working
        if (error)[General logError:error];
        NSArray *array = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
        return array;
    }
    return nil;
}

+(BOOL)antibodyWorksForImaging:(Clone *)clone{
    if(clone.cloApplication){
        NSDictionary *dict = [General jsonStringToObject:clone.cloApplication];
        if(![dict respondsToSelector:@selector(count)])return NO;
        if([dict valueForKey:@"1"] || [dict valueForKey:@"3"] || [dict valueForKey:@"4"] )return YES;
    }
    return NO;
}

+(BOOL)antibodyWorksForFlow:(Clone *)clone{
    if(clone.cloApplication){
        NSDictionary *dict = [General jsonStringToObject:clone.cloApplication];
        if(![dict respondsToSelector:@selector(count)])return NO;
        if([dict valueForKey:@"0"] || [dict valueForKey:@"2"])return YES;
    }
    return NO;
}

+(NSString *)showFullAntibodyName:(Clone *)clone withSpecies:(BOOL)showSpecies{
    NSString *result = [NSString stringWithFormat:@"%@%@ (%@)", clone.cloIsPhospho.intValue == 1?@"p-":@"", clone.protein.proName, clone.cloName];
    if(showSpecies)[result stringByAppendingString:[NSString stringWithFormat:@"(%@)", clone.speciesHost.spcName]];
    return result;
}

+(NSString *)showFullLotInfo:(Lot *)lot{
    return [NSString stringWithFormat:@"#%@ %@ - %@|%@|%@", lot.reiReagentInstanceId, [General showFullAntibodyName:lot.clone withSpecies:YES], lot.comertialReagent.provider.proName, lot.comertialReagent.comReference, lot.comertialReagent.comName];
}

+(NSString *)showFullLotSubInfo:(Lot *)lot withSpecies:(NSString *)reactive{
    return [NSString stringWithFormat:@"Lot %@ | %@ | Reactive with: %@", lot.lotNumber, lot.clone.cloBindingRegion, reactive];
}

+(NSArray *)getProtocols{
    return [General searchDataBaseForClass:RECIPE_DB_CLASS sortBy:@"rcpRecipeId" ascending:YES inMOC:[self managedObjectContext]];
}

+(void)constraintIVofTVC:(UITableViewCell *)cell withSize:(CGSize)size{
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, size.width, size.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

+(void)forObject:(Object *)object CreateImage:(UIImage *)image{
    
    NSData *data = UIImageJPEGRepresentation(image, 0.2);
    File *aFile = (File *)[General newObjectOfType:FILE_DB_CLASS saveContext:YES];
    aFile.zetData = data;
    aFile.filExtension = @"jpg";
    aFile.filHash = [NSString stringWithFormat:@"%@_%@", [General randomStringWithLength:2], [General randomStringWithLength:18]];
    
    aFile.catchedInfo = [NSString stringWithFormat:@"%@|%lu", aFile.filHash, (unsigned long)data.length];
    aFile.filSize = [NSString stringWithFormat:@"%lu", (unsigned long)data.length];
    object.objectPictureId = [[aFile.filHash stringByAppendingString:@"."] stringByAppendingString:aFile.filExtension];
    [[IPExporter getInstance]updateInfoForObject:object withBlock:nil];
    
    aFile.zetUploadData = data;
    [General saveContextAndRoll];
}

+(void)populateCell:(UITableViewCell *)cell withStrings:(NSArray *)stringsArray andFormats:(NSArray *)formats margin:(float)margin{
    if(stringsArray.count != formats.count)return;
    
    float accumulated = margin;
    for(NSString *str in stringsArray){
        
    }
    
    NSArray *attribs = @[@{
                                               NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0f],
                                               }];//An example
    
    NSMutableString *pricesMiniPanelString = [NSMutableString string];
    NSString *fullFest = @"Full Festival: ";
    
    [pricesMiniPanelString appendFormat:@"%@\n", fullFest];
    
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:pricesMiniPanelString
                                           attributes:[attribs lastObject]];
    
//    [attributedText setAttributes:[attribs firstObject] range:[pricesMiniPanelString rangeOfString:fullFest]];
//    [attributedText setAttributes:[attribs firstObject] range:[pricesMiniPanelString rangeOfString:dayTicket]];
//    [attributedText setAttributes:[attribs firstObject] range:[pricesMiniPanelString rangeOfString:otherOffers]];
    
//    [_pricesMiniPanel setAttributedText:attributedText];
    
}

@end



