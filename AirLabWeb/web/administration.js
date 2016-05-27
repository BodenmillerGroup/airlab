angular.module('Admin', ['ngRoute', 'Getters'])
 
.config(function($routeProvider) {
  $routeProvider
    .when('/', {
      controller:'AdminCtrl',
      templateUrl:'web/administration.html'
    })
    .otherwise({
      redirectTo:'/'
    });
})
 
.controller('AdminCtrl', function($scope, $http, $window, AllGetters, AllData) {
	$scope.baseData = AllData;
	getCall($http, 'getPeopleInGroup/'+getCookie('USER_GROUP_ID'), $scope.baseData, 'peopleList');
	
	$scope.save = function(){
		for(var i in AllData.peopleList){
			var person = AllData.peopleList[i];
			if(person.changes == 1){
				createApi('persongroup', angular.copy(AllData.peopleList[i]), $http, null, 'gpeGroupPersonId');
				person.changes = null;		
			}
		}
	}
	
	$scope.colorButton = function(status, index){
		if(parseInt(status) == 0 && index == 0){
			return 'danger';
		}
		if(parseInt(status) == 1 && index == 1){
			return 'success';
		}
		return 'default';
	}
	
	$scope.self = function(){
		return getCookie('USER_USER_GROUP_ID');
	}
	
	$scope.canI = function(){
		if($scope.yesICan)return $scope.yesICan;
		var stay = false;
		for(var i in AllData.peopleList){
			var person = AllData.peopleList[i];
			if(person.gpeGroupPersonId == getCookie('USER_USER_GROUP_ID') && parseInt(person.gpeRole)<2  && parseInt(person.gpeRole)>= 0){
				stay = true;
				break;
			}
		}
		$scope.yesICan = stay;
		if($scope.yesICan == false && AllData.peopleList.length > 0)window.location.href = 'dashboard.php';
		return $scope.yesICan;
	}
	
	$scope.sendInvite = function(invitea, inviteb){
		if(invitea && inviteb && invitea.indexOf('@') < 0 && inviteb.indexOf('@') < 0 && invitea.indexOf(' ') < 0 && inviteb.indexOf(' ') < 0){
			var person = {'email':invitea+'@'+inviteb};
			createApi('invite', person, $http, null, 'perEmail');
			return;
		}
		addWarningOfType('danger', 'Please enter a valid email')
	}
	
	$scope.activeMembers = function(){
		var j = 0;
		for(var i in AllData.peopleList){			
			if(parseInt(AllData.peopleList[i].gpeActiveInGroup) == 1){
				j++;	
			}
		}
		return j;
	}
	$scope.nonActiveMembers = function(){
		var j = 0;
		for(var i in AllData.peopleList){
			if(parseInt(AllData.peopleList[i].gpeActiveInGroup) == 0){
				j++;
			}
		}
		return j;
	}
	
	$scope.sendEmail = function(){
		var recipients = '';
		for(var i in AllData.peopleList){
			if(AllData.peopleList[i].perEmail && AllData.peopleList[i].gpeActiveInGroup == '1')recipients +=AllData.peopleList[i].perEmail+',';
		}
		$('<iframe src="mailto:'+recipients+'">').appendTo('body').css("display", "none");
		//$window.open('mailto:'+recipients);
	}
})