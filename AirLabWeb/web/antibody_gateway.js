angular.module('Ab_Gateway', ['ngRoute', 'ngDialog'])
 
//.value('fbURL', 'https://angularjs-projects.firebaseio.com/')
 
.factory('SelectedLot', function() {
  return {"selectedLot" : "-1"};
})

.factory('SelectedPanel', function() {
  return {"selectedPanel" : "-1"};
})

.factory('LabPeople', function() {
  return ['AJA', 'CG', 'SC', 'NZ', 'SdP', 'XL', 'FP', 'RC', 'BB', 'JW', 'DS'];
})

.factory('TubeNumber', function() {
  return {"tubeNumber":"0"};
})
 
.config(function($routeProvider) {
  $routeProvider
    .when('/', {
      controller:'ClonesCtrl',
      templateUrl:'web/antibody_gateway.html'
    })
    .otherwise({
      redirectTo:'/'
    });
})

 
.controller('AddCloneCtrl', function ($http, $scope, ngDialog) {

	$scope.proteins = [];
	$scope.speciesList = [];
	$scope.data = [];
	$scope.data.cloReactivity = [];
	$scope.result = '';
	
	$http({method: 'POST',
    	data: dataCrud(),
    	headers: {'Content-Type': 'application/x-www-form-urlencoded'},
		url: '/apiLabPad/api/getAllProteinsForGroup'}).success(function(data, status, headers, config) {
      		$scope.proteins = data;
      		
          }).error(function(data, status, headers, config) {
			  $scope.proteins = 'Error';
    });
    
    $http({method: 'GET',
		url: 'http://www.raulcatena.com/apiLabPad/api/getAllSpecies'}).success(function(data, status, headers, config) {
      		$scope.speciesList = data;
      		
          }).error(function(data, status, headers, config) {
			  $scope.speciesList = 'Error';
    });
    
    $scope.toggleSelection = function(speciesId){
    	var found = false;
	  	for(var i in $scope.data.cloReactivity){
		  	if(parseInt($scope.data.cloReactivity[i]) == parseInt(speciesId)){
			  	$scope.data.cloReactivity.splice(i, 1);
			  	found = true;
		  	}
	  	}
	  	if(!found)$scope.data.cloReactivity.push(speciesId);
    };
    
	$scope.next = function () {
					if($scope.data.proteinNew != null){
						var protein = {"proName": $scope.data.proteinNew};
						$http({method: 'POST',
							data: dataPayload(protein)+'&'+dataCrud(),
							headers: {'Content-Type': 'application/x-www-form-urlencoded'},
							url: '/apiLabPad/api/protein'}).success(function(data, status, headers, config) {
								result = data;
								alert(data+'Success');
								$scope.data.cloProteinId = data;
								createApi('clone', dataPayload($scope.data), $http, $scope.result);
						}).error(function(data, status, headers, config) {
									alert(data);
									result = 'Error';
						});
					}else{
						createApi('clone', dataPayload($scope.data), $http, $scope.result);
					}
									
					ngDialog.close('ngdialog1');
					/*ngDialog.open({
					template: 'secondDialog',
						className: 'ngdialog-theme-flat ngdialog-theme-custom'
				});*/
	};
				
})

.directive('ngLike', function () {
				return {
					restrict: 'E',
					link: function (scope, elem, attrs) {
						elem.on('click', function () {
							window.open(attr.href, 'Share', 'width=600,height=400,resizable=yes');
						});
					}
				};
}) 

.controller('ClonesCtrl', function($scope, SelectedLot, $http, $window, TubeNumber, ngDialog) {
  	$scope.sort = null;
    $scope.clonesList = [];
    $scope.lotsList = [];
    $scope.conjugatesList = [];
    $scope.tagsList = [];
    $scope.theStatus = null;
    $scope.data = SelectedLot;
    $scope.tubeNumber = TubeNumber;
    
    $http({method: 'POST',
    	data: dataCrud(),
    	headers: {'Content-Type': 'application/x-www-form-urlencoded'},
		url: '/apiLabPad/api/getAllClonesForGroup'}).success(function(data, status, headers, config) {
      		$scope.clonesList = data;
      		
          }).error(function(data, status, headers, config) {
			  $scope.clonesList = 'Error';
			  $scope.theStatus = config;
    });
    
    $http({method: 'POST',
    	data: dataCrud(),
    	headers: {'Content-Type': 'application/x-www-form-urlencoded'},
		url: '/apiLabPad/api/getAllLotsForGroup'}).success(function(data, status, headers, config) {
      		$scope.lotsList = data;
      		
          }).error(function(data, status, headers, config) {
			  $scope.lotsList = 'Error';
			  $scope.theStatus = config;
    });
    
    $http({method: 'POST',
    	data: dataCrud(),
    	headers: {'Content-Type': 'application/x-www-form-urlencoded'},
		url: '/apiLabPad/api/getAllLabeledAntibodiesForGroup'}).success(function(data, status, headers, config) {
      		$scope.conjugatesList = data;
      		
          }).error(function(data, status, headers, config) {
			  $scope.conjugatesList = 'Error';
			  $scope.theStatus = config;
    });
    
    $http({method: 'GET',
		url: '/apiLabPad/api/getAllTags'}).success(function(data, status, headers, config) {
      		$scope.tagsList = data;
      		
          }).error(function(data, status, headers, config) {
			  $scope.tagsList = 'Error';
			  $scope.theStatus = config;
    });
    
    $scope.addClone = function(){
    	//http://codepen.io/m-e-conroy/pen/ALsdF
    			
		ngDialog.open({
						template: 'addClone',
						controller: 'AddCloneCtrl',
						className: 'ngdialog-theme-default ngdialog-theme-custom'
					});
				
    }
})
