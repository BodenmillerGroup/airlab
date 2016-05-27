angular.module('CreateLab', ['ngRoute'])
 
.config(function($routeProvider) {
  $routeProvider
    .when('/', {
      controller:'CreateCtrl',
      templateUrl:'web/create_lab.html'
    })
    .otherwise({
      redirectTo:'/'
    });
})

 
.controller('CreateCtrl', function ($window, $http, $scope) {
	
	
	$scope.createLab = function(){
		var group = {'grpName':$scope.labname,'grpInstitution': $scope.institution, 'grpUrl': $scope.urlLab};
		
		$http({method: 'POST',
    	data: dataPayload(group)+'&'+dataCrud(),
    	headers: {'Content-Type': 'application/x-www-form-urlencoded'},
		url: '/apiLabPad/api/group'}).success(function(data, status, headers, config) { 	
			
	      	if(parseInt(data)>0){
		    	var linkerToGroup = {'gpeGroupId':data,'gpePersonId': getCookie('USER_ID'), 'gpeRole': 0};
				document.cookie="USER_GROUP_ID="+parseInt(data);
				var func = function(){
					document.cookie="TOKEN_PUBLIC_KEY=;expires=Thu, 01 Jan 1970 00:00:00 UTC";
					$window.location.href = '/login.php?success=newgroup';
				}
				createApi('zgroupperson', linkerToGroup, $http, null, 'gpeGroupPersonId', func);  	
	      	}		
          }).error(function(data, status, headers, config) {
			addWarningOfType('danger', 'There was an error processing your request.');	
    	});
		
		}
})