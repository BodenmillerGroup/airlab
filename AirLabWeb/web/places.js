angular.module('Places', ['ngRoute', 'Getters'])
 
.config(function($routeProvider) {
  $routeProvider
    .when('/', {
      controller:'PlacesMainCtrl',
      templateUrl:'web/places.html'
    })
    .otherwise({
      redirectTo:'/'
    });
})
 
.controller('PlacesMainCtrl', function($scope, $http, $window, AllGetters, AllData) {
	$scope.baseData = AllData;
	$scope.allGetters = AllGetters;	
	AllData.getAllPlacesForGroup(false);
	AllData.getAllReagentInstancesForGroup(false);
	AllData.getAllSamplesForGroup(false);		
	AllData.getAllLabeledAntibodiesForGroup(false);
	AllData.getAllLotsForGroup(false);				
	AllData.getAllClonesForGroup(false);
	AllData.getAllProteinsForGroup(false);		
	
	$scope.initParents = function(place){
		if(!place.parents)place.parents = [];
	}
	$scope.widthColumns = function(place){
		return 100/(parseInt(place.plaColumns)+1);
	}
	$scope.selectRoom = function(place){
		$scope.selectedRoom = place;
	}
	$scope.compIndex = function(rowInd, colInd, width){
		return (colInd * parseInt(width) + rowInd);
	}
	$scope.tubeInfo = function(rowInd, colInd, width, parent){
		var placeRelate = AllGetters.placeWithCoordinates(colInd * parseInt(width) + rowInd, parent);
		var tubes = AllGetters.tubeAtPlace(placeRelate);
		if(tubes.length>0){
			var last = tubes[0];
			if(last.labLabeledAntibodyId){
				var proN = AllGetters.protein(AllGetters.clone(AllGetters.lot(last.labLotId).lotCloneId).cloProteinId).proName;				
				return last.labBBTubeNumber +'\nanti-'+ proN + ' (' +AllGetters.clone(AllGetters.lot(last.labLotId).lotCloneId).cloName + ')';
			}
			if(last.samSampleId)return last.samName;
			if(last.reiReagentInstanceId){
				if(last.lotCloneId){
					var proN = AllGetters.protein(AllGetters.clone(last.lotCloneId)).proName;
					return '\nanti-'+ proN + ' (' +AllGetters.clone(last.lotCloneId).cloName + ')'; 
				}
				return last.reiReagentInstanceId;	
			}
		}
		
	}	
	var arr = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
	$scope.letterForIndex = function(index){
		return arr[index];
	}
});