angular.module('Inventory', ['ngRoute', 'Getters'])
 
.config(function($routeProvider) {
  $routeProvider
    .when('/inventory', {
      controller:'InventoryCtrl',
      templateUrl:'web/inventory.html'
    })
    .otherwise({
      redirectTo:'/'
    });
})

.filter('statusFilter', function() {
  return function(input, status, reagentInstances) {
  		if(typeof status === 'undefined')return input;
  		if(status === 'all')return input;
  		var filtered = [];
  		for(var j = 0; j<input.length; j++){
				var com = input[j];
				for(var i = 0; i<reagentInstances.length; i++){
					var rei = reagentInstances[i];
					if(rei.reiStatus == status && rei.reiComertialReagentId == com.comComertialReagentId){
						filtered.push(com);
						break;
					}	
				}
		}
		return filtered;
  };
})
 
.controller('InventoryCtrl', function($scope, $http, $window, AllGetters, AllData) {
   
    $scope.sort = null;
    $scope.baseData = AllData;
    $scope.allGetters = AllGetters;
	AllData.getAllReagentInstancesForGroup(false);
	AllData.getAllComertialReagentsForGroup(false);
	AllData.getAllProviders(false);
	AllData.getAllClonesForGroup(false);
	AllData.getAllProteinsForGroup(false);
	//getCall($http, 'getPeopleInGroup/'+getCookie('USER_GROUP_ID'), AllData, 'peopleList');
 
    $scope.page = 0;
    $scope.sizePage = 20;
    $scope.numberOfPages = function(){
	    if(AllData.comertialReagentsList)
	    return parseInt(AllData.comertialReagentsList.length/$scope.sizePage)+1;
    }
    
    $scope.conditionsPaging = function(index, search){
	    if(search){
		    if(index >= $scope.sizePage * 3)return false;
		    if(search.length > 0)return true;
	    }
	    if(index >= $scope.sizePage * $scope.page && index < $scope.sizePage * ($scope.page + 1))return true;
    }
    
    $scope.changePage = function(pagePassed){
	    if(pagePassed < 0) pagePassed = 0;
	    if(pagePassed > $scope.numberOfPages() - 1)pagePassed = $scope.numberOfPages()-1;	    
	    $scope.page = pagePassed;
    }
    
    $scope.catchedInfo = function(adictString){
	    //return [];//TODO something is wrong here
	  	if(adictString){
			return JSON.parse(jsonEscape(adictString));
	  	}
    }
    
    $scope.addReagent = function(reagent){
	    if(!reagent)$scope.dataModal = {};
	    if(reagent)$scope.dataModal = angular.copy(reagent);
	    if(reagent.catchedInfo){
			var dict = JSON.parse(reagent.catchedInfo);
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
    }
	
	var updateReagent = function(reagent){
		var acopy = reagent.catchedInfo;
		console.log(reagent);
		createApi('lot', angular.copy(reagent), $http, null, 'reiReagentInstanceId');
		reagent.catchedInfo = acopy;
	}
	$scope.reorder = function(reagent){
		var instances = AllGetters.reagentInstances(reagent.comComertialReagentId);
		var instance = [];
		if(instances.length == 0)instance.reiComertialReagentId = reagent.comComertialReagentId;
		else instance = instances[0];
		reorderAnInstanceFromAReagent(instance, $http, AllData);
	}
	
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
	
	$scope.nextAddReagentModal = function(){
		var c = confirm('Are you sure?');
		if(c == true){
			if($scope.dataModal.pairs){
				if($scope.dataModal.pairs.length > 0){
					var redoneDict = {};
					for(i in $scope.dataModal.pairs){
						console.log(i);
						redoneDict[$scope.dataModal.pairs[i].key] = $scope.dataModal.pairs[i].value;
					}
					console.log(redoneDict);
					$scope.dataModal.catchedInfo = createJSONFromDictionary(redoneDict);
				}	
			}else{
				$scope.dataModal.catchedInfo = null;
			}
			createApi('comertialreagent', $scope.dataModal, $http, AllData.comertialReagentsList, 'comComertialReagentId');
			closeModal('addReagent');			
		}
	}
	
	$scope.approve = function(instance){
		var txt;
		var r = confirm("Are you sure?");
		if (r == true) {
			instance.reiStatus = 'approved';
			instance.reiApprovedBy = getCookie('USER_USER_GROUP_ID');
			instance.reiApprovedAt = iOSLikeDate();
			updateReagent(instance);
		} else {
		
		}		
	}
	
	$scope.order = function(instance){
		var dict = null;
		if(instance.catchedInfo) dict = JSON.parse(instance.catchedInfo);
		if(!dict)dict = {};
		var r = prompt('What was the price of this item?', dict.price);
		if (r.length > 0) {
			if(instance.reiStatus != 'ordered'){
				instance.reiStatus = 'ordered';
				instance.reiOrderedBy = getCookie('USER_USER_GROUP_ID');
				instance.reiOrderedAt = iOSLikeDate();	
			}
			dict.price = r;
			instance.catchedInfo = createJSONFromDictionary(dict);
			updateReagent(instance);
		} else {
		
		}		
	}
	
	$scope.reprice = function(instance){
		var dict = null;
		if(instance.catchedInfo) dict = JSON.parse(instance.catchedInfo);
		if(!dict)dict = {};
		var r = prompt('What was the price of this item?', dict.price);
		if (r.length > 0) {
			dict.price = r;
			instance.catchedInfo = createJSONFromDictionary(dict);
			updateReagent(instance);
		} else {
		
		}		
	}
	
	$scope.receive = function(instance){
		var r = prompt("Are you sure you have received this item? Please add the lot number", instance.lotNumber);
		if (r.length > 0) {
			instance.reiStatus = 'stock';
			instance.reiReceivedBy = getCookie('USER_USER_GROUP_ID');
			instance.reiReceivedAt = iOSLikeDate();
			instance.lotNumber = r;
			updateReagent(instance);
		} else {
		
		}		
	}	
	
	$scope.addNote = function(instance){
		var dict = null;
		if(instance.catchedInfo) dict = JSON.parse(instance.catchedInfo);
		if(!dict)dict = {};
		var r = prompt('Note', dict.note);
		if (r.length > 0) {
			dict.note = r;
			instance.catchedInfo = createJSONFromDictionary(dict);
			updateReagent(instance);
		}		
	}
	
	$scope.finished = function(instance){
		var r = confirm("Are you sure?");
		if (r == true) {
			instance.tubFinishedBy = getCookie('USER_USER_GROUP_ID');
			instance.tubFinishedAt = iOSLikeDate();
			updateReagent(instance);
		} else {
		
		}		
	}
	
	$scope.undomarkFinished = function(instance){
		var txt;
		var r = confirm("Are you sure?");
		if (r == true) {
			instance.tubFinishedBy = 0;
			instance.tubFinishedAt = '';
			updateReagent(instance);
		} else {
		
		}		
	}
	
	
	$scope.low = function(instance){
		var txt;
		var r = confirm("Are you sure?");
		if (r == true) {
			instance.tubIsLow = 1;
			updateReagent(instance);
		} else {
		
		}		
	}
	
	$scope.undomarkLow = function(instance){
		var txt;
		var r = confirm("Are you sure?");
		if (r == true) {
			instance.tubIsLow = 0;
			updateReagent(instance);
		} else {
		
		}		
	}
	
	$scope.changeStatus = function(instance){
		if(instance.reiStatus == 'rejected'){
			instance.reiStatus = 'requested';
		}
		else if(instance.reiStatus == 'requested'){
			instance.reiStatus = 'approved';
		}
		else if(instance.reiStatus == 'approved'){
			instance.reiStatus = 'ordered';
		}
		else if(instance.reiStatus == 'ordered'){
			instance.reiStatus = 'stock';
		}
		else if(instance.reiStatus == 'stock'){
			instance.reiStatus = 'rejected';
		}
		updateReagent(instance);								
	}	
	
	$scope.isURL = function(value){
		if(value.indexOf('http')>-1)return true;
		if(value.indexOf('www.')>-1)return true;
		return false;
	}
	
	$scope.processValue = function(value){
		if($scope.isURL(value)){
			return '<a href="'+value+'">'+value+'</a>';
		}
		return value;
	}
	
	$scope.colorForStatus = function(instance){
		if(parseInt(instance.tubFinishedBy) > 0){
			return 'default';
		}
		if(parseInt(instance.tubIsLow) > 0){
			return 'danger';
		}
		
		switch(instance.reiStatus){
			case 'stock':
				return 'success';
				break;
			case 'requested':
				return 'info';
				break;
			case 'approved':
				return 'primary';
				break;
			case 'ordered':
				return 'warning';
				break;
			case 'rejected':
				return 'default';
				break;
			default:
				return 'default';																
		}
	}
	
	$scope.statusCalc = function(instance){
		if(parseInt(instance.tubFinishedBy) > 0){
			return 'finished';
		}
		if(parseInt(instance.tubIsLow) > 0){
			return 'low';
		}
		return instance.reiStatus;
	}

	$scope.formatDate = function(iOSTypeDate){
		return getDateFromIOSFormat(iOSTypeDate).substring(0, 10);
	}
	
	$scope.reject = function(instance){
		var txt;
		var r = confirm("Are you sure?");
		if (r == true) {
			instance.reiStatus = 'rejected';
			updateReagent(instance);
		} else {
		
		}
	}
	
	$scope.showNumber = function(instance){
		if(instance.reiStatus === 'stock')return true;
		return false;
	}
	
	$scope.price = function(instance){
		var dict = null;
		if(instance.catchedInfo) dict = JSON.parse(instance.catchedInfo);
		if(dict)return dict.price;		
		return null;
	}
	$scope.note = function(instance){
		var dict = null;
		if(instance.catchedInfo) dict = JSON.parse(instance.catchedInfo);
		if(dict)return dict.note;
		return null;
	}
	
	$scope.deleteInstance = function(instance){
		var txt;
		var r = confirm("Are you sure?");
		if (r == true) {
			deleteApi('reagentinstance', instance, $http, AllData.reagentInstancesList, 'reiReagentInstanceId');
		} else {
		
		}
	}
	
	$scope.showLotNumber = function(instance){
		alert(instance.lotNumber);
	}
	
	$scope.showPurpose = function(instance){
		alert(instance.reiPurpose);
	}
})