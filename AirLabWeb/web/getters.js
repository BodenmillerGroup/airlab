angular.module('Getters', [])
   
.factory('AllData', function($http, $window) {
		
	var comps = document.URL.split("#/");
	var loaderCount = 0;
	var completed = 1;
	
	function addCompleter(){
		loaderCount++;
		document.getElementById('progress').style.display = 'block';
	}
	
	function refreshPage(){
		completed++;
//		var compll = completed * 5;
		document.getElementById('progress-bar').style.width = parseInt(parseFloat(completed)/parseFloat(loaderCount)*100)+'%';
		if(completed > loaderCount){
			completed = 1;
			loaderCount = 0;
			document.getElementById('progress').style.display = 'none';
		}
	}

    var obj = {};
    
    obj.selfLinker = function(){
	    return getCookie('USER_USER_GROUP_ID');
    }
    obj.selfId = function(){
	    return getCookie('USER_USER_ID');
    }
    obj.selfGroup = function(){
	    return getCookie('USER_GROUP_ID');
    }
    obj.groupName = function(id){
	    var str = decodeURIComponent(getCookie('USER_DATA'));
	    var arr = JSON.parse(str);
	    for(var i in arr){
		    if(arr[i].gpeGroupId == id )return arr[i].grpName.replace(/\+/g, ' ');
	    }
    }        
    
    obj.getAllCalendarsForGroup = function(force){
	    if(!obj.groupCalendarsList || force == true){
			addCompleter();
			postCall($http, dataCrud(), 'getAllCalendarsForGroup', obj, 'groupCalendarsList', recipesReordered);    	
		}
    }
    
    obj.getAllCalendarsForPerson = function(force){
	    if(!obj.myCalendarsList || force == true){
			addCompleter();
			postCall($http, dataCrud(), 'getAllCalendarsForPerson', obj, 'myCalendarsList', recipesReordered);    	
		}
    }
    
    obj.getAllRecipesForGroup = function(force){
	    if(!obj.protocolsList || force == true){
			addCompleter();
			postCall($http, dataCrud(), 'getAllRecipesForGroup', obj, 'protocolsList', recipesReordered);    	
		}
    }
    obj.getAllRecipesPublic = function(force){
	    if(!obj.protocolsPublicList || force == true){
			addCompleter();
			postCall($http, dataCrud(), 'getAllRecipesPublic', obj, 'protocolsPublicList', recipesReordered);    	
		}
    }    
    
    obj.getAllGroups = function(force){
	    if(!obj.groupsList || force == true){
			addCompleter();
			postCall($http, dataCrud(), 'getAllGroups', obj, 'groupsList', recipesReordered);    	
		}
    }
    
    obj.getAllPlacesForGroup = function(force){
	    if(!obj.placesList || force == true){
			addCompleter();
			postCall($http, dataCrud(), 'getAllPlacesForGroup', obj, 'placesList', recipesReordered);    	
		}
    }
    
    var recipesReordered = function(){
	    var mine = [];
	    var others = [];
		for(var index in obj.protocolsList){
			if(parseInt(obj.protocolsList[index].createdBy) == parseInt(getCookie('USER_USER_GROUP_ID'))){
				mine.push(obj.protocolsList[index]);
			}else{
				others.push(obj.protocolsList[index]);
			}
		}
		obj.protocolsMineList = mine;
		obj.protocolsLabList = others;
		refreshPage();
    }
    
    obj.getAllProteinsForGroup = function(force){
		if(!obj.proteinsList || force == true){
			addCompleter();
			postCall($http, dataCrud(), 'getAllProteinsForGroup', obj, 'proteinsList', refreshPage);    	
		}
    }
    
    obj.getAllClonesForGroup = function(force){
	    if(!obj.clonesList || force == true){
			addCompleter();
		 	postCall($http, dataCrud(), 'getAllClonesForGroup', obj, 'clonesList', refreshPage);
	    }
    }
    
    obj.getAllLotsForGroup = function(force){
	    if(!obj.lotsList || force == true){
			addCompleter();		    
		 	postCall($http, dataCrud(), 'getAllLotsForGroup', obj, 'lotsList', refreshPage);       
	    }
    }
    
    obj.getAllReagentInstancesForGroup = function(force){
	    if(!obj.reagentInstancesList || force == true){
			addCompleter();		    
		 	postCall($http, dataCrud(), 'getAllReagentInstancesWithLotsForGroup', obj, 'reagentInstancesList', refreshPage);       
	    }
    }
    
    obj.getAllLabeledAntibodiesForGroup = function(force){
	    if(!obj.conjugatesList || force == true){
			addCompleter();		    
		 	postCall($http, dataCrud(), 'getAllLabeledAntibodiesForGroup', obj, 'conjugatesList', refreshPage);       
	    }
    }
    
    obj.getAllPanelsForGroup = function(force){
	    if(!obj.panelsList || force == true){
			addCompleter();		    
		 	postCall($http, dataCrud(), 'getAllPanelsForGroup', obj, 'panelsList', panelsReordered);   
	    }
    }
    
    var panelsReordered = function(){
	    var mine = [];
	    var others = [];
		for(var index in obj.panelsList){
			if(parseInt(obj.panelsList[index].createdBy) == parseInt(getCookie('USER_USER_GROUP_ID'))){
				mine.push(obj.panelsList[index]);
			}else{
				others.push(obj.panelsList[index]);
			}
		}
		obj.myPanelsList = mine;
		obj.otherPanelsList = others;
		refreshPage();
    }
    
    obj.getAllFilesForPersonGroup = function(force){
	    if(!obj.filesList || force == true){
			addCompleter();
		 	postCall($http, dataCrud(), 'getAllFilesForPersonGroup', obj, 'filesList', refreshPage);   
	    }    
    }
    
    obj.getAllFilesForGroup = function(force){
	    if(!obj.filesGroupList || force == true){
			addCompleter();
		 	postCall($http, dataCrud(), 'getAllFilesForGroup', obj, 'filesGroupList', refreshPage);   
	    } 
    }
    
    obj.getAllTasksForGroup = function(force){
	    if(!obj.tasksGroupList || force == true){
			addCompleter();		    
		 	postCall($http, dataCrud(), 'getAllTasksForGroup', obj, 'tasksGroupList', refreshPage);       
	    }
    }
    
    obj.getAllTasksForPersonGroup = function(force){
	    if(!obj.tasksList || force == true){
			addCompleter();		    
		 	postCall($http, dataCrud(), 'getAllTasksForPersonGroup', obj, 'tasksList', refreshPage);       
	    }
    }
    
    obj.getAllFilePartsForGroup = function(force){
	    if(!obj.filesPartLinkersList || force == true){
			addCompleter();		    
		 	postCall($http, dataCrud(), 'getAllFilePartsForGroup', obj, 'filesPartLinkersList', refreshPage);       
	    }
    }
    
    obj.getAllComertialReagentsForGroup = function(force){
	    if(!obj.comertialReagentsList || force == true){
			addCompleter();		    
		 	postCall($http, dataCrud(), 'getAllComertialReagentsForGroup', obj, 'comertialReagentsList', refreshPage);   
	    }
    }
    postCall($http, dataCrud(), 'getAllFavoritesForPersonGroup', obj, 'favoritesList', refreshPage);
    postCall($http, dataCrud(), 'getAllFavoritesForGroup', obj, 'favoritesGroupList', refreshPage);
    
    obj.getAllCommentWallsForGroup = function(force){
	    if(!obj.commentsList || force == true){
			addCompleter();		    
		 	postCall($http, dataCrud(), 'getAllCommentWallsForGroup', obj, 'commentsList', refreshPage);   
	    }
    }
    
    obj.getAllPartsForExperiment = function(id, force){
	    if(!obj.partsList || force == true){
			addCompleter();		    
		 	postCall($http, dataCrud(), 'getAllPartsForExperiment/'+id, obj, 'partsList', refreshPage);   
	    }
    }
    
    obj.getAllEnsayosForPersonGroup = function(force){
	    if(!obj.ensayosList || force == true){
			addCompleter();		    
		 	postCall($http, dataCrud(), 'getAllEnsayosForPersonGroup', obj, 'ensayosList', refreshPage);   
	    }
    }
    
    obj.getAllEnsayosSharedForPersonGroup = function(force){
	    if(!obj.ensayosSharedList || force == true){
			addCompleter();		    
		 	postCall($http, dataCrud(), 'getAllEnsayosSharedForPersonGroup', obj, 'ensayosSharedList', refreshPage);   
	    }
    }    
    
    obj.getAllPlansForPersonGroup = function(force){
	    if(!obj.plansList || force == true){
			addCompleter();		    
		 	postCall($http, dataCrud(), 'getAllPlansForPersonGroup', obj, 'plansList', refreshPage);   
	    }
    }
    obj.getAllPlansSharedForPersonGroup = function(force){
	    if(!obj.plansSharedList || force == true){
			addCompleter();		    
		 	postCall($http, dataCrud(), 'getAllPlansSharedForPersonGroup', obj, 'plansSharedList', refreshPage);   
	    }
    }    
    
    obj.getAllScientificArticlesForPerson = function(force){
	    if(!obj.papersList || force == true){
			addCompleter();		    
		 	postCall($http, dataCrud(), 'getAllScientificArticlesForPerson', obj, 'papersList', refreshPage);   
	    }
    }
    
    obj.getAllScientificArticlesForGroup = function(force){
	    if(!obj.papersLabList || force == true){
			addCompleter();		    
		 	postCall($http, dataCrud(), 'getAllScientificArticlesForGroup', obj, 'papersLabList', refreshPage);   
	    }
    }
    
    obj.getAllSamplesForGroup = function(force){
	    if(!obj.samplesList || force == true){
			addCompleter();		    
		 	postCall($http, dataCrud(), 'getAllSamplesForGroup', obj, 'samplesList', obj.samplesReordered);   
	    }
    }
    
    obj.samplesReordered = function(){
	    var categories = {};
		for(var index in obj.samplesList){
			if(obj.samplesList[index]){
				if(obj.samplesList[index].samType){
					var type = obj.samplesList[index].samType.replace(/\s/g,'');
					if(categories[type]){
				
					}else{
						if(type.length>0)categories[type] = [];	
						else continue;
					}
					if(categories[type] !== 'undefined')
					categories[type].push(obj.samplesList[index]);		
				}
			}
		}
		obj.samplesReorderedList = categories;
		refreshPage();
    }
    
    obj.getAllTags = function(force){
	    if(!obj.tagsList || force == true){
			addCompleter();		    
		 	getCall($http, 'getAllTags', obj, 'tagsList', refreshPage);   
	    }
    }
    
    obj.getAllSpecies = function(force){
	    if(!obj.speciesList || force == true){
			addCompleter();		    
		 	getCall($http, 'getAllSpecies', obj, 'speciesList', refreshPage);   
	    }    
    }
    
    obj.getAllProviders = function(force){
	    if(!obj.providersList || force == true){
			addCompleter();		    
		 	getCall($http, 'getAllProviders', obj, 'providersList', refreshPage);   
	    }
    }
    getCall($http, 'getPeopleInGroup/'+getCookie('USER_GROUP_ID'), obj, 'peopleList', refreshPage);
    
    return obj;    
})
   
