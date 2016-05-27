//
//  ADBCyTOFPanelGenerator.m
//  AirLab
//
//  Created by Raul Catena on 6/29/15.
//  Copyright (c) 2015 CatApps. All rights reserved.
//

#import "ADBCyTOFPanelGenerator.h"

@implementation ADBCyTOFPanelGenerator

-(NSManagedObjectContext *)managedObjectContext{
    return [(ADBAppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
}

-(void)generateCyTOFString:(int)cytofVersion withPanel:(Panel *)panel andLinkers:(NSArray *)linkers fromVC:(ADBMasterViewController *)controller{
    NSString *allTemplate;
    switch (cytofVersion) {
        case 1:
            allTemplate = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"TemplateCyTOF1" ofType:nil] encoding:NSUTF8StringEncoding error:nil];
            break;
        case 2:
            allTemplate = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"TemplateCyTOF2" ofType:nil] encoding:NSUTF8StringEncoding error:nil];
            break;
            
        default:
            break;
    }
    //NSLog(@"allTemp %@", allTemplate);
    NSArray *parts = [allTemplate componentsSeparatedByString:@"-----+++"];
    if (parts.count == 3) {//Everything is alrighty here
        NSString *isotopes = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"IsotopeMasses" ofType:nil] encoding:NSUTF8StringEncoding error:nil];
        NSArray *allIsotopes = [isotopes componentsSeparatedByString:@"\n"];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:allIsotopes.count];
        for (NSString *isotope in allIsotopes) {
            NSArray *info = [isotope componentsSeparatedByString:@" "];
            [dictionary setValue:info.firstObject forKey:info.lastObject];
        }
        
        NSString *inicio = parts.firstObject;
        inicio = [inicio stringByReplacingOccurrencesOfString:@"{panelName}" withString:panel.panName];
        
        NSMutableArray *channels = [NSMutableArray arrayWithCapacity:linkers.count];
        
        for (NSDictionary *linker in linkers) {
            LabeledAntibody *lab = (LabeledAntibody *)[[General searchDataBaseForClass:LABELEDANTIBODY_DB_CLASS withTerm:[linker valueForKey:@"plaLabeledAntibodyId"] inField:@"labLabeledAntibodyId" sortBy:@"labLabeledAntibodyId" ascending:YES inMOC:self.managedObjectContext]lastObject];
            
            if ([channels containsObject:lab.tag.tagMW]) {
                continue;
            }
            NSString *model = [parts objectAtIndex:1];
            model = [model stringByReplacingOccurrencesOfString:@"{panelName}" withString:panel.panName];
            NSString *search = [dictionary valueForKey:[NSString stringWithFormat:@"%@-%@", lab.tag.tagName, lab.tag.tagMW]];
            NSLog(@"Search %@ for %@-%@", search, lab.tag.tagName, lab.tag.tagMW);
            if (!search) {
                //[General showOKAlertWithTitle:@"Problem generating CyTOF1 acquisitions file" andMessage:nil];
                return;
            }
            [channels addObject:lab.tag.tagMW];
            model = [model stringByReplacingOccurrencesOfString:@"{isotopeMass}" withString:search];
            int lenghtOfWord = lab.lot.clone.protein.proName.length>7? (int)7 : (int)lab.lot.clone.protein.proName.length;
            model = [model stringByReplacingOccurrencesOfString:@"{protName}" withString:
                     [NSString stringWithFormat:@"%@%@_%@",[lab.lot.clone.protein.proName substringToIndex:lenghtOfWord], lab.lot.clone.cloIsPhospho.boolValue?@"_phospho":@"", lab.lot.clone.cloCloneId]
                     ];
            model = [model stringByReplacingOccurrencesOfString:@"{protDescription}" withString:
                     [NSString stringWithFormat:@"%@%@_%@",[lab.lot.clone.protein.proName substringToIndex:lenghtOfWord], lab.lot.clone.cloIsPhospho.boolValue?@"_phospho":@"", lab.lot.clone.cloCloneId]
                     ];
            model = [model stringByReplacingOccurrencesOfString:@"{atom}" withString:lab.tag.tagName];
            model = [model stringByReplacingOccurrencesOfString:@"{atomShortMass}" withString:lab.tag.tagMW];
            //model = [model stringByReplacingOccurrencesOfString:@"{orderNumber}" withString:[NSString stringWithFormat:@"%i",lab.lot.clone.cloCloneId.intValue+8000]];
            model = [model stringByReplacingOccurrencesOfString:@"{orderNumber}" withString:[NSString stringWithFormat:@"%i",lab.labBBTubeNumber.intValue+3000]];//To avoid crash in Cytof computer when using the same clone twice
            inicio = [inicio stringByAppendingString:model];
        }
        
        //////IMPORTANT, to avoid dupes
        NSMutableDictionary *arrayFixed = @{
                                            @"102":@[@"Pd(102)", @"101.905", @"MCB"],
                                            @"104":@[@"Pd(104)", @"103.904", @"MCB"],
                                            @"105":@[@"Pd(105)", @"104.905", @"MCB"],
                                            @"106":@[@"Pd(106)", @"105.903", @"MCB"],
                                            @"108":@[@"Pd(108)", @"107.903", @"MCB"],
                                            @"110":@[@"Pd(110)", @"109.905", @"MCB"],
                                            @"113":@[@"In(113)", @"112.904", @"MCB"],
                                            @"115":@[@"In(115)", @"114.903", @"MCB"],
                                            @"140":@[@"Ce(140)", @"139.905", @"Beads"],
                                            @"151":@[@"Eu(151)", @"150.919", @"Beads"],
                                            @"153":@[@"Eu(153)", @"152.921", @"Beads"],
                                            @"165":@[@"Ho(165)", @"164.93", @"Beads"],
                                            @"175":@[@"Lu(175)", @"174.94", @"Beads"],
                                            @"191":@[@"Ir(191)", @"190.96", @"DNA"],
                                            @"193":@[@"Ir(193)", @"192.962", @"DNA"],
                                            @"194":@[@"Pt(194)", @"193.962", @"Live"],
                                            @"195":@[@"Pt(195)", @"194.964", @"Live"]
                                            }.mutableCopy;
        //Checking what to remove
        for (NSString *str in channels) {
            if ([arrayFixed.allKeys containsObject:str]) {
                [arrayFixed removeObjectForKey:str];
            }
        }
        
        //Adding the auxiliary channels
        for (NSString *key in arrayFixed.allKeys) {
            NSString *model = [parts objectAtIndex:1];
            model = [model stringByReplacingOccurrencesOfString:@"{panelName}" withString:panel.panName];
            
            model = [model stringByReplacingOccurrencesOfString:@"{isotopeMass}" withString:[[arrayFixed valueForKey:key]objectAtIndex:1]];
            
            model = [model stringByReplacingOccurrencesOfString:@"{protName}" withString:
                     [[[arrayFixed valueForKey:key]objectAtIndex:2]stringByAppendingString:key]
                     ];
            model = [model stringByReplacingOccurrencesOfString:@"{protDescription}" withString:
                     [[[arrayFixed valueForKey:key]objectAtIndex:2]stringByAppendingString:key]
                     ];
            model = [model stringByReplacingOccurrencesOfString:@"{atom}" withString:
                     [[[arrayFixed valueForKey:key]objectAtIndex:0]substringToIndex:2]
                     ];
            model = [model stringByReplacingOccurrencesOfString:@"{atomShortMass}" withString:key];
            model = [model stringByReplacingOccurrencesOfString:@"{orderNumber}" withString:[NSString stringWithFormat:@"%lu",[arrayFixed.allKeys indexOfObject:key]+2000]];
            inicio = [inicio stringByAppendingString:model];
        }
       
        
        inicio = [inicio stringByAppendingString:parts.lastObject];
        NSLog(@"Generated %@", inicio);
        NSError *error;
        NSString *fileName = [NSString stringWithFormat:@"%@-CyTOF%i.conf", panel.panName, cytofVersion];
        //NSString *xmlName = [NSString stringWithFormat:@"%@.xml", _panel.panName];
        BOOL succeed = [inicio writeToFile:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]
                                atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if(error)[General logError:error];
        if (succeed) {
            NSData *fileData = [NSData dataWithContentsOfFile:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
            [General sendToFriend:nil withData:fileData withSubject:[NSString stringWithFormat:@"Panel (%@) details for CyTOF%i", panel.panName, cytofVersion] fileName:fileName fromVC:controller];
        }
        
    }else{
        //[General showOKAlertWithTitle:@"Problem generating CyTOF acquisitions file" andMessage:nil];
    }
}

@end
