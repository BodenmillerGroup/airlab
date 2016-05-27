var myApp = angular.module('AntibodyGateway.all', []);

myApp.factory('Conjugate', function(){
	return []
});


myApp.controller('abGatewayController', function($scope, $http, Conjugate) {
    $scope.nameFilter = null;
    $scope.conjugatesList = [];
    $scope.theStatus = null;
    $scope.conjugateId = Conjugate;
    
    $http({method: 'GET', url: 'http://www.raulcatena.com/apiLabPad/api/getAntibodyGateway'}).success(function(data, status, headers, config) {
      		$scope.conjugatesList = data;
      		
          }).error(function(data, status, headers, config) {
			  $scope.conjugatesList = 'Error';
			  $scope.theStatus = config;
    });
    
    $scope.orderByProt = function(){
	    $scope.sort = "proName";
    }
    
    $scope.orderByLot = function(){
	    $scope.sort = "lotNumber";
    }
    
    $scope.orderByClone = function(){
	    $scope.sort = "cloName";
    }
    
    $scope.orderByLabel = function(){
	    $scope.sort = "tagMW";
    }
    
    $scope.orderByTubeNumber = function(){
	    $scope.sort = "labBBTubeNumber";
    }
    
    $scope.addConjugate =  function (input){
	    Conjugate = input;
	    alert(Conjugate)
    }
    
});

myApp.filter('iif', function () {
		return function(input) {
        	return input.length()>0 ? true : false;
        };
});



angular.module('Panels', []).
controller('panelsController', function($scope, $http) {
    $scope.nameFilter = null;
    $scope.panelsList = [];
    $scope.theStatus = null;
    
    $http({method: 'GET', url: 'http://www.raulcatena.com/apiLabPad/api/getPanels'}).success(function(data, status, headers, config) {
      		$scope.panelsList = data;
      		
          }).error(function(data, status, headers, config) {
			  $scope.panelsList = 'Error';
			  $scope.theStatus = config;
    });
    
    $scope.clicked = function($anIndex){
	    //alert("The index is " + $anIndex);
    }
});

angular.module('AntibodyGateway.proteins', []).
controller('proteinsController', function($scope, $http) {
    $scope.nameFilter = null;
    $scope.proteinsList = [];
    $scope.theStatus = null;
    var postData = 'dataCrud={"groupId":"2","perPersonId":"7","linkerFlag":"5","token":"eeba50fb27b09cc41093c811a62ff83b23882032"}';
    
    $http.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";
    $http({method: 'POST', data: postData , url: 'http://www.raulcatena.com/apiLabPad/api/getAllProteinsForGroup'}).success(function(data, status, headers, config) {
      		$scope.proteinsList = data;
      		
          }).error(function(data, status, headers, config) {
			  $scope.proteinsList = 'Error';
			  $scope.theStatus = config;
    });
    
});






