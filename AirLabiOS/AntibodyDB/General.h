//
//  General.h
//  LabPad
//
//  Created by Raul Catena on 8/23/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//


#import <MessageUI/MessageUI.h>
#import <MapKit/MapKit.h>

@class Protocolo;
@class Object;
@class Lot;
@class LabeledAntibody;
@class Tube;
@class File;
@class Clone;
@class ComertialReagent;
@class ADBMasterViewController;


@interface General : NSObject <MFMailComposeViewControllerDelegate, UIPrintInteractionControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

+(NSArray *)searchDataBaseForClass:(NSString *)className withTerm:(NSString *)term inField:(NSString *)field sortBy:(NSString *)sortFactor ascending:(BOOL)ascending inMOC:(NSManagedObjectContext *)moc;

+(NSArray *)searchDataBaseForClass:(NSString *)className withTermContained:(NSString *)term inField:(NSString *)field sortBy:(NSString *)sortFactor ascending:(BOOL)ascending inMOC:(NSManagedObjectContext *)moc;

+(NSArray *)searchDataBaseForClass:(NSString *)className withDictionaryOfTerms:(NSDictionary *)dictOfTerms sortBy:(NSString *)sortFactor ascending:(BOOL)ascending inMOC:(NSManagedObjectContext *)moc;

+(NSArray *)searchDataBaseForClass:(NSString *)className withBOOL:(BOOL)boolValue inField:(NSString *)field sortBy:(NSString *)sortFactor ascending:(BOOL)ascending inMOC:(NSManagedObjectContext *)moc;

+(NSArray *)searchDataBaseForClass:(NSString *)className sortBy:(NSString *)sortFactor ascending:(BOOL)ascending inMOC:(NSManagedObjectContext *)moc;

+(void)incorrectDataInput:(ADBMasterViewController *)delegate;
+(void)noConnection:(ADBMasterViewController *)delegate;

+(NSMutableURLRequest *)callToAPI:(NSString *)urlSuffix withPost:(NSString *)post;
+(NSMutableURLRequest *)callToGetAPIWithSuffix:(NSString *)urlSuffix;
+(NSMutableURLRequest *)callToGetAPI:(NSString *)url;
+(NSMutableURLRequest *)photoUpload:(NSData *)photoData withName:(NSString *)name;
+(NSMutableURLRequest *)fileUpload:(NSData *)photoData withName:(NSString *)name andExtension:(NSString *)ext;
//+(NSData *)photoUDownloadWithName:(NSString *)name;
+(BOOL)isDataZero:(NSData *)data;
+(BOOL)isJSONEmpty:(NSData *)data;
+(NSString *)createDataPostWithDictionary:(NSDictionary *)dictionary;

+(Object *)newObjectOfType:(NSString *)type saveContext:(BOOL)boolsave;

+(NSString *)getDateFromDescription:(NSString *)descriptionOfTime;
+(NSString *)getHourFromDescription:(NSString *)descriptionOfTime;
+(NSDate *)getNSDateFromDescription:(NSString *)descriptionOfTime;

+(NSArray *)validExtensionsForFile;

//+(void)connectAndGetStepsForProtocol:(Protocolo *)protocol inMOC:(NSManagedObjectContext *)context refreshArray:(NSArray *)results;

+(void)logError:(NSError *)error;
+(float)calculateHeightedLabelForLabelWithText:(NSString *)text andWidth:(float)width andFontSize:(float)fontSize;

+(void)showOKAlertWithTitle:(NSString *)title andMessage:(NSString *)message delegate:(ADBMasterViewController *)delegate;

+(void)addBorderToButton:(UIButton *)button withColor:(UIColor *)color;
+(NSString *)secondsToTime:(int)seconds;

//+(BOOL)checkNameLenghtTo:(int)maxLenght forString:(NSString *)test;
+(BOOL)checkEmailIsValid:(NSString *)email;
+(NSString *)returnMessageAftercheckName:(NSString *)name lenghtTo:(int)maxLenght;
+(NSString *)titleForTube:(id)tube;
+(NSString *)titleForSideOfTube:(id)tube;

//Camer
+(void)showCameraWithDelegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate inVC:(UIViewController *)viewController;

