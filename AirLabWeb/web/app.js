angular.module('LabPadApp', ['AntibodyGateway.all','AntibodyGateway.proteins' ,'Panels']).//,'ngRoute']).
config(['$httpProvider', function($httpProvider) {
        $httpProvider.defaults.useXDomain = true;
        delete $httpProvider.defaults.headers.common['X-Requested-With'];
    }
])
/*.config(function($routeProvider){
	$routeProvider
    .when('/', {
      controller:'abGatewayController',
      templateUrl:'allLevelsList.html'
    })
    .otherwise({
      redirectTo:'/'
    });
	
})*/