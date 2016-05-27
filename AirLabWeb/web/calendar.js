angular.module('Calendar', ['ngRoute', 'Getters', 'mwl.calendar', 'ui.bootstrap'])
 
.config(function($routeProvider) {
  $routeProvider
    .when('/', {
      controller:'CalendarsCtrl',
      templateUrl:'web/calendar.html'
    })
    .when('/links', {
      controller:'LinksCtrl',
      templateUrl:'web/links.html'
    })
    .when('/cal', {
      controller:'ActiveCalendar',
      templateUrl:'web/calendar1.html'
    })
    .otherwise({
      redirectTo:'/'
    });
})

.factory('SelectedCalendar', function() {
  return {"calendar" : "-1"};
})
 
.controller('CalendarsCtrl', function($scope, $http, $window, AllGetters, AllData, $sce, SelectedCalendar) {
	$scope.baseData = AllData;
	AllData.getAllCalendarsForGroup(false);
	AllData.getAllCalendarsForPerson(false);	
	$scope.addCalendar = function(bool){
		var pub = bool == true?'1':'0';
		$scope.dataModal = {calPublic: pub}
	}
	$scope.nextAddCalendarModal = function(){
		if($scope.dataModal.calPublic == '0'){
			createApi('calendar', angular.copy($scope.dataModal), $http, AllData.myCalendarsList, 'calCalendarId');		
		}else if($scope.dataModal.calPublic == '1'){
			createApi('calendar', angular.copy($scope.dataModal), $http, AllData.groupCalendarsList, 'calCalendarId');	
		}
	}
	$scope.self = function(){
		return getCookie('USER_USER_GROUP_ID');
	}
})

.controller('ActiveCalendar', function($scope, $http, $window, AllGetters, AllData, $sce, SelectedCalendar){
	var vm = this;
	
    //These variables MUST be set as a minimum for the calendar to work
    vm.calendarView = 'month';
    vm.viewDate = new Date();
    vm.events = [
/*
      {
        title: 'An event',
        type: 'warning',
        startsAt: moment().startOf('week').subtract(2, 'days').add(8, 'hours').toDate(),
        endsAt: moment().startOf('week').add(1, 'week').add(9, 'hours').toDate(),
        draggable: true,
        resizable: true
      }, {
        title: '<i class="glyphicon glyphicon-asterisk"></i> <span class="text-primary">Another event</span>, with a <i>html</i> title',
        type: 'info',
        startsAt: moment().subtract(1, 'day').toDate(),
        endsAt: moment().add(5, 'days').toDate(),
        draggable: true,
        resizable: true
      }, {
        title: 'This is a really long event title that occurs on every year',
        type: 'important',
        startsAt: moment().startOf('day').add(7, 'hours').toDate(),
        endsAt: moment().startOf('day').add(19, 'hours').toDate(),
        recursOn: 'year',
        draggable: true,
        resizable: true,
        editable: true,
        deletable: false
      }
*/
    ];

    //vm.isCellOpen = true;

	$scope.addEvent = function(){
		$scope.event = {};
	}
	
	$scope.nextAddEventModal = function(){
		vm.events.push($scope.event);
		console.log($scope.event);
		closeModal('addEvent');
	}

    vm.eventClicked = function(event) {
//      alert.show('Clicked', event);
    	  alert('Clicked');
    };

    vm.eventEdited = function(event) {
//      alert.show('Edited', event);
	      alert('Edited');
    };

    vm.eventDeleted = function(event) {
//      alert.show('Deleted', event);
	      alert('Deleted');
    };

    vm.eventTimesChanged = function(event) {
//      alert.show('Dropped or resized', event);
	      alert('Dropped');
    };

    vm.toggle = function($event, field, event) {
      $event.preventDefault();
      $event.stopPropagation();
      event[field] = !event[field];
    };
	
})
 
.controller('LinksCtrl', function($scope, $http, $window, AllGetters, AllData, $sce) {
	$scope.baseData = AllData;
	$scope.allGetters = AllGetters;
	
	$scope.pages = function(){
		if($scope.procPages)return $scope.procPages;
		if(AllData.favoritesList){
			if(AllData.favoritesList.length > 0){
				$scope.procPages = JSON.parse(jsonEscape(AllData.favoritesList[0].favPages));
			}
		}
		return $scope.procPages;
	}

	$scope.selected = function(page){
		$scope.selectedPage = $sce.trustAsResourceUrl(page.url);
	}
	$scope.addLink = function(bool){
		AllGetters.favoritesGroup();
		AllGetters.favorites();	
		var pub = bool == true?'1':'0';
		$scope.dataModal = {ispublic: pub, createdBy: $scope.self()}
	}
	$scope.nextAddLinkModal = function(){
		if($scope.dataModal.ispublic == '0'){
			if(!AllGetters.favorites().links)AllGetters.favorites().links = [];
			var links = AllGetters.favorites().links;
			links.push($scope.dataModal);
			AllGetters.favorites().favPages = createJSONFromArrayOfDictionaries(links);
			createApi('favorites', AllGetters.favorites(), $http, AllData.favoritesList, 'favFavoritesId');		
		}else if($scope.dataModal.ispublic == '1'){
			if(!AllGetters.favoritesGroup().links)AllData.favoritesGroup().links = [];
			var links = AllGetters.favoritesGroup().links;
			links.push($scope.dataModal);
			AllGetters.favoritesGroup().favIsGroup = '1';
			AllGetters.favoritesGroup().favPages = createJSONFromArrayOfDictionaries(links);
			console.log(AllGetters.favoritesGroup());
			createApi('favorites', AllGetters.favoritesGroup(), $http, AllData.favoritesGroupList, 'favFavoritesId');	
		}
	}
	$scope.self = function(){
		return getCookie('USER_USER_GROUP_ID');
	}	
});