//Printing and sharing
+(NSData *)generatePDFData:(UIView *)aView;
+(void)sendToFriend:(UIButton *)sender withData:(NSData *)data withSubject:(NSString *)subject fileName:(NSString *)fileName fromVC:(UIViewController *)controller;
+(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
+(void)generatePDFFromScrollView:(UIView *)scrollView onVC:(UIViewController *)controller;
+(void)printPDF:(NSData *)data andSender:(UIBarButtonItem *)sender withJobName:(NSString *)jobName;
+(void)print:(UIScrollView *)aView fromSender:(UIBarButtonItem *)sender withJobName:(NSString *)jobName;

//Add newObject offline Id
+(void)offlineIdToObject:(Object *)object;
+ (BOOL)isInteger:(NSString *)toCheck;
+(NSString *)stringToSha1:(NSString *)str;
+(NSString *)randomStringWithLength:(int)len;
+(NSString *)utfEncode:(NSString *)str;
+(void)doLinkForProperty:(NSString *)property inObject:(Object *)receiver withReceiverKey:(NSString *)receiverKey fromDonor:(Object *)donor withPK:(NSString *)pkDonor;
+(void)saveContextAndRoll;
+(void)iPhoneBlock:(void(^)())iPhoneBlock iPadBlock:(void(^)())iPadBlock;
+(BOOL)isIphone;
+(BOOL)isANumberCharacter:(NSString *)string;

+(NSArray *)arrayOfValidationNotesForLot:(Lot *)lot andConjugate:(LabeledAntibody *)conjugate;
+(UIColor *)colorForValidationNotesDictionary:(NSDictionary *)dictionary;
+(UIColor *)colorForValidationNotesDictionaryArray:(NSArray *)dictionaryArray;
+(UIColor *)colorForClone:(Clone *)clone forApplication:(int)application;

+(NSString *)determineMimeType:(NSString *)extension;
+(void)logData:(NSData *)data withHeader:(NSString *)header;

+(BOOL)checkPointersAndText:(NSArray *)stuff;
+(NSString *)coordinatesToString:(CLLocationCoordinate2D)coordinates;
+(CLLocationCoordinate2D)stringToCoordinates:(NSString *)string;

+(int)checkText:(NSString *)text orExistForObject:(NSString *)objectType inField:(NSString *)field;//1 is invalid text 2 is valid text and does not exist 3 exists
+(void)startBarSpinner;
+(void)barIndicatorWithPercentage:(float)percentage;
+(void)stopBarSpinner;

+(BOOL)textField:(UITextField *)textField onlyNumbersInRange:(NSRange)range replacementString:(NSString *)string;
+ (NSString *)stringByConvertingHTMLToPlainText:(NSString *)htmlString;
+(void)sendTweet:(NSString *)tweet withImage:(UIImage *)image andURL:(NSString *)urlString fromVC:(UIViewController *)vc;
+(void)sendFB:(NSString *)text withImage:(UIImage *)image andURL:(NSString *)urlString fromVC:(UIViewController *)vc;

//Common actions over tubes
+(void)didExecuteOrderOfReagent:(ComertialReagent *)reagent clone:(Clone *)clone withAmount:(int)amount andPurpose:(NSString *)purpose withBlock:(void(^)())block;
+(void)finishedTube:(Tube *)tube withBlock:(void(^)())block;
+(void)lowlevelsofTube:(Tube *)tube withBlock:(void(^)())block;
+(void)reorder:(Tube *)tube withAmount:(int)amount andPurpose:(NSString *)purpose withBlock:(void(^)())block;

+(void)showFile:(File *)file AndPushInNavigationController:(UINavigationController *)navCon;
+(NSString *)convertAngularDateToNSDateDescription:(NSString *)angDate;

+(NSString *)jsonObjectToString:(id)jsonObject;
+(id)jsonStringToObject:(NSString *)jsonString;

+(BOOL)antibodyWorksForImaging:(Clone *)clone;
+(BOOL)antibodyWorksForFlow:(Clone *)clone;

+(NSArray *)getProtocols;

+(NSString *)showFullAntibodyName:(Clone *)clone withSpecies:(BOOL)showSpecies;
+(NSString *)showFullLotInfo:(Lot *)lot;
+(NSString *)showFullLotSubInfo:(Lot *)lot withSpecies:(NSString *)reactive;

+(void)constraintIVofTVC:(UITableViewCell *)cell withSize:(CGSize)size;
+(void)forObject:(Object *)object CreateImage:(UIImage *)image;
//+(NSData *)getFileDataForHash:(NSString *)hash;

@end
