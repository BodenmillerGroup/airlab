//
//  IPFetchObjects.h
// AirLab
//
//  Created by Raul Catena on 5/31/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^YBlock)();

@interface IPFetchObjects : NSObject

+(IPFetchObjects *)getInstance;
-(void)completedTask;
-(float)valueForProgress;
-(void)reset;
-(void)addProviderssFromServerWithBlock:(YBlock)block;
-(void)addTagsFromServerWithBlock:(YBlock)block;
-(void)addSpeciesFromServerWithBlock:(YBlock)block;
-(void)addPeopleFromLabFromServerWithBlock:(YBlock)block;
-(void)addProteinsFromServerWithBlock:(YBlock)block;
-(void)addClonesFromServerWithBlock:(YBlock)block;
//-(void)addSpeciesProteinFromServerWithBlock:(YBlock)block;
-(void)addLostFromServerWithBlock:(YBlock)block;
-(void)addConjugatesFromServerWithBlock:(YBlock)block;
//-(void)addCloneSpeciesProteinFromServerWithBlock:(YBlock)block;
-(void)addPanelsFromServerWithBlock:(YBlock)block;
//-(void)addPanelLabeledAntibodiesFromServerWithBlock:(YBlock)block;
-(void)addReagentInstancesFromServerWithBlock:(YBlock)block;
-(void)addComertialReagentsFromServerWithBlock:(YBlock)block;
-(void)addScientificArticlesForPersonFromServerWithBlock:(YBlock)block;
-(void)addScientificArticlesForGroupFromServerWithBlock:(YBlock)block;
-(void)addRecetasFromServerWithBlock:(YBlock)block;
//-(void)addStepsFromServerWithBlock:(YBlock)block;
-(void)addSamplesFromServerWithBlock:(YBlock)block;
-(void)addPlansForServerWithBlock:(YBlock)block;
-(void)addEnsayosForServerWithBlock:(YBlock)block;
-(void)addPartsForServerWithBlock:(YBlock)block;
-(void)addFilesForServerWithBlock:(YBlock)block;
-(void)addFilesForGroupServerWithBlock:(YBlock)block;
-(void)addFilePartsForServerWithBlock:(YBlock)block;
-(void)addPlacesForServerWithBlock:(YBlock)block;
-(void)addPlatesForServerWithBlock:(YBlock)block;
-(void)addPlateWellsForServerWithBlock:(YBlock)block;
-(void)addLotEnsayosForServerWithBlock:(YBlock)block;
-(void)addCommentWallsForServerWithBlock:(YBlock)block;

@end
