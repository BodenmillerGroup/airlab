angular.module('Dashboard', ['ngRoute', 'Getters'])
 
.config(function($routeProvider) {
  $routeProvider
    .when('/', {
      controller:'DashboardCtrl',
      templateUrl:'web/dashboard_comments.html'
    })
    .otherwise({
      redirectTo:'/'
    });
})

.filter('reverse', function() {
  return function(items) {
	if(items)
    return items.slice().reverse();
  };
}) 

.controller('DashboardCtrl', function($scope, $http, $window, $sce, AllGetters, AllData) {
   
    $scope.sort = null;
    $scope.baseData = AllData;
    $scope.allGetters = AllGetters;
    AllData.getAllCommentWallsForGroup(false);
    AllData.getAllTasksForPersonGroup(false);
    AllData.getAllTags(false);    
    AllData.getAllLotsForGroup(false);
    AllData.getAllReagentInstancesForGroup(false);
    AllData.getAllComertialReagentsForGroup(false);
    AllData.getAllLabeledAntibodiesForGroup(false);    
	
	$scope.addComment = function(){
		createApi('commentwall', {'cwlComment': $scope.cwlComment, 'createdBy': getCookie('USER_USER_GROUP_ID')}, $http, AllData.commentsList, 'cwlCommentWallId');
	}
	
	$scope.addTask = function(){
		$scope.newTask = [];
		$scope.newTask.tskAssigneeId = getCookie('USER_USER_GROUP_ID');			
	}
	
	$scope.sendTask = function(){
		createApi('task', $scope.newTask, $http, AllData.tasksList, 'tskTaskId');
	}
	
	$scope.colorByPriority = function(ind){
		switch(parseInt(ind)){
			case 0:
				return 'info';
				break;
			case 1:
				return 'success';
				break;				
			case 2:
				return 'warning';
				break;
			case 3:
				return 'danger';
				break;
			default:
				return 'default';
		}
	}
	
	$scope.priorityByIndex = function(ind){
		switch(ind){
			case 0:
				return 'Low';
				break;
			case 1:
				return 'Normal';
				break;				
			case 2:
				return 'Medium';
				break;
			case 3:
				return 'High';
				break;
			default:
				return 'Normal';
		}
	}
	
	$scope.utfToHtml_ = function(str){
		return $sce.trustAsHtml(utfToHtml(str));
	}
	
	$scope.isOwn = function(task){
		if(parseInt(getCookie('USER_USER_GROUP_ID')) == parseInt(task.tskAssigneeId)){
			return true;	
		}
		if(parseInt(getCookie('USER_USER_GROUP_ID')) == parseInt(task.createdBy)){
			return true;	
		}
/*
		if(1 == parseInt(task.tskIsGroup)){
			return true;	
		}
*/		
		return false;
	}
	
	$scope.setFocusTask = function(task){
		$scope.focusTask = task;
	}
	
	$scope.orderKey = function(byPriority){
		if(byPriority == true)return '-tskPriority';
		return '-tskTaskId';
	}
	
	$scope.closeTask = function(task){
		console.log(task);		
		task.tskClosedBy = getCookie('USER_USER_GROUP_ID');
		task.tskClosedAt = iOSLikeDate();		
		createApi('task', task, $http, AllData.tasksList, 'tskTaskId');		
	}
	
	$scope.deleteTask = function(task){
		deleteApi('task', task, $http, AllData.tasksList, 'tskTaskId');
	}
	$scope.deleteComment = function(comment){
		$scope.focusTask = comment;
	}	
	$scope.confirmDeleteComment = function(comment){
		deleteApi('commentwall', comment, $http, AllData.commentsList, 'cwlCommentWallId');		
	}
	
	var theActiveTab = {tab: 0};
	$scope.activeTab = function(tabi){
		theActiveTab.tab = tabi;		
	}
	
	$scope.tabClass = function(ind){
		if(theActiveTab.tab == ind)return 'active';
	}
	
	var theActiveTabRSS = {tab: 0};
	$scope.activeTabRSS = function(tabi){
		theActiveTabRSS.tab = tabi;		
	}
	
	$scope.tabClassRSS = function(ind){
		if(theActiveTabRSS.tab == ind)return 'active';
	}	
	
	$scope.sendEmail = function(){
		var recipients = '';
		for(var i in AllData.peopleList){
			if(AllData.peopleList[i].perEmail && AllData.peopleList[i].gpeActiveInGroup == '1')recipients +=AllData.peopleList[i].perEmail+',';
		}
		$('<iframe src="mailto:'+recipients+'">').appendTo('body').css("display", "none");
		//$window.open('mailto:'+recipients);
	}
	$scope.addressPC = function(){
		$http.get("../get_phd_comic.php")
		.then(function(response) {
			console.log(response.data);
       		 $scope.phdComic = response.data;
    	});
	}
	$scope.addressPC();
})