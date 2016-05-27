angular.module('Shopper', ['ngRoute', 'Getters'])
 
.config(function($routeProvider, $httpProvider) {
  $routeProvider
    .when('/', {
      controller:'ShopPortalCtrl',
      templateUrl:'web/shop.html'
    })
    .when('/results1', {
      controller:'ShopPortalResults1Ctrl',
      templateUrl:'web/shop_results_1.html'
    })
    .otherwise({
      redirectTo:'/'
    });
    $httpProvider.defaults.headers.get = { 'My-Header' : 'value'};
})
 
.controller('ShopPortalCtrl', function($scope, $http, $window, AllData, AllGetters) {
   
    $scope.baseData = AllData;
    $scope.allGetters = AllGetters;
    AllData.getAllProteinsForGroup(false);
    AllData.getAllSpecies(false);
    AllData.getAllProviders(false);
   
    $scope.search_box = '';
    $scope.dataObtained = '';
            
    $scope.clicked = function (searchTerm) {
		
		var url = 'shop.php?q='+searchTerm;
    	window.location.assign(url);
	};
	
	$scope.isReactive = function(speciesId){
		if(!$scope.dataModal)return;
	    for(var i in $scope.dataModal.reactiveSpecies){
		    if(parseInt(speciesId) === parseInt($scope.dataModal.reactiveSpecies[i]))return true;
	    }
	    return false;
    }
    $scope.toggleSelection = function(speciesId){
	    if(!$scope.dataModal.reactiveSpecies)$scope.dataModal.reactiveSpecies = [];
    	var found = false;
	  	for(var i in $scope.dataModal.reactiveSpecies){
		  	if(parseInt($scope.dataModal.reactiveSpecies[i]) == parseInt(speciesId)){
			  	$scope.dataModal.reactiveSpecies.splice(i, 1);
			  	return;
		  	}
	  	}
	  	$scope.dataModal.reactiveSpecies.push(speciesId);
    }
    
    $scope.checkProt = function(foundProts){
	    if(!foundProts || !$scope.dataModal)return;
	    if(foundProts.length == 0){
		    $scope.dataModal.proteinNew = $scope.proteinSearch;
	    }else if(foundProts.length == 1){
		    $scope.dataModal.cloProteinId = foundProts[0].proProteinId;
		    $scope.dataModal.proteinNew = null;
	    }else if(foundProts.length > 1 && !$scope.proteinSearch){
		    $scope.dataModal.cloProteinId = null;
	    }
    }
	
	var callBack = function(){
		sleep(500);
		console.log('creating RI');					
		var num = parseInt($scope.numberOfItems);
		var instance = {};
				
		if(isNaN($scope.reagent.comComertialReagentId)){
			alert('There was a problem');
			return;
		}
		instance.reiComertialReagentId = $scope.reagent.comComertialReagentId;
		instance.lotNumber = 'Pending';
		instance.reiRequestedBy = getCookie('USER_USER_GROUP_ID');
		instance.reiRequestedAt = iOSLikeDate();
		instance.reiStatus = 'requested';
		
		var table = 'reagentinstance';
		if($scope.dataModal){
			if($scope.dataModal.cloCloneId){
				table = 'lot';
				instance.lotCloneId = $scope.dataModal.cloCloneId;
			}
		}
		
		for(var i = 0; i<num; i++){
			createApi(table, angular.copy(instance), $http, null, 'reiReagentInstanceId');
		}
	}
	
	var orderProcessing = function(){
		sleep(500);
		console.log('creating comR');			
		var data = JSON.parse($window.reagentData);
		$scope.reagent = {};
		var catched = JSON.parse($window.reagentData);

		$scope.reagent.comName = catched['Item'];
		$scope.reagent.comReference = catched['Catalog Number'];
		$scope.reagent.provider = catched['Company'];//Have to process this in server
		$scope.reagent.catchedInfo = jsonEscape($window.reagentData);
		
		createApi('comertialreagent', $scope.reagent, $http, null, 'comComertialReagentId', callBack);

	}
	$scope.orderItem = function(){

		var num = parseInt($scope.numberOfItems);		
		if(num > 0 && num < 11){
			if($window.location.href.indexOf('-Antibodies')>0){
				$scope.dataModal = {};

				var suckedData = JSON.parse(jsonEscape($window.reagentData));
				$scope.dataModal.cloName = suckedData['Clone'];
				$scope.proteinSearch = suckedData['Antigen'];
				$scope.dataModal.cloBindingRegion = suckedData['Immunogen'];
				if(suckedData['Clonality'] !== 'Monoclonal'){
					$scope.dataModal.cloIsPolyclonal = true;
					$scope.dataModal.cloName = "Polyclonal_"+suckedData['Antigen'];	
					
				}
				if(suckedData['Host'] == 'Mouse')$scope.dataModal.cloSpeciesHost = '2';
				if(suckedData['Host'] == 'Rabbit')$scope.dataModal.cloSpeciesHost = '1';
				if(suckedData['Host'] == 'Rat')$scope.dataModal.cloSpeciesHost = '15';
				if(suckedData['Host'] == 'Horse')$scope.dataModal.cloSpeciesHost = '36';
				if(suckedData['Host'] == 'Sheep')$scope.dataModal.cloSpeciesHost = '37';
				if(suckedData['Isotype'])$scope.dataModal.cloIsotype = suckedData['Isotype'];
				
				openModal('addClone');
				$scope.dataModal.reactiveSpecies = [];
				if(suckedData['Reactivity']){
					if(suckedData['Reactivity'].indexOf('Human') > -1)$scope.dataModal.reactiveSpecies.push('4');
					if(suckedData['Reactivity'].indexOf('Hu') > -1)$scope.dataModal.reactiveSpecies.push('4');
					if(suckedData['Reactivity'].indexOf('Hs') > -1)$scope.dataModal.reactiveSpecies.push('4');
					if(suckedData['Reactivity'].indexOf('Mouse') > -1)$scope.dataModal.reactiveSpecies.push('2');
					if(suckedData['Reactivity'].indexOf('Mm') > -1)$scope.dataModal.reactiveSpecies.push('2');
					if(suckedData['Reactivity'].indexOf('Ms') > -1)$scope.dataModal.reactiveSpecies.push('2');					
				}
			}else{
				orderProcessing();//Process right away if it is not a clone			
			}
		}else{
			alert('Please input a number of items between 1 and 10');			
		}
	}
	$scope.nextAddCloneModal = function(){

		$scope.dataModal.cloReactivity = redoArrayToCommaString($scope.dataModal.reactiveSpecies);
		
		var createClone = function(){
			sleep(500);
				console.log('creating clone');			
			aprotein = findObjectsInArrayWithIdInField(AllData.proteinsList, '1', 'flag');
			if(aprotein.length > 0 || $scope.dataModal.cloProteinId){
				if(aprotein.length > 0){
					aprotein[0].flag = null;
					$scope.dataModal.cloProteinId = aprotein[0].proProteinId;	
				}
				createApi('clone', $scope.dataModal, $http, AllData.clonesList, 'cloCloneId', orderProcessing);
				closeModal('addClone');
			}
		}
		
		if($scope.dataModal.cloProteinId && $scope.dataModal.cloName){
			createClone();
		}else{
			if($scope.dataModal.proteinNew && $scope.dataModal.cloName){
				var protein = {"proName": $scope.dataModal.proteinNew, "flag": '1'};
				for(var i in AllData.proteinsList){
					if(AllData.proteinsList[i].proName == $scope.dataModal.proteinNew)protein = AllData.proteinsList[i];
				}
				console.log('creating protein');
				createApi('protein', protein, $http, AllData.proteinsList, 'proProteinId', createClone);
			}else{
				alert('Please add Protein and Clone names');
			}
		}
	}
	
	$scope.inArticle = function(){
		if($window.location.href.indexOf('?art=')>0)return true;
		return false;
	}
})