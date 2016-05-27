angular.module('Account', ['ngRoute', 'Getters'])
 
.config(function($routeProvider) {
  $routeProvider
    .when('/', {
      controller:'AccountCtrl',
      templateUrl:'web/account.html'
    })
    .otherwise({
      redirectTo:'/'
    });
})


.controller('AccountCtrl', function($scope, $http, $window, SelectedExperiment, AllGetters, AllData) {

    $scope.baseData = AllData;
    $scope.allGetters = AllGetters;
	
	$scope.edit = function(){
		
	};
	$scope.resave = function(){
		
	};
})