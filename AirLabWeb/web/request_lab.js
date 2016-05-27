angular.module('RequestLab', ['ngRoute', 'Getters'])
 
.config(function($routeProvider) {
  $routeProvider
    .when('/', {
      controller:'RequestCtrl',
      templateUrl:'web/request_lab.html'
    })
    .otherwise({
      redirectTo:'/'
    });
})

 
.controller('RequestCtrl', function ($window, $http, $scope, AllData, AllGetters) {

	AllData.getAllGroups(false);
	$scope.baseData = AllData;
	$scope.allGetters = AllGetters;	
	
	$scope.requestLab = function(lab){
		
		var group = {'personId':getCookie('USER_USER_ID'),'groupRequested': lab.grpGroupId};
		
		$http({method: 'POST',
    	data: dataPayload(group)+'&'+dataCrud(),
    	headers: {'Content-Type': 'application/x-www-form-urlencoded'},
		url: '/apiLabPad/api/requestJoinGroup'}).success(function(data, status, headers, config) { 	
				if(parseInt(data) == -1){
					addWarningOfType('danger', 'This group does not accept requests, you can contact the laboratory and ask for access granted upon their initiative.');
				}
				if(parseInt(data) == 0){
					addWarningOfType('warning', 'You already requested access to this lab. The approval by the lab\'s administrators is pending.');
				}
				if(parseInt(data) > 0){
					addWarningOfType('success', 'Your request has been successfully added. You need to wait for any administrator at '+lab.grpName+' lab to grant you access');
				}
	      			
          }).error(function(data, status, headers, config) {
			addWarningOfType('danger', 'There was an error processing your request.');	
    	});
		
		}
})