.factory('AllGetters', function(AllData) {

	var allFunctions = {};
	
	allFunctions.test = function(){
		alert('test');
	}
	
	
    allFunctions.protein = function(id, linker){
	    if(linker){
		    if(linker.protein)return linker.protein;
	    }
    	var results = findObjectsInArrayWithIdInField(AllData.proteinsList, id, 'proProteinId');
    	if(linker && results.length > 0){
	    	linker.proName = results[0].proName;	
			linker.protein = results[0];
    	}
    	return results[0];
    }
    
    allFunctions.provider = function(id, linker){
    	var results = findObjectsInArrayWithIdInField(AllData.providersList, id, 'proProviderId');
    	//if(linker && results[0].proName)linker.proName = results[0].proName;
	    return results[0];
    }
    allFunctions.person = function(id, linker){
    	var results = findObjectsInArrayWithIdInField(AllData.peopleList, id, 'perPersonId');
	    return results[0];
    }
    allFunctions.personFromLinker = function(id, linker){
    	var results = findObjectsInArrayWithIdInField(AllData.peopleList, id, 'gpeGroupPersonId');
	    return results[0];
    }
    
    allFunctions.ensayos = function(id, linker){
    	var results = findObjectsInArrayWithIdInField(AllData.ensayosList, id, 'enyPlanId');
	    return results;
    }
    
    allFunctions.ensayosShared = function(id, linker){
    	var results = findObjectsInArrayWithIdInField(AllData.ensayosSharedList, id, 'enyPlanId');
	    return results;
    }    
    
    allFunctions.ensayosShared = function(id, linker){
    	var results = findObjectsInArrayWithIdInField(AllData.ensayosSharedList, id, 'enyPlanId');
	    return results;
    }    
    
    allFunctions.samplesNoParent = function(){
    	var filtered = [];
    	for(var i in AllData.samplesList){
	    	var sample = AllData.samplesList[i];
	    	if(sample.samParentId > 0)continue;
	    	else filtered.push(sample);
    	}
	    return filtered;
    }
    
    allFunctions.samplesWithParent = function(id, linker){
    	var results = findObjectsInArrayWithIdInField(AllData.samplesList, id, 'samParentId');
	    return results;
    }
    
    allFunctions.tag = function(id, linker){
    	var results = findObjectsInArrayWithIdInField(AllData.tagsList, id, 'tagTagId');
    	if(linker && results.length > 0){
	    	linker.tagMW = results[0].tagMW;
	    	linker.tagName = results[0].tagName;	
    	}
	    return results[0];
    }
    
    
    allFunctions.clone = function(id, linker){
	    if(linker){
		    if(linker.clone)return linker.clone;
		}
	    var results = findObjectsInArrayWithIdInField(AllData.clonesList, id, 'cloCloneId');
	    if(linker && results.length > 0){
	    	linker.cloName = results[0].cloName;
	    	if(linker.labLabeledAntibodyId)linker.catchedInfo = results[0].catchedInfo;//This will prevent linkers from panels to get junk that break the panels when saved in panelDetails.html While it keeps the validation data from the labeled antibodies to stick around.
			linker.clone = results[0];
    	}
	    return results[0];
    }
    
    allFunctions.comertialReagent = function(id, linker){	    
	    var results = findObjectsInArrayWithIdInField(AllData.comertialReagentsList, id, 'comComertialReagentId');
	    return results[0];
    }
    
    allFunctions.lot = function(id, linker){
	    if(linker){
		    if(linker.lot)return linker.lot;
		}
	    var results = findObjectsInArrayWithIdInField(AllData.lotsList, id, 'reiReagentInstanceId');
	    if(linker && results.length > 0){
	    	linker.lotNumber = results[0].lotNumber;
			linker.lot = results[0];
    	}
	    return results[0];	    
    }
    allFunctions.lots = function(id, linker){
    	var results = findObjectsInArrayWithIdInField(AllData.lotsList, id, 'lotCloneId');
	    return results;
    }
    allFunctions.reagentInstance = function(id, linker){
	    var results = findObjectsInArrayWithIdInField(AllData.reagentInstancesList, id, 'reiReagentInstanceId');
	    //if(linker && results[0].lotNumber)linker.lotNumber = results[0].lotNumber;
	    return results[0];
    }
    allFunctions.reagentInstances = function(id, linker){
    	var results = findObjectsInArrayWithIdInField(AllData.reagentInstancesList, id, 'reiComertialReagentId');
	    return results;
    }
    allFunctions.lotsByClone = function(id, linker){
	    if(linker){
		    if(linker.lots)return linker.lots;
	    }
    	var results = findObjectsInArrayWithIdInField(AllData.lotsList, id, 'lotCloneId');
    	if(linker)linker.lots = results;
	    return results;
    }
    allFunctions.conjugates = function(id, linker){
	    if(linker){
		    if(linker.conjugates)return linker.conjugates;
	    }
    	var results = findObjectsInArrayWithIdInField(AllData.conjugatesList, id, 'labLotId');
    	if(linker)linker.conjugates = results;    	
	    return results;
    }
    
    allFunctions.conjugate = function(id, linker){
	    var results = findObjectsInArrayWithIdInField(AllData.conjugatesList, id, 'labLabeledAntibodyId');
	    if(results.length > 0 && linker){
		 	//results[0].labBBTubeNumber = parseInt(results[0].labBBTubeNumber);
		 	linker.labBBTubeNumber = parseInt(results[0].labBBTubeNumber);
	    }
	    return results[0];
    }
    
    allFunctions.conjugatesByTag = function(id, linker){
	    var results = findObjectsInArrayWithIdInField(AllData.conjugatesList, id, 'labTagId');
	    return results;
    }
    
    allFunctions.placesChildrenOf = function(parentPlace){
	    var results = findObjectsInArrayWithIdInField(AllData.placesList, parentPlace.plaPlaceId, 'plaParentId');
	    return results;
    }
    allFunctions.tubeAtPlace = function(place){
	    var resultsA = findObjectsInArrayWithIdInField(AllData.samplesList, place.plaPlaceId, 'tubPlaceId');
	    var resultsB = findObjectsInArrayWithIdInField(AllData.reagentInstancesList, place.plaPlaceId, 'tubPlaceId');
	    var resultsC = findObjectsInArrayWithIdInField(AllData.conjugatesList, place.plaPlaceId, 'tubPlaceId');	    
	    return resultsA.concat(resultsB).concat(resultsC);
    }
    allFunctions.placeWithCoordinates = function(x, parent){
	    var results = findObjectsInArrayWithIdInField(AllData.placesList, x, 'plaX');
	    for(var i in results){
		    if(results[i].plaParentId == parent.plaPlaceId)return results[i];
	    }
    }
    
    allFunctions.cloneIsMouse = function(clone){
	    if(clone.isMouse)return clone.isMouse;
		var reactivities = clone.cloReactivity.split(',');
		for(var j in reactivities){
			
			if(parseInt(reactivities[j]) == 2){
				clone.isMouse = true;
				return true;	
			}
		}		
		clone.isMouse = false;
		return false;
    }
    
    allFunctions.cloneIsHuman = function(clone){
	    if(clone.isHuman)return clone.isHuman;
		var reactivities = clone.cloReactivity.split(',');
		for(var j in reactivities){
			
			if(parseInt(reactivities[j]) == 4){
				clone.isHuman = true;
				return true;	
			}
		}		
		clone.isHuman = false;
		return false;
    }
    
    allFunctions.favorites = function(){
		for(var j in AllData.favoritesList){		
			if(AllData.favoritesList[j].favClones){
				if(AllData.favoritesList[j].favClones.length > 0)
				AllData.favoritesList[j].clonesFavorite = AllData.favoritesList[j].favClones.split(',');
			}
			if(AllData.favoritesList[j].favPages){
				if(AllData.favoritesList[j].favPages.length > 0)
				AllData.favoritesList[j].links = JSON.parse(jsonEscape(AllData.favoritesList[j].favPages));
			}
			return AllData.favoritesList[j];
		}
		if(AllData.favoritesList){
			if(AllData.favoritesList.length > 0)return AllData.favoritesList[0];
		}
		var newF = {};
		newF.links = [];
		AllData.favoritesList.push(newF);
		return AllData.favoritesList[0];	
    }
    
    allFunctions.favoritesGroup = function(){
		for(var j in AllData.favoritesGroupList){		
			if(AllData.favoritesGroupList[j].favPages){
				if(AllData.favoritesGroupList[j].favPages.length > 0)
				AllData.favoritesGroupList[j].links = JSON.parse(jsonEscape(AllData.favoritesGroupList[j].favPages));
				return AllData.favoritesGroupList[j];
			}
		}
		if(AllData.favoritesGroupList){
			if(AllData.favoritesGroupList.length > 0)return AllData.favoritesGroupList[0];
		}
		var newF = {};
		newF.links = [];
		AllData.favoritesGroupList.push(newF);
		return AllData.favoritesGroupList[0];
    }
    
    allFunctions.toogleFavoriteClone = function(clone, $http){
		var favorites = allFunctions.favorites();
		if(favorites){
			if(favorites.clonesFavorite){
				var found = [];
				for(var i in favorites.clonesFavorite){
					if(favorites.clonesFavorite[i] == clone.cloCloneId){
						console.log(favorites.clonesFavorite[i]);
						found.push(i);
						break;	
					}
				}
				console.log(found);
				if(found.length > 0){
					for(var i in found)					
					favorites.clonesFavorite.splice(found[i], 1);	
				}else{
					favorites.clonesFavorite.push(clone.cloCloneId);
				}	
			}else{
				favorites.clonesFavorite = [];
			}
			favorites.favClones = favorites.clonesFavorite.join();
			createApi('favorites', favorites, $http, AllData.favoritesList, 'favFavoritesId');
		}else{
			var newfavorites = {};
			newfavorites.favClones = clone.cloCloneId;
			createApi('favorites', newfavorites, $http, AllData.favoritesList, 'favFavoritesId');
		}
    }
    
    allFunctions.isMouse = function(conjugate){
	    if(conjugate.isMouse)return conjugate.isMouse;
        if(conjugate){
    		var lot = allFunctions.lot(conjugate.labLotId, conjugate);
    		if(lot){
	    		var clone = allFunctions.clone(lot.lotCloneId, lot);
	    		if(clone){
		    		var reactivities = clone.cloReactivity.split(',');
					for(var j in reactivities){
						
						if(parseInt(reactivities[j]) == 2){
							conjugate.isMouse = true;
							return true;	
						}
					}		
				}	
			}	
		}
		conjugate.isMouse = false;
		return false;
    }
    
    allFunctions.isHuman = function(conjugate){
	    if(conjugate.isHuman)return conjugate.isHuman;
        if(conjugate){
    		var lot = allFunctions.lot(conjugate.labLotId, conjugate);
    		if(lot){
	    		var clone = allFunctions.clone(lot.lotCloneId, lot);
	    		if(clone){
		    		var reactivities = clone.cloReactivity.split(',');
					for(var j in reactivities){
						if(parseInt(reactivities[j]) == 4){
							conjugate.isHuman = true;
							return true;	
						}
					}		
				}	
			}	
		}
		conjugate.isHuman = false;
		return false;
    }

    return allFunctions;
})

.directive('imageonload', function() {
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
            element.bind('load', function() {
	            var imageId = attrs.id;
	            var theId = imageId.split('image');
				console.log(theId[1]);	            
				document.getElementById('loader'+theId[1]).style.display = "none";
            });
            element.bind('error', function(){
	            var imageId = attrs.id;
	            var theId = imageId.split('image');
				console.log(theId[1]);	            
				document.getElementById('loader'+theId[1]).style.display = "none";
            });
        }
    };
})