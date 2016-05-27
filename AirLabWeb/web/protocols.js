angular.module('Protocols', ['ngRoute', 'Getters', 'dndLists'])
 
.config(function($routeProvider) {
  $routeProvider
    .when('/', {
      controller:'ProtocolsCtrl',
      templateUrl:'web/protocols.html'
    })
    .otherwise({
      redirectTo:'/'
    });
})
 
.controller('ProtocolsCtrl', function($scope, $http, $window, AllGetters, AllData, $sce) {
   
    $scope.sort = null;
    $scope.allGetters = AllGetters;
	$scope.baseData = AllData;
	AllData.getAllRecipesForGroup(false);
	AllData.getAllRecipesPublic(false);	
		
	postCall($http, dataCrud(), 'getAllRecipesForGroup', $scope, 'protocolsList');	
	
	$scope.clicked = function(planId){
		
	};
	
	$scope.getSteps = function(protocol){
		if(!protocol.steps){
			var allSteps = JSON.parse(protocol.catchedInfo);
			if(!allSteps)allSteps = [];
			protocol.steps = allSteps;	
		}
		
		return protocol.steps;
	}
		
	$scope.dragModel = {copySteps: {}, selected: null};
		
	$scope.$watch('dragModel', function(model) {
        $scope.modelAsJson = angular.toJson(model, true);
    }, true);
	
	$scope.addProtocol = function(){
		var retVal = prompt("Enter the new protocol's name : ", "Protocol name here");
		var recipe = {};
		recipe.catchedInfo = '[]';
		recipe.rcpTitle = retVal;
		if(retVal) createApi('recipe', recipe, $http, $scope.baseData.protocolsMineList, 'rcpRecipeId');
	}
	
	$scope.publicity = function(publicity, recipe){
		recipe.rcpIsPublic = publicity;
		if(!$scope.baseData.protocolsPublicList)$scope.baseData.protocolsPublicList = [];
		createApi('recipe', recipe, $http, $scope.baseData.protocolsPublicList, 'rcpRecipeId');
	}
	
	$scope.deleteRecipe = function(recipe){
		////Refactor
		var r = confirm("Are you sure?");
		if (r == true) {
			deleteApi('recipe', angular.copy(recipe), $http, $scope.baseData.protocolsMineList, 'rcpRecipeId');
		} else {
		
		}
	}
	
	$scope.duplicateRecipe = function(recipe, own){
		if(own){
			var retVal = prompt("Enter the new protocol's name : ", "Duplicate of "+recipe.rcpTitle);
			var recipeNew = {};
			recipeNew.catchedInfo = recipe.catchedInfo;
			recipeNew.rcpTitle = retVal;
			createApi('recipe', recipeNew, $http, $scope.baseData.protocolsMineList, 'rcpRecipeId');
			return;
		}
		////Refactor
	    var txt;
		var r = confirm("Are you sure?");
		if (r == true) {
			var copy = angular.copy(recipe);
			copy.rcpRecipeId = null;
			copy.createdBy = null;
			copy.groupId = null;
			createApi('recipe', copy, $http, $scope.baseData.protocolsMineList, 'rcpRecipeId');
		} else {
		
		}
	}
	
	$scope.edit = function(protocol){
		protocol.editing = 1;
		$scope.dragModel.copySteps = angular.copy($scope.getSteps(protocol));
	}
	$scope.save = function(recipe){
		$scope.reorderSteps($scope.dragModel.copySteps);
		recipe.steps = angular.copy($scope.dragModel.copySteps);
		$scope.dragModel.copySteps = null;
		recipe.editing = 0;
		recipe.reorder = 0;		
		recipe.catchedInfo = createJSONFromArrayOfDictionaries(recipe.steps);
		createApi('recipe', angular.copy(recipe), $http, $scope.baseData.protocolsMineList, 'rcpRecipeId');		
	}
	$scope.cancel = function(protocol){
		$scope.dragModel.copySteps = null;
		protocol.editing = 0;
	}
	$scope.addStep = function(protocol){
		var newStep = {};
		newStep.stpPosition = $scope.dragModel.copySteps.length + 1;
		newStep.stpTime = '0';
		//newStep.stpText = 'Add here text...';
		$scope.dragModel.copySteps.push(newStep);
	}
	
	$scope.reorderSteps = function (steps){
		for (var i in steps){
			var step = steps[i];
			step.stpPosition = parseInt(i) + 1;
		}
	}
	
	$scope.removeStep = function(protocol, stepIndex){
		$scope.dragModel.copySteps.splice(stepIndex, 1);
		$scope.reorderSteps($scope.dragModel.copySteps);
	}
	
	$scope.utfToHtml_ = function(str){
		return $sce.trustAsHtml(utfToHtml(str));
	}
	
	$scope.help = function(){
		alert('will show help');
	}
})