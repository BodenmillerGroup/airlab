angular.module('Home', ['ngRoute', 'Getters'])
 
.config(function($routeProvider) {
  $routeProvider
    .when('/', {
      controller:'HomeMainCtrl',
      templateUrl:'web/home.html'
    })
    .otherwise({
      redirectTo:'/'
    });
})
 
.controller('HomeMainCtrl', function($scope, $http, $window, AllGetters, AllData) {
	
});