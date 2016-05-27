angular.module('Samples', ['ngRoute', 'Getters'])
 
.config(function($routeProvider) {
  $routeProvider
    .when('/', {
      controller:'SamplesCtrl',
      templateUrl:'web/samples.html'
    })
    .otherwise({
      redirectTo:'/'
    });
})
 
.controller('SamplesCtrl', function($scope, $http, $window, AllData, AllGetters) {
   
    $scope.sort = null;
    $scope.baseData = AllData;
    $scope.allGetters = AllGetters;
    AllData.getAllSamplesForGroup(false);
    	
    $scope.whatParent = [];
    $scope.inMenu = false;	
    	
	$scope.array = function(value){
		return angular.copy(value);
	}
	
	$scope.clicked = function(sample){
	
	}
	
    $scope.belongsToCat = function(sample, cat){
	    if(sample.samType == cat)return true;
	    return false;
	    var type = sample.samType.replace(/\s/g,'');
    }
    
	$scope.addAliquots = function(sample, $event){
		//$event.stopPropagation();
		var c = prompt('How many aliquots?', '1/20');
		var num = parseInt(c);
		if(isNaN(num)){
			alert('Not a valid integer number between 1 and 20');
			return;
		}else{
			if(num < 21 && num>0){
				var d = prompt('Choose a base name for the aliquots. The generated aliquots will contain a unique numeric suffix', sample.samName+'_aliquot_');
				if(d){
					var aSample = angular.copy(sample);
					aSample.samType = null;
					aSample.samParentId = sample.samSampleId;
					aSample.samSampleId = null;
					if(!aSample.samData)aSample.samData = '{}';
					if(!sample.childreOMine)sample.childrenOMine = [];
					for(var i = 0; i<num; i++){
						var theCopy = angular.copy(aSample);
						theCopy.samName = d+(i+1);						
						sample.childrenOMine.push(theCopy);
						createApi('sample', theCopy, $http, AllData.samplesList, 'samSampleId', AllData.samplesReordered);		
					}	
				}else{
					alert('Action canceled');
				}
			}else{
				alert('Not a valid integer number between 1 and 20');
			}	
		}	
	}
	
	$scope.childrenOfSample = function(sample){
		if(!sample.childrenOMine){
			sample.childrenOMine = [];
			for(var i in AllData.samplesList){
				if(AllData.samplesList[i].samParentId == sample.samSampleId){
					sample.childrenOMine.push(AllData.samplesList[i]);	
				}
			}
		}
		return sample.childrenOMine;
	}
	
	function sleepFor( sleepDuration ){
	    var now = new Date().getTime();
	    while(new Date().getTime() < now + sleepDuration){ /* do nothing */ } 
	}
	
	$scope.seeChildren = function(sample, $event){
		if($scope.inMenu == false){
			if($scope.childrenOfSample(sample).length > 0){
				$scope.whatParent.push(sample);
			}
		}else{
			$scope.inMenu = false;
		}
	}
	
	$scope.cancelProp = function($event){
		$scope.inMenu = true;
	}
	
	$scope.showCat = function(cat){
		if($scope.whatParent.length > 0){
			for(var i in $scope.whatParent){
				if($scope.whatParent[i].samType == cat)return true;	
			}
			return false;
		}
		return true;
	}
	
	$scope.showSample = function(sample, key){
		if($scope.whatParent.length == 0){
			if(parseInt(sample.samParentId)<1){
				if(key.replace(/\s/g,'') == sample.samType.replace(/\s/g,'')){
					return true;
				}
			}
		}else{
			if(parseInt(sample.samParentId) == parseInt($scope.whatParent[$scope.whatParent.length - 1].samSampleId)){
				return true;			
			}	
		}
		return false;
	}
	$scope.lastParent = function(){
		return $scope.whatParent[$scope.whatParent.length - 1];
	}
	
	$scope.back = function(){
		$scope.whatParent.splice($scope.whatParent.length - 1, 1);
	}
	$scope.goToParent = function(ind){
		$scope.whatParent.splice(ind, $scope.whatParent.length - ind);
	}
	
	$scope.deleteSample = function(sample){
		var extra = 'Are you sure?';
		if($scope.childrenOfSample(sample).length > 0)extra += ' This samples has children/aliquots associated. If you remove this sample you will lose the children aliquots';
		var c = confirm(extra);
		if(c == true){
			deleteApi('sample', sample, $http, AllData.samplesList, 'samSampleId', AllData.samplesReordered);
		}
	}
	
	$scope.seeSample =function(sample, $event){
		$scope.dataModal = sample;
		if(sample.samData){
			var dict = JSON.parse(sample.samData);
			var arr = [];
			for(var i in dict){
				var miniDict = {};
				miniDict['key'] = i;
				miniDict['value'] = dict[i];
				arr.push(miniDict);
			}
			$scope.dataModal.pairs = arr; 
		}else{
			$scope.dataModal.pairs = [];	
		}
		$event.stopPropagation();
		openModal('addSample');
	}
	$scope.duplicate = function(sample){
		var asample = angular.copy(sample);
		asample.samSampleId = null;
		asample.samName = null;
		$scope.dataModal = asample;
		openModal('addSample');
	}
	$scope.setType =function(type){
		
		var samples = $scope.baseData.samplesReorderedList[type];
		if(!$scope.dataModal.pairs)$scope.dataModal.pairs = {};
		if(samples.length > 0){
			var last = samples[0];
			for(var i in $scope.dataModal.pairs){
				if($scope.dataModal.pairs[i].addon == true){
					$scope.dataModal.pairs.addon == false;
				}	
			}
			for(var i in $scope.dataModal.pairs){
				if($scope.dataModal.pairs[i].addon == false){
					$scope.dataModal.pairs.splice(i, 1);
				}
			}
			var newPairs = JSON.parse(last.samData);
			var arr = [];
			for(var i in newPairs){
				var miniDict = {};
				miniDict['key'] = i;
				miniDict['value'] = newPairs[i];
				arr.push(miniDict);
			}
			
			for(var i in arr){
				arr[i].addon = true;
				$scope.dataModal.pairs.push(arr[i]);
			}
			
			$scope.dataModal.pairs['Created on'] = iOSLikeDate();		
		}
	}
	var ind = 1;
	$scope.addPair = function(){
		if(!$scope.dataModal.pairs){
			$scope.dataModal.pairs = [];
		}
		//var propName = 'New key...'+ind;
		$scope.dataModal.pairs.push({'key':'New key...','value': 'New value...'});
		ind++;
	}
	$scope.removePair =  function(ind){
		$scope.dataModal.pairs.splice(ind, 1);
	}
	$scope.changeDictValue = function(dict, value){	
		dict.value = value;
	}
	$scope.changeDictKey = function(dict, key){
		dict.key = key;
	}

	$scope.nextAddSampleModal = function(){
		var c = confirm('Are you sure?');
		if(c == true){
			if($scope.dataModal.pairs){
				if($scope.dataModal.pairs.length > 0){
					var redoneDict = {};
					console.log($scope.dataModal.pairs);
					for(i in $scope.dataModal.pairs){
						console.log(i);
						redoneDict[$scope.dataModal.pairs[i].key] = $scope.dataModal.pairs[i].value;
					}
					console.log(redoneDict);
					$scope.dataModal.samData = createJSONFromDictionary(redoneDict);
				}
			}else{
				$scope.dataModal.samData = null;	
			}
			createApi('sample', angular.copy($scope.dataModal), $http, AllData.samplesList, 'samSampleId', AllData.samplesReordered);	
		}
	}
})