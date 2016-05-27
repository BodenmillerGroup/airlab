angular.module('AbGateway', ['ngRoute', 'Getters'])
   
.factory('SelectedLot', function() {
  return {"selectedLot" : "-1"};
})

.factory('SelectedPanel', function() {
  return {"selectedPanel" : "-1"};
})

.directive('bubbles', function () {
		
	return {
    	restrict: 'CE',
		scope: {
			data: '=',
			datalength: '=',
			variableradius: '=',
			variablexaxis: '=',
			variableyaxis: '=',
			variablecolor: '=',
			counter: '='
		},
		link: function (scope, element, attrs) {
			
		//	scope.dataLength = function(data){
		//		alert(data.length);
		//		return data.length;
		//	}
			
			scope.$watch('datalength', function (newVal, oldVal) {
				
/*
				console.log(element[0]);
				console.log(attrs);
				console.log(scope);
				console.log(element[0].id);
				console.log(attrs.id);
*/
	            scope.render(scope.data, scope.variableradius, scope.variablexaxis, scope.variableyaxis, scope.variablecolor, element[0].id);
	        });
	        scope.$watch('counter', function (newVal, oldVal) {
	            scope.render(scope.data, scope.variableradius, scope.variablexaxis, scope.variableyaxis, scope.variablecolor, element[0].id);
	        });

			scope.render = function(data, variableRadius, variableXAxis, variableYAxis, variableColor, theId) {
// 				console.log(this.id);
				plotWithDataRadiusXYAndColor(data, variableRadius, variableXAxis, variableYAxis, variableColor, theId);
			}
		}
		// reset grouped state to false
        //scope.grouped = false;
		
		
	}
})

.directive('fileDropzone', function() {
    return {
      restrict: 'A',
      scope: {
        file: '=',
        fileName: '='
      },
      link: function(scope, element, attrs) {
        var checkSize, isTypeValid, processDragOverOrEnter, validMimeTypes;
        processDragOverOrEnter = function(event) {
          if (event != null) {
            event.preventDefault();
          }
          event.dataTransfer.effectAllowed = 'copy';
          return false;
        };
        validMimeTypes = attrs.fileDropzone;
        checkSize = function(size) {
          var _ref;
          if (((_ref = attrs.maxFileSize) === (void 0) || _ref === '') || (size / 1024) / 1024 < attrs.maxFileSize) {
            return true;
          } else {
            alert("File must be smaller than " + attrs.maxFileSize + " MB");
            return false;
          }
        };
        isTypeValid = function(type) {
          if ((validMimeTypes === (void 0) || validMimeTypes === '') || validMimeTypes.indexOf(type) > -1) {
            return true;
          } else {
            alert("Invalid file type.  File must be one of following types " + validMimeTypes);
            return false;
          }
        };
        element.bind('dragover', processDragOverOrEnter);
        element.bind('dragenter', processDragOverOrEnter);
        return element.bind('drop', function(event) {
          var file, name, reader, size, type;
          if (event != null) {
            event.preventDefault();
          }
          reader = new FileReader();
          reader.onload = function(evt) {
            if (checkSize(size) && isTypeValid(type)) {
              return scope.$apply(function() {
                scope.file = evt.target.result;
                if (angular.isString(scope.fileName)) {
                  return scope.fileName = name;
                }
              });
            }
          };
          file = event.dataTransfer.files[0];
          name = file.name;
          type = file.type;
          size = file.size;
          reader.readAsDataURL(file);
          return false;
        });
      }
    };
  })

.config(function($routeProvider) {
  $routeProvider
    .when('/addConjugate', {
      controller:'AddConjugateCtrl',
      templateUrl:'web/addConjugate.html'
    })
    .when('/panels', {
      controller:'PanelCtrl',
      templateUrl:'web/panels.html'
    })
    .when('/panelDetail', {
      controller:'PanelDetailCtrl',
      templateUrl:'web/panelDetails.html'
    })
    .when('/editPanel', {
      controller:'EditPanelCtrl',
      templateUrl:'web/edit_panel.html'
    })
    .when('/refine_panel', {
      controller:'PanelDetailCtrl',
      templateUrl:'web/panel_designer.html'
    })    
    .when('/clones', {
      controller:'ClonesCtrl',
      templateUrl:'web/clones.html'
    })
    .when('/conjugates', {
      controller:'ClonesCtrl',
      templateUrl:'web/conjugates.html'
    })
    .when('/lots', {
      controller:'ClonesCtrl',
      templateUrl:'web/lots.html'
    })
    .when('/stats_ag', {
      controller:'StatsAGCtrl',
      templateUrl:'web/stats_ag.html'
    })
    .otherwise({
      redirectTo:'/'
    });
})

.controller('ClonesCtrl', function($scope, $http, $sce, $window, AllGetters, AllData) {

	$scope.allGetters = AllGetters;
	$scope.baseData = AllData;
	AllData.getAllLabeledAntibodiesForGroup(false);
	AllData.getAllClonesForGroup(false);
	AllData.getAllLotsForGroup(false);
	AllData.getAllProviders(false);	//
	AllData.getAllComertialReagentsForGroup(false);	//
	AllData.getAllTags(false);

    //Pagination Naviation
    
    $scope.oneAtATime = true;
 
    $scope.page = 0;
    $scope.sizePage = 20;
    $scope.numberOfPages = function(){
	    if(AllData.clonesList)
	    return parseInt(AllData.clonesList.length/$scope.sizePage)+1;
    }
    
    $scope.conditionsPaging = function(index, search){
	    if(search){
		    if(index >= $scope.sizePage * 3)return false;
		    if(search.length > 0)return true;
	    }
	    if(index >= $scope.sizePage * $scope.page && index < $scope.sizePage * ($scope.page + 1))return true;
    }
    
    $scope.changePage = function(pagePassed){
	    if(pagePassed < 0) pagePassed = 0;
	    if(pagePassed > $scope.numberOfPages() - 1)pagePassed = $scope.numberOfPages()-1;	    
	    $scope.page = pagePassed;
    }
    
    //Public/Private
    
    $scope.makePrivate = function(clone){
	    clone.cloPublic = 0;
	    createApi('clone', clone, $http, AllData.clonesList, 'cloCloneId');
    }
    $scope.makePublic = function(clone){
	    clone.cloPublic = 1;	    
	    createApi('clone', clone, $http, AllData.clonesList, 'cloCloneId');
    }
    
    
	//Edit objects in general    
	
	$scope.edit = function(anObj){
		$scope.editedObject = angular.copy(anObj);
	}
	
	$scope.confirmChange = function(){
		console.log($scope.editedObject);
		if($scope.editedObject.reiReagentInstanceId){
			createApi('reagentinstance', $scope.editedObject, $http, AllData.lotsList, 'reiReagentInstanceId');
		}
		if($scope.editedObject.cloCloneId){
			createApi('clone', $scope.editedObject, $http, AllData.clonesList, 'cloCloneId');
		}				
	}
	
	
	//Clone
    $scope.addClone = function(){
	    AllData.getAllSpecies();
		AllData.getAllProteinsForGroup(false);	     
    	$scope.dataModal = {};
		$scope.dataModal.reactiveSpecies = [];		
    }
    $scope.editClone = function(clone){
	    AllData.getAllSpecies();
		AllData.getAllProteinsForGroup(false);	    
    	$scope.dataModal = angular.copy(clone);
    	$scope.dataModal.edit = true;
    	$scope.dataModal.reactiveSpecies = clone.cloReactivity.split(',');
    }
    $scope.deleteClone = function(clone){
	    var r = confirm('Are you sure?');
	    if(r == true){
		    deleteApi('clone', angular.copy(clone), $http, AllData.clonesList, 'cloCloneId');
	    }
    }
    $scope.isReactive = function(speciesId){
	    if(!$scope.dataModal)return;
	    for(var i in $scope.dataModal.reactiveSpecies){
		    if(parseInt(speciesId) === parseInt($scope.dataModal.reactiveSpecies[i]))return true;
	    }
	    return false;
    }
    $scope.toggleSelection = function(speciesId){
	    if(!$scope.dataModal.reactiveSpecies)$scope.dataModal.reactiveSpecies = [];
    	var found = false;
	  	for(var i in $scope.dataModal.reactiveSpecies){
		  	if(parseInt($scope.dataModal.reactiveSpecies[i]) == parseInt(speciesId)){
			  	$scope.dataModal.reactiveSpecies.splice(i, 1);
			  	return;
		  	}
	  	}
	  	$scope.dataModal.reactiveSpecies.push(speciesId);
    }
    
	$scope.nextAddCloneModal = function () {

		$scope.dataModal.cloReactivity = redoArrayToCommaString($scope.dataModal.reactiveSpecies);
		
		var createClone = function(){
			aprotein = findObjectsInArrayWithIdInField(AllData.proteinsList, '1', 'flag');
			if(aprotein.length > 0 || $scope.dataModal.cloProteinId){
				if(aprotein.length > 0){
					aprotein[0].flag = null;
					$scope.dataModal.cloProteinId = aprotein[0].proProteinId;	
				}
				createApi('clone', angular.copy($scope.dataModal), $http, AllData.clonesList, 'cloCloneId');
				closeModal('addClone');
			}
		}
		
		if($scope.dataModal.cloProteinId && $scope.dataModal.cloName){
			createClone();
		}else{
			if($scope.dataModal.proteinNew && $scope.dataModal.cloName){
				var protein = {"proName": $scope.dataModal.proteinNew, "flag": '1'};
				for(var i in AllData.proteinsList){
					if(AllData.proteinsList[i].proName === $scope.dataModal.proteinNew)protein = AllData.proteinsList[i];
				}
				createApi('protein', protein, $http, AllData.proteinsList, 'proProteinId', createClone);
			}else{
				alert('Please add Protein and Clone names');
			}
		}
	}
    
    //Lot
    $scope.providerForLot = function(lot){
	    if(lot.provider)return lot.provider;
	    var comR = AllGetters.comertialReagent(lot.reiComertialReagentId);
	    if(comR){
			var prov = AllGetters.provider(comR.comProviderId);
			if(prov){
				lot.provider = prov.proName;
			}
	    }
	    return lot.provider?lot.provider:'unknown provider';
    }
    
    $scope.addLot = function(clone){
	    AllData.getAllProviders();
		AllData.getAllComertialReagentsForGroup(false);	    
    	$scope.dataModal = {};    	
    	$scope.dataModal.lotCloneId = clone.cloCloneId;
    	$scope.dataModal.lotNumber = 'Pending';
    	$scope.dataModal.reiRequestedBy = getCookie('USER_USER_GROUP_ID');
		$scope.dataModal.reiRequestedAt = iOSLikeDate();
		$scope.dataModal.reiStatus = 'requested';
    	$scope.dataModal.comertialReagent = {};		
    	$scope.dataModal.comertialReagent.comName = 'Anti-'+AllGetters.protein(clone.cloProteinId).proName+' ('+clone.cloName+')';
    }
    $scope.editLot = function(lot){
	    AllData.getAllProviders();
		AllData.getAllComertialReagentsForGroup(false);	    
    	$scope.dataModal = angular.copy(lot);
    	if(parseInt($scope.dataModal.lotHasCarrier) != 0 && $scope.dataModal.lotHasCarrier != '')$scope.dataModal.passCarrier = true;
    	$scope.dataModal.edit = true;
    	if(!lot.reiComertialReagentId){
	    	$scope.dataModal.comertialReagent = {};		
			$scope.dataModal.comertialReagent.comName = 'Anti-'+AllGetters.protein(clone.cloProteinId).proName+' ('+clone.cloName+')';
    	}else{
	    	$scope.dataModal.comertialReagent = AllGetters.comertialReagent(lot.reiComertialReagentId);
    	}
    }
    
	$scope.reorderLot = function (lot) {
		reorderAnInstanceFromAReagent(lot, $http, AllData);
	}
	
	//Toss out?
	if($scope.dataprev){
		var previousLots = AllGetters.lots($scope.dataprev.previousId);
		for(var i in previousLots){
			var prevLot = previousLots[i];
			$scope.comertialReagent = AllGetters.comertialReagent(prevLot.reiComertialReagentId);
			$scope.data = {}
			$scope.data.lotNumber = 'Pending';
			$scope.data.lotCloneId = prevLot.lotCloneId;
			$scope.data.reiComertialReagentId = prevLot.reiComertialReagentId;			
			break;
		}			
	}
	
	$scope.nextAddLotModal = function () {					
		var createLot = function(){
			if($scope.dataModal.comertialReagent){
				if($scope.dataModal.comertialReagent.comComertialReagentId){
					$scope.dataModal.reiComertialReagentId = $scope.dataModal.comertialReagent.comComertialReagentId;	
				}	
			}
			if($scope.dataModal.passCarrier == false)$scope.dataModal.lotHasCarrier = '0';
			createApi('lot', angular.copy($scope.dataModal), $http, AllData.lotsList, 'reiReagentInstanceId');
		}
		
		if($scope.dataModal.reiComertialReagentId){
			createLot();
		}else{
			if($scope.dataModal.comertialReagent){
				if($scope.dataModal.comertialReagent.comProviderId){
					createApi('comertialreagent', $scope.dataModal.comertialReagent, $http, AllData.comertialReagentsList, 'comComertialReagentId', createLot);
				}else{
					alert('Please Select a Provider');
				}
			}else{
				createApi('comertialreagent', $scope.dataModal.comertialReagent, $http, AllData.comertialReagentsList, 'comComertialReagentId', createLot);
			}
			
		}
	};
	
	$scope.lazyLot = function(lot){
		if(!lot.proName || !lot.cloName || !lot.phospho){
			var clone = AllGetters.clone(lot.lotCloneId, lot);
			if(clone)lot.proName = clone.proName;
			if(clone)lot.cloName = clone.cloName;
			if(clone)lot.phospho = clone.cloIsPhospho == '1'?'p-':'';
		}
	}
    
	
	//Conjugate 
	
	$scope.lazyConjugate = function(conj){
		if(!conj.proName || !conj.cloName || !conj.phospho){
			var lot = AllGetters.lot(conj.labLotId);
			if(lot)var clone = AllGetters.clone(lot.lotCloneId);
			if(clone)conj.proName = clone.proName;
			if(clone)conj.cloName = clone.cloName;
			if(clone)conj.phospho = clone.cloIsPhospho == '1'?'p-':'';
		}
		if(!conj.tagMW || !conj.tagName){
			var tag = AllGetters.tag(conj.labTagId);
			if(tag)conj.tag = tag.tagMW+tag.tagName;
		}
		if(!conj.person){
			var person = AllGetters.person(conj.labContributorId);
			if(person)conj.person = person.perName;
		}	
	}
	 
    $scope.addConjugate = function (lot) {
		AllData.getAllLabeledAntibodiesForGroup(true);    
		$scope.dataModal = {};
		$scope.dataModal.labLotId = lot.reiReagentInstanceId;
		$scope.dataModal.labDateOfLabeling = iOSLikeDate();
		$scope.dataModal.labContributorId = AllData.selfLinker();
	}
    $scope.editConjugate = function(conjugate){
    	$scope.dataModal = angular.copy(conjugate);
    	$scope.dataModal.edit = true;
    }
	$scope.nextAddConjugateModal =  function (){
		var lastTube = 0;
		var theConj = 0;
		for (conjugate in $scope.baseData.conjugatesList) {
    		theConj = $scope.baseData.conjugatesList[conjugate];
			if(parseInt(theConj.labBBTubeNumber) > lastTube){
	   			lastTube = theConj.labBBTubeNumber;
			}
		}
		if($scope.dataModal.labLabeledAntibodyId == null){
			//TODO lab number from API
			var num = parseInt(lastTube)+1;
			$scope.dataModal.labBBTubeNumber = num.toString();
		}
		if(checkRequired($scope.dataModal, ['labContributorId', 'labLotId', 'labTagId', 'labConcentration', 'labBBTubeNumber'])){
			var message = 'Please label the tube on the top with '+JSON.stringify(parseInt(lastTube)+1);
			if($scope.dataModal.labLabeledAntibodyId == null)alert(message);
			if(!$scope.dataModal.labDateOfLabeling)$scope.dataModal.labDateOfLabeling = iOSLikeDate();
			createApi('labeledantibody', angular.copy($scope.dataModal), $http, AllData.conjugatesList, 'labLabeledAntibodyId');
		}
    };    
    
    //Validation notes
    $scope.addValidationNote = function(object){
		AllData.getAllFilesForGroup(false);//Only with validations
		AllData.getAllFilesForPersonGroup(true);//Only with validations
		$scope.dataModal = {};
    	$scope.dataModal.clone = object;		
		$scope.dataModal.validation = {};
    	$scope.dataModal.validation.isVal = 1;		
		if(object.catchedInfo){
			$scope.dataModal.validations = JSON.parse(jsonEscape(object.catchedInfo));
		}else{
			$scope.dataModal.validations = [];    
		}
		$scope.uploadComplete = false;
    }
    $scope.applications = ['sMC', 'iMC', 'Flow Cytometry', 'IF', 'IHC'];
    
    $scope.applicationForVal = function(val){
	    if(val.app)
	    return $scope.applications[val.app];
	    return '';
    }
    $scope.showValidations = function(object){
		AllData.getAllFilesForGroup(false);//Only with validations
		AllData.getAllFilesForPersonGroup(true);//Only with validations	    
    	if(object.catchedInfo){
	    	$scope.dataModal = {};
			$scope.dataModal.clone = object;		
			$scope.dataModal.validations = JSON.parse(jsonEscape(object.catchedInfo));
		}
    }
	$scope.editValidation = function(validation, index){
		closeModal('seeValidations');
		$scope.dataModal.validation = validation;
		$scope.dataModal.validation.edit = true;
		openModal('addValidation');		
	}    
    $scope.applications = ['sMC', 'iMC', 'Flow Cytometry', 'IF', 'IHC'];
	$scope.knowledge = ['YES', 'NO', 'Not tested'];
	$scope.works = ['YES', 'So so', 'NO'];
	$scope.whatApp = function(valueToTest){return $scope.applications[valueToTest];}
	$scope.whatKnowledge = function(valueToTest){return $scope.knowledge[valueToTest];}
	$scope.whatWorks = function(valueToTest){return $scope.works[valueToTest];}
	$scope.worksColor = function(valueToTest){
		
		switch(parseInt(valueToTest)) {
			case 0:
			    return 'success';
			    break;
			case 1:
			    return 'warning';
			    break;
			case 2:
			    return 'danger';
			    break;
			default:
			    return 'default';
		}
	}
	$scope.erase = function(validationIndex){
		var r = confirm("Are you sure?");
		if (r == true) {
			$scope.dataModal.validations.splice(validationIndex, 1);
			$scope.dataModal.clone.catchedInfo = createJSONFromArrayOfDictionaries($scope.dataModal.validations);
			createApi('clone', angular.copy($scope.dataModal.clone), $http, null, 'cloCloneId');
		}
	}  
    $scope.numberOfValidations = function(object){
    	if(object.catchedInfo){
	    	var theInt = JSON.parse(jsonEscape(object.catchedInfo)).length;
	    	if(theInt>0)return theInt;	
    	}
    }
    $scope.validationsForLotInClone = function(lot, clone){

	    if(lot.validations)return lot.validations;
	    var all = JSON.parse(jsonEscape(clone.catchedInfo));
	    var filtered = [];
	    for(var i in all){
		    if(all[i].lot){
				if(parseInt(all[i].lot) == parseInt(lot.reiReagentInstanceId)){
			    	filtered.push(all[i]);
		    	}   
		    }
	    }
	    lot.validations = filtered;
	    return lot.validations;
    }
    $scope.validationsForConjugateInClone = function(conjugate, clone){
	    if(conjugate.validations)return conjugate.validations;
	    var all = JSON.parse(jsonEscape(clone.catchedInfo));
	    var filtered = [];
	    for(var i in all){
		    if(all[i].conjugate){
				if(parseInt(all[i].conjugate) == parseInt(conjugate.labLabeledAntibodyId)){
			 	   filtered.push(all[i]);
		    	}   
		    }
	    }
	    conjugate.validations = filtered;
	    return conjugate.validations;	    
    }
    $scope.colorForValidation = function(val){
	    switch(parseInt(val.val)){
		    case 0:
		    	return 'success';
		    	break;
		    case 1:
		    	return 'warning';
		    	break;
		    case 2:
		    	return 'danger';
		    	break;			    
	    }
	    return 'default';	    
    }
    $scope.glyphForValidation =function(val){
	    switch(parseInt(val.val)){
		    case 0:
		    	return 'thumbs-up';
		    	break;
		    case 1:
		    	return 'hand-right';
		    	break;
		    case 2:
		    	return 'thumbs-down';
		    	break;			    
	    }
    }  
/*
    $scope.removeValidations = function(clone){
    	clone.catchedInfo = '';
	    createApi('clone', angular.copy(clone), $http, null, 'cloCloneId');
    }
*/    
	
	$scope.nextAddValidationModal =  function (index){
		if(checkRequired($scope.dataModal.validation, ['app', 'sample', 'negSample', 'val', 'file'])){
			$scope.dataModal.validation.personId = getCookie('USER_ID');
			$scope.dataModal.validation.date = iOSLikeDate();
			if($scope.dataModal.validation.edit == true){
				$scope.dataModal.validation.edit = null;
				$scope.dataModal.validations.splice(index, 1, $scope.dataModal.validation);				
			}else{
				$scope.dataModal.validations.push($scope.dataModal.validation);				
			}
			$scope.dataModal.clone.catchedInfo = createJSONFromArrayOfDictionaries($scope.dataModal.validations);
			createApi('clone', angular.copy($scope.dataModal.clone), $http, null, 'cloCloneId');
			closeModal('addValidation');
		}
    }
	
	$scope.files = [];//These are the files selected
	
	$scope.cancelFile = function(element) {
		element.files = null;
	}

    $scope.uploadFile = function() {
    
    	var aFile = {};
    	aFile.filExtension = getExtensionFromFilename($scope.files[0].name);
		aFile.filHash = makeHash(2)+'_'+makeHash(20);
		aFile.catchedInfo = $scope.files[0].name+'|'+$scope.files[0].size;
    
        var fd = new FormData();//For now will support only one file
        //for (var i in $scope.files) {
            //fd.append("userfile"+i, $scope.files[i]);
            //console.log($scope.files[i]);
        //}
        fd.append("userfile", $scope.files[0], aFile.filHash+'.'+aFile.filExtension);
        var client = new XMLHttpRequest();
        client.upload.addEventListener("progress", uploadProgress, false);
        client.addEventListener("load", uploadComplete, false);
        client.addEventListener("error", uploadFailed, false);
        client.addEventListener("abort", uploadCanceled, false);
        $scope.progressVisible = true;

		client.open("POST", "/apiLabPad/api/uploadFileGAE", true);
		//client.setRequestHeader("Content-Type", "multipart/form-data");//This gives trouble in the PHP server
		client.send(fd);  /* Send to server */ 
     
	   client.onreadystatechange = function() 
	   {
		  console.log(client.responseText);
	      if (client.readyState == 4 && client.status == 200) 
	      {
	         //alert(client.statusText + '__returned '+client.responseText);
	         createApi('file', aFile, $http, $scope.baseData.filesList, 'filFileId', selectFile);
	      }else if(client.status != 200){
		      genericError();
	      }
	   }
    }
    
    var selectFile = function(){
	    var file = AllData.filesList[filFileId.filesList.length - 1];
	    //alert(file.filFileId + '????');
	    $scope.dataModal.file = file.filFileId;
    }
    
    $scope.setFiles = function(element) {
    	if(element.files.length > 1){
	    	alert('Select only one file');
	    	element.files = [];
	    	$scope.files = [];
	    	return;
    	}
    	$scope.$apply(function($scope) {
			console.log('files:', element.files);
			$scope.files = [];
			if(element.files.length == 1){
				for (var i = 0; i < element.files.length; i++) {
					$scope.files.push(element.files[i]);
				}
				$scope.progressVisible = false	
			}
		});
    }
    
    function uploadProgress(evt) {
        $scope.$apply(function($scope){
            if (evt.lengthComputable) {
                $scope.progress = Math.round(evt.loaded * 100 / evt.total)
            } else {
                $scope.progress = 'unable to compute'
            }
        })
    }
    
    function uploadComplete(evt) {
        /* This event is raised when the server send back a response */
        $scope.progressVisible = false;
        $scope.uploadComplete = false;
        //alert(evt.target.responseText)
    }

    function uploadFailed(evt) {
        alert("There was an error attempting to upload the file.")
    }

    function uploadCanceled(evt) {
        scope.$apply(function(){
            $scope.progressVisible = false
        })
        alert("The upload has been canceled by the user or the browser dropped the connection.")
    }    
    
	//Fast actions    
    $scope.markLow = function(object){
    	$scope.dataModal = angular.copy(object);
    	$scope.dataModal.tubIsLow = '1';
    }
    
    $scope.undomarkLow = function(object){
    	$scope.dataModal = angular.copy(object);
    	$scope.dataModal.tubIsLow = '0';
    }
    
    $scope.markFinished = function(object){
    	$scope.dataModal = angular.copy(object);
    	$scope.dataModal.tubFinishedBy = getCookie('USER_USER_GROUP_ID');
    	$scope.dataModal.tubFinsihedAt = iOSLikeDate();
    }
    
    $scope.undomarkFinished = function(object){
    	$scope.dataModal = angular.copy(object);
    	$scope.dataModal.tubFinishedBy = '0';
    	$scope.dataModal.tubFinsihedAt = '0';
    }
    
    $scope.confirmedChanges = function(){
    	
		if($scope.dataModal.reiReagentInstanceId){
			primaryKey = 'reiReagentInstanceId';
			table = 'lot';
			createApi(table, angular.copy($scope.dataModal), $http, AllData.lotsList, primaryKey);
		}
		if($scope.dataModal.labLabeledAntibodyId){
			primaryKey = 'labLabeledAntibodyId';
			table = 'labeledantibody';
			createApi(table, angular.copy($scope.dataModal), $http, AllData.conjugatesList, primaryKey);
		}	    
    }

	//Sugar
	$scope.show = function(fileId){
		if(fileURL(fileId, $http, $sce, AllData.filesGroupList) == false)return false;
		return true;
	}

 	$scope.utfToHtml_ = function(str){
		return $sce.trustAsHtml(utfToHtml(str));
	}
	$scope.tempFileURL = function(fileId){
		return fileURL(fileId, $http, $sce, AllData.filesGroupList);
	}   
    $scope.worksFlow = function(object){
	    if(object.worksFlow)return object.worksFlow;
	    if(!object.apps)object.apps = JSON.parse(jsonEscape(object.cloApplication));
	    object.worksFlow = false;
	    if(object.apps['0'] == true || object.apps['2'] == true){
			object.worksFlow = true;   
	    }
    	return object.worksFlow;
    }
    $scope.worksImaging = function(object){
	    if(object.worksImaging)return object.worksImaging;
	    if(!object.apps)object.apps = JSON.parse(jsonEscape(object.cloApplication));
	    object.worksImaging = false;
	    if(object.apps['1'] == true || object.apps['3'] == true || object.apps['4'] == true){
			object.worksImaging = true;   
	    }
    	return object.worksImaging;
    }
    
    $scope.labelDate = function(dateL){
	    return dateL.substring(0, 10);
    }
    
    //Link to antibody DBss
    $scope.citeAb = function(aclone){
	    return "http://www.citeab.com/search?q="+aclone.cloName;
    }
    
    $scope.antibodyRegistry = function(aclone){
	    if(aclone.proName)
	    	return "http://www.antibodyregistry.org/search?q="+aclone.proName+'%20'+aclone.cloName;
	    else
	    	return null;
    }
    
    $scope.antibodyPedia = function(aclone){
	    if(aclone.proName)
		    return "http://www.antibodypedia.com/explore/"+aclone.proName+'+'+aclone.cloName;
	    else
	    	return null;
    }
    
    $scope.isFavoriteClone = function(aClone){
	    AllGetters.favorites();
	    var favs = AllGetters.favorites().clonesFavorite;
	    for(var i in favs){
		    if(favs[i] == aClone.cloCloneId){
			    aClone.isAFavorite = 'zyxfavorite';
			 	return 'danger';   
		    }
	    }
	    return 'default';
    }
 
    $scope.toogleFavoriteClone = function(aClone){
	    AllGetters.toogleFavoriteClone(aClone, $http);
    }
})

.directive('ngLike', function () {
				return {
					restrict: 'E',
					link: function (scope, elem, attrs) {
						elem.on('click', function () {
							window.open(attr.href, 'Share', 'width=600,height=400,resizable=yes');
						});
					}
				};
})

.controller('PanelCtrl', function($scope, SelectedPanel, $http, $window, AllData, AllGetters) {
	$scope.allGetters = AllGetters;
	$scope.baseData = AllData;
	AllData.getAllPanelsForGroup(false);
	AllData.getAllClonesForGroup(false);
	AllData.getAllLotsForGroup(false);
	AllData.getAllProteinsForGroup(false);
	AllData.getAllLabeledAntibodiesForGroup(false);

  	$scope.sort = null;
    $scope.theStatus = null;
    
    //Pagination
    $scope.page = 0;
    $scope.sizePage = 20;
    $scope.numberOfPages = function(list){
	    if(list)
	    return parseInt(list.length/$scope.sizePage)+1;
    }
    
    $scope.conditionsPaging = function(index, search){
	    if(search){
		    if(index >= $scope.sizePage)return false;
		    //if(search.length > 0)return true;
		    return true;
	    }
	    if(index >= $scope.sizePage * $scope.page && index < $scope.sizePage * ($scope.page + 1))return true;
    }
    
    $scope.changePage = function(pagePassed){
	    if(pagePassed < 0) pagePassed = 0;
	    if(pagePassed > $scope.numberOfPages() - 1)pagePassed = $scope.numberOfPages()-1;	    
	    $scope.page = pagePassed;
    }    
    
    $scope.addPanel = function(){
	    $scope.newPanel = {};
	    $scope.newPanel.panFluor = '0';
    }
    
    $scope.nextAddPanelModal =  function (){
	    $scope.newPanel.createdBy = AllData.selfLinker();
		if(checkRequired($scope.newPanel, ['panName'])){	
			createApi('panel', angular.copy($scope.newPanel), $http, AllData.myPanelsList, 'panPanelId');
		}
    };
    
    $scope.clicked = function (panel){
	  	SelectedPanel.selectedPanel = panel;
	  	$window.location.href = '#panelDetail';
    };
})

.controller('PanelDetailCtrl', function($scope, SelectedPanel, $http, $window, AllData, AllGetters) {

	$scope.allGetters = AllGetters;
	$scope.baseData = AllData;
	AllData.getAllPanelsForGroup(false);
	AllData.getAllClonesForGroup(false);
	AllData.getAllLotsForGroup(false);
	AllData.getAllLabeledAntibodiesForGroup(false);
	AllData.getAllTags(false);
	
  	$scope.sort = null;
    $scope.panel = SelectedPanel.selectedPanel;
    
    $scope.panel.nameeditable = false;
    
    $scope.panelDetails = JSON.parse(jsonEscape($scope.panel.panDetails));
    $scope.panelMetadata = JSON.parse(jsonEscape($scope.panel.catchedInfo));
    
    if($scope.panelMetadata){
	 	$scope.sketch = $scope.panelMetadata['sketch'];
	 	if($scope.sketch){
		 	for(var index in $scope.sketch){
		 		var linker = {};
		 		linker.tagTagId = index;
		 		linker.cloName = $scope.sketch[index];
		 		$scope.panelDetails.push(linker);
			}
	 	}else{
		 	$scope.sketch = {};
	 	}
    }else{
	    $scope.panelMetadata = {};
	    $scope.sketch = {};
    }
        
    for(var index in $scope.panelDetails){
    	var linker = $scope.panelDetails[index];
		linker.plaLabeledAntibodyId = parseInt(linker.plaLabeledAntibodyId);
	}

    $scope.theStatus = null;
    $scope.totalVolumePanel = "100";
    
    if(SelectedPanel.selectedPanel == -1)$window.location.href = '#panels';
    
    $scope.nameEdit = function(){
	    $scope.panel.nameeditable = !$scope.panel.nameeditable;   
    }
    
    $scope.amountAntibody = function (linker, initialConc, totalVolume, dilution){
	    if(dilution == true){
			var res = parseFloat(totalVolume) / parseFloat(linker.plaActualConc);
			linker.plaPipet = res;
			return res;
	    }
	    var res = parseFloat(totalVolume)*(parseFloat(linker.plaActualConc)/parseFloat(initialConc));
	    linker.plaPipet = res;
	    return res;
    }
    
    $scope.diluentVolume = function(totalVolume){
    	var cum = 0.0;
    	for(var index in $scope.panelDetails){
    		var linker = $scope.panelDetails[index];
    		if(!linker.plaActualConc)continue;
    		var conjugate = AllGetters.conjugate(linker.plaLabeledAntibodyId, linker);
    		linker.labConcentration = conjugate.labConcentration;
			var add = $scope.amountAntibody(linker, conjugate.labConcentration, totalVolume, linker.dilutionType == '1'?true:false);
			if($scope.excludeEmpty == true && parseInt(conjugate.tubFinishedBy)>0)continue;
    		if(!isNaN(add)){
	    		cum = cum + add;
    		}
       	}
       	console.log(parseFloat(totalVolume)+'  '+cum);
	    return parseFloat(totalVolume) - cum;
    }
    
    $scope.addTentative = function(){
	    $scope.newLinker = {};
    }
    
    $scope.rebuildObj = function(){
	    $scope.panelMetadata.sketch =  $scope.sketch;
	    $scope.panel.catchedInfo = createJSONFromDictionaryOfDictionaries($scope.panelMetadata);
    }
    
    $scope.removeLinker = function(linker){
	    delete $scope.sketch[linker.tagTagId];
	    console.log($scope.panelDetails);
	    for(var aLink in $scope.panelDetails){
		    if($scope.panelDetails[aLink].tagTagId == linker.tagTagId && $scope.panelDetails[aLink].cloName == linker.cloName){
			    $scope.panelDetails.splice(aLink, 1);
			    break;
		    }
	    }
	    $scope.rebuildObj();
    }
    
    $scope.nextAddTentativeModal = function(){
	    $scope.panelDetails.push($scope.newLinker);
	    
	    $scope.sketch[$scope.newLinker.tagTagId] = $scope.newLinker.cloName;
	    $scope.panelMetadata.sketch =  $scope.sketch;
	    $scope.panel.catchedInfo = createJSONFromDictionaryOfDictionaries($scope.panelMetadata);
		createApi('panel', angular.copy($scope.panel), $http, $scope.baseData.myPanelsList, 'panPanelId');    
    }
    
    $scope.editPanel = function (){

       $window.location.href = '#editPanel';
    }
    
    $scope.panelDesigner = function (){
       $window.location.href = '#refine_panel';
    }
    
    $scope.duplicate = function(panel){
	    var retVal = prompt("Enter the new panel name : ", "Panel name here");
		var panelNew = angular.copy(panel);
		panelNew.createdBy = getCookie('USER_USER_GROUP_ID');
		panelNew.groupId = getCookie('USER_GROUP_ID');
		panelNew.panName = retVal;
		panelNew.panPanelId = null;
		createApi('panel', panelNew, $http, $scope.baseData.myPanelsList, 'panPanelId');
    }
    
    $scope.resave = function(panel){
	    $scope.panel.nameeditable = false;
	  	$scope.panel.panDetails = createJSONFromArrayOfDictionaries($scope.panelDetails);
		createApi('panel', angular.copy($scope.panel), $http, $scope.baseData.myPanelsList, 'panPanelId');
    }
    
    $scope.deletePanel = function(panel){
	    ////Refactor
	    var txt;
		var r = confirm("Are you sure?");
		if (r == true) {
			deleteApi('panel', angular.copy($scope.panel), $http, AllData.myPanelsList, 'panPanelId');
		} else {
		
		}
    }
    
    $scope.exportCyTOF = function(version){
	    switch(version){
		    case 0:
			    generateCSV($scope.panel, $scope.panelDetails);
			    break;
		    case 1:
			    generateCyTOF1Panel($scope.panel, $scope.panelDetails);
			    break;
		    case 2:
			    generateCyTOF2Panel($scope.panel, $scope.panelDetails);
			    break;
		    case 3:
			    generateHeliosPanel($scope.panel, $scope.panelDetails);
			    break;			    			    
	    }
    }
    
    $scope.back = function(){
	    if($window.location.href.indexOf('refine')>0){
		    $window.location.href = '#editPanel';
		    return;
	    }
	    $window.location.href = '#panels';
    }
    
    $scope.isMyPanel = function(){
	    if(parseInt($scope.panel.createdBy) == parseInt(getCookie('USER_USER_GROUP_ID')))return true;
	    return false;
    }
    
    $scope.loadIsotopes = function(){
	    $.ajax({
		    url: "/apiLabPad/api/isotopes",
		    async: false,
		    success: function (csvd) {
			    $scope.isotopes = [];
			    var d = csvd.split('\n'); /*1st separator*/
		        var i = 0;//Cool trick i = d.length and while is (i--)
		        while(i<d.length)
		        {
			        if(d[i] !== ""){
				    	$scope.isotopes.push(d[i].split(','));
			        }
			        i++;
		        }			    
		    },
		    dataType: "text",
		    complete: function () {
		        // call a function on complete 
		        //console.log($scope.isotopes);
		    }
		});
    }
    $scope.loadIsotopes();
    $scope.oxidation = 3;
    $scope.one = 1;
    $scope.impurities = true;
    $scope.acounter = 0;
    
    $scope.computePanel = function(){
	    $scope.acounter = $scope.acounter + 1;
	    $scope.panelDesigned = [];
	    $scope.panelDesignedSummary = [];
	    
	    //Get Max
	    var max = 0;
	    var maxChan = 0;
	    var minChan = 0;	    
	    for(var i in $scope.panelDetails){
		    var ch = parseInt($scope.panelDetails[i].tagMW);
		    if(minChan == 0)minChan = ch;
		    else{
				if(ch < minChan)  minChan = ch; 
		    }
		    if(ch > maxChan)maxChan = ch;
		    
		    if($scope.panelDetails[i].plaExpected){
			    var test = Math.sqrt(parseFloat($scope.panelDetails[i].plaExpected) / 3.14159);
			    if(test > max){
				    max = test / 20;
			    }
		    }
	    }
	    
	    for(var i in $scope.panelDetails){
		    if($scope.panelDetails[i].ignore == false)continue;
		    var bub = {};
		    bub.type = 1;
		    var sig = parseFloat($scope.panelDetails[i].plaExpected);
		    if($scope.allSame == true)sig = $scope.allSameValue;
			bub.signal = $scope.panelDetails[i].plaExpected? Math.sqrt(sig / 3.14159)/max :2;
		    if($scope.allSameTolerance == true) bub.tolerance = $scope.allSameToleranceTolerance;
		    else bub.tolerance = $scope.panelDetails[i].plaTolerance?$scope.panelDetails[i].plaTolerance:'1';		    
		    bub.emitted = $scope.panelDetails[i].tagMW;
		    bub.received = $scope.panelDetails[i].tagMW;
		    $scope.panelDesigned.push(bub);
		    
		    if(parseInt(bub.emitted)+16 <= maxChan){
				var oxi = {};
			    oxi.tolerance = '0';
			    oxi.type = 5;	    
				oxi.signal = Math.sqrt((sig * parseFloat($scope.oxidation)/100) / 3.14159)/max;
				oxi.received = bub.emitted;
				oxi.emitted = parseInt(bub.emitted)+16;
				$scope.panelDesigned.push(oxi);    
		    }		    
			
			var plusOne = {};
		    plusOne.tolerance = '0';
		    plusOne.type = 6;	    
			plusOne.signal = Math.sqrt((sig * parseFloat($scope.one)/100) / 3.14159)/max;
			plusOne.received = bub.emitted;
			plusOne.emitted = parseInt(bub.emitted) + 1;
			$scope.panelDesigned.push(plusOne); 
		    
		    if($scope.impurities == true){
			    var added = 0;
			    for(var j in $scope.isotopes){
				    if($scope.isotopes[j][1] == bub.emitted){
					    for(var l in $scope.isotopes[j]){
						    if(l<2)continue;
						    if($scope.isotopes[j][l].length > 0 && $scope.isotopes[j][l] != '100'){
							     console.log('in '+bub.emitted+' found '+$scope.isotopes[j][1]+' spillover '+$scope.isotopes[j][l]+' for '+$scope.isotopes[0][l]);
							 	var subBub = {};
							    subBub.type = 2;
							    var spill = parseInt(parseFloat(sig) * parseFloat($scope.isotopes[j][l])/100.0);
							    subBub.signal = spill > 0? Math.sqrt(spill / 3.14159)/max:0.0001;
							    added += spill;
								subBub.tolerance = '0';		    
								subBub.emitted = $scope.isotopes[0][l];
								subBub.received = bub.emitted;
								$scope.panelDesigned.push(subBub);   
						    }   
					    }
				    }
			    }
		    }

		    
		    var sumBubA = {};
		    sumBubA.type = parseFloat(sig)/parseFloat(added)>5?1:1;
		    sumBubA.signal = bub.signal;
		    sumBubA.emitted = bub.emitted;
		    sumBubA.received = minChan - (maxChan - minChan)/10;
		    
		    $scope.panelDesigned.push(sumBubA);
	    }
	    for(var j in $scope.panelDetails){
		    var sumBubB = {};
		    sumBubB.type = 7;
		    
		    var add = 0;
		    var chanAnalyzed = parseInt($scope.panelDetails[j].tagMW);
		    console.log('----');
		    for(var k in $scope.panelDesigned){
			    if(chanAnalyzed == parseInt($scope.panelDesigned[k].emitted) && $scope.panelDesigned[k].type > 1 && $scope.panelDesigned[k].type != 7){			    
				    add += 3.14159 * parseFloat($scope.panelDesigned[k].signal) * parseFloat($scope.panelDesigned[k].signal);
			    }
		    }

		    sumBubB.signal = Math.sqrt(add / 3.14159);
		    sumBubB.emitted = chanAnalyzed;
		    sumBubB.received =  minChan - (maxChan - minChan)/10;
		    $scope.panelDesigned.push(sumBubB);
	    }
    }
    
    $scope.makeBool = function(linker){
	    if(linker.ignore == 'true')linker.ignore = true;
	    if(linker.ignore == 'false')linker.ignore = false;
    }
    
    $scope.computePanel();
})

.filter('panelFilter', function() {
  return function(input, searchText, scope) {
  		if(typeof searchText === 'undefined')return input;
  		//return input;
  		if(!input)return;
  		var filtered = [];
/*
  		for (var i = 0; i < input.length; i++) {
  		
  			var item = input[i];
  			if(item.labLotId === 'undefined')continue;
  			var lot = scope.allGetters.lot(item.labLotId);
  			if(lot.lotCloneId === 'undefined')continue;
  			var clone = scope.allGetters.clone(lot.lotCloneId); 
   			if(clone.cloCloneId === 'undefined')continue;
   			var protein = scope.allGetters.protein(clone.cloProteinId); 
  		  		
			var item = input[i];
			if(clone.cloName != null  ){
				if(clone.cloName.toLowerCase().indexOf(searchText.toLowerCase()) > -1){
					filtered.push(item);
					continue;
				}
			}
			if(protein.proName != null){
				if(protein.proName.toLowerCase().indexOf(searchText.toLowerCase()) > -1){
					filtered.push(item);
					continue;
				}
			}
			if(item.labBBTubeNumber != null){
				if(item.labBBTubeNumber.toLowerCase().indexOf(searchText.toLowerCase()) > -1){
					filtered.push(item);
					continue;
				}
			}
		}
*/
		return filtered;
  };
})

.controller('EditPanelCtrl', function($scope, SelectedPanel, $http, $window, AllData, AllGetters) {

	$scope.allGetters = AllGetters;
	$scope.baseData = AllData;
	AllData.getAllPanelsForGroup(false);
	AllData.getAllClonesForGroup(false);
	AllData.getAllLotsForGroup(false);
	AllData.getAllLabeledAntibodiesForGroup(false);
	AllData.getAllTags(false);

  	$scope.sort = null;
    $scope.panel = SelectedPanel.selectedPanel;
    $scope.panelDetails = JSON.parse(jsonEscape($scope.panel.panDetails));
    if(!$scope.panelDetails)$scope.panelDetails = [];
    $scope.totalVolumePanel = "100";
        
    if(!SelectedPanel.selectedPanel){
	 	$window.location.href = '#panels';   
    }
    
    $scope.panelDesigner = function (){
       $window.location.href = '#refine_panel';
    }

    
    $scope.buttonTapped = function(conj, atag, $event){
		if ($event.altKey){}
		if ($event.ctrlKey){}
		if ($event.shiftKey){
			if($scope.isSelected(conj) == false){
				$scope.selectConjugate(conj);
	    	}else{
				$scope.unSelectConjugate(conj);		    	
	    	}
	    	return;
		}
		
    	if($scope.isSelected(conj) == false){
		    $scope.unselectAllForTag(atag);	    	
			$scope.selectConjugate(conj);    		
	    }else{
		    $scope.unselectAllForTag(atag);
	    }
    }
    
    $scope.statusAntibody = function(conjugate){
	    var selected = $scope.isSelected(conjugate);
	    var isOver = false;
	    if(parseInt(conjugate.tubFinishedBy) > 0)isOver = true;
	    
	    var isLow = false;
	    if(parseInt(conjugate.tubIsLow) > 0)isLow = true;
	    
	    if(selected == true){
		    if(isOver == true)return 5;		    
		    if(isLow == true)return 4;
		    return 3;
	    }
	    if(isOver == true)return 2;
	    if(isLow == true)return 1;
	    return 0;
    }
    
    $scope.isSelected = function(conjugate){
    	for(var select in $scope.panelDetails){
	    	if(parseInt($scope.panelDetails[select]['plaLabeledAntibodyId']) == parseInt(conjugate.labLabeledAntibodyId)){return true;}
    	}
	    return false;
    }

    $scope.unselectAllForTag = function(atag){
    	for(var i in $scope.panelDetails){
    		if(parseInt($scope.allGetters.conjugate($scope.panelDetails[i]['plaLabeledAntibodyId']).labTagId) == parseInt(atag.tagTagId)){
					
		    	$scope.panelDetails.splice(i, 1);	
	    	}
    	}
    }
    
    $scope.selectConjugate = function(conj){

    	$scope.panelDetails.push({'plaLabeledAntibodyId':conj.labLabeledAntibodyId, 'plaActualConc':'2'});
    }
    $scope.unSelectConjugate = function(conj){
		for(var i in $scope.panelDetails){
    		if($scope.panelDetails[i].plaLabeledAntibodyId == conj.labLabeledAntibodyId){
		    	$scope.panelDetails.splice(i, 1);	
	    	}
    	}
    }    
    
    $scope.resave = function(){
    	$scope.panel.panDetails = createJSONFromArrayOfDictionaries($scope.panelDetails);
	    createApi('panel', angular.copy($scope.panel), $http, null, 'panPanelId');
    }
    
    $scope.saveChangesAndReturn = function (){
	   $scope.panel.panDetails = createJSONFromArrayOfDictionaries($scope.panelDetails);
	   createApi('panel', angular.copy($scope.panel), $http, null, 'panPanelId');
       $window.location.href = '#panelDetail';
    }
    
    $scope.back = function(oneStep){
	    if(oneStep == true)$window.location.href = '#panelDetail';
	    else $window.location.href = '#panels';
    }
    
    $scope.isFavoriteClone = function(aClone){
	    AllGetters.favorites();
	    var favs = AllGetters.favorites().clonesFavorite;
	    for(var i in favs){
		    if(favs[i] == aClone.cloCloneId){
			    aClone.isAFavorite = 'zyxfavorite';
			    return true;
		    }
	    }
	    return null;
    }
})

.controller('StatsAGCtrl', function($scope, SelectedPanel, $http, $window, AllData, AllGetters) {

	$scope.allGetters = AllGetters;
	$scope.baseData = AllData;
	AllData.getAllLabeledAntibodiesForGroup(false);
	AllData.getAllLotsForGroup(false);
	AllData.getAllPanelsForGroup(false);	

	var countDone = false;
	var countPur = false;
	var countFin = false;
	
	console.log(moment().year());
	for(var j in AllData.conjugatesList){
	  	//console.log(moment(AllData.conjugatesList[j].labDateOfLabeling.substring(0, 19)).year());
	}

  	$scope.recount = function(){
	  	for(var i in AllData.peopleList){
		  	
		  	if(!AllData.peopleList[i].totalLabeled){
			  	var counterPerson = 0;
			  	var count2016 = 0;
			  	var count2015 = 0;
			  	for(var j in AllData.conjugatesList){
				  	if(AllData.conjugatesList[j].labContributorId == AllData.peopleList[i].perPersonId){
					  	counterPerson++;
					  	if(AllData.conjugatesList[j].labDateOfLabeling.indexOf('2016-') > -1)count2016++;
					  	if(AllData.conjugatesList[j].labDateOfLabeling.indexOf('2015-') > -1)count2015++;
				  	}
				  	countDone = true;
				  	AllData.peopleList[i].totalLabeled = counterPerson;
				  	AllData.peopleList[i].totalLabeled2016 = count2016;	
				  	AllData.peopleList[i].totalLabeled2015 = count2015;					  	
			  	}
		  	}
		  	
		  	if(!AllData.peopleList[i].totalRequested){
			  	var counterPurchasePerson = 0;
			  	var countPurchase2016 = 0;
			  	var countPurchase2015 = 0; 			  	
			  	for(var j in AllData.lotsList){
			  		if(AllData.lotsList[j].reiRequestedBy == AllData.peopleList[i].gpeGroupPersonId){
				  		counterPurchasePerson++;
				  		if(AllData.lotsList[j].reiRequestedAt.indexOf('2016-') > -1)countPurchase2016++;
				  		if(AllData.lotsList[j].reiRequestedAt.indexOf('2015-') > -1)countPurchase2015++;
			  		}
			  		countPur = true;
			  		AllData.peopleList[i].totalRequested = counterPurchasePerson;
			  		AllData.peopleList[i].totalRequested2016 = countPurchase2016;	
			  		AllData.peopleList[i].totalRequested2015 = countPurchase2015;
		  		}
		  	}
		  	
		  	if(!AllData.peopleList[i].totalFinished){
			  	var counterFinished = 0;
			  	var counterFinished2016 = 0;
			  	var counterFinished2015 = 0;			  				  	
			  	for(var j in AllData.conjugatesList){

				  	if(AllData.conjugatesList[j].tubFinishedBy == AllData.peopleList[i].gpeGroupPersonId){
			  			counterFinished++;
			  			if(AllData.conjugatesList[j].tubFinishedAt){
					  		if(AllData.conjugatesList[j].tubFinishedAt.indexOf('2016-') > -1)counterFinished2016++;
				  			if(AllData.conjugatesList[j].tubFinishedAt.indexOf('2015-') > -1)counterFinished2015++;				  						  			
			  			}
		  			}
			  		
				  	AllData.peopleList[i].totalFinished = counterFinished;
				  	AllData.peopleList[i].totalFinished2016 = counterFinished2016;
				  	AllData.peopleList[i].totalFinished2015 = counterFinished2015;
		  		}
		  	}
		  			  	
	  	} 	
  	}
  	
  	$scope.panConjs = [];
  	$scope.filtConjs = [];  	
  	var doneRecLabs = false;
  	$scope.recountLabs = function(){
	  	if(AllData.panelsList && doneRecLabs == false){
		  	if(AllData.conjugatesList){
			  	var minDate = null;
			  	for(var i in AllData.panelsList){
				  	if(!AllData.panelsList[i].panDetails)continue;
				  	var all = JSON.parse(jsonEscape(AllData.panelsList[i].panDetails));

				  	for(var j in all){
				  		var lab = findFirstObjectInArrayWithValueInField(AllData.conjugatesList, all[j].plaLabeledAntibodyId, 'labLabeledAntibodyId');
				  		var lab2 = findFirstObjectInArrayWithValueInField($scope.filtConjs, all[j].plaLabeledAntibodyId, 'labLabeledAntibodyId');
				  		if(lab){
					  		if(lab.lastPanel){
						  		if(parseInt(lab.lastPanel) < parseInt(AllData.panelsList[i].panPanelId))lab.lastPanel = AllData.panelsList[i].panPanelId;
					  		}else{
						  		lab.lastPanel = AllData.panelsList[i].panPanelId;
					  		}
						  	all[j].panelId = AllData.panelsList[i].panPanelId;
							$scope.panConjs.push(all[j]);
							if(lab)all[j].tube_number = lab.labBBTubeNumber;
							doneRecLabs = true;
							if(!lab2){
								var conv =  convertIOSTypeDateToUnix(lab.labDateOfLabeling)/(365 * 24 * 3600 * 1000) + 1970;
								
								if(!minDate){
									if(lab.labDateOfLabeling.length>17){
										minDate = conv;
									}
								}
								if(conv < minDate)minDate = conv;

								lab.labDate = conv;
								if(!conv){
									lab.labDate = minDate;
								}
								
								lab.finished = parseInt(lab.tubFinishedBy) > 0?0:2;
								lab.finished_at = convertIOSTypeDateToUnix(lab.tubFinishedAt)/(365 * 24 * 3600 * 1000) + 1970;
		
								$scope.filtConjs.push(lab);
								
							}					  		
				  		}
				  	}	
				  	//console.log($scope.filtConjs);				  	
			  	}			  	
		  	}
		  	
	  	}		  			  	
  	}
  	
  	
  	var doneRecPanels = false;  	
  	$scope.recountPanels = function(){
	  	if(AllData.panelsList && doneRecPanels == false){
		  	if(AllData.peopleList){
			  	for(var i in AllData.peopleList){
				  	var counterPanels = 0;

				  	for(var j in AllData.panelsList){
				  		
						if(AllData.panelsList[j].createdBy == AllData.peopleList[i].gpeGroupPersonId)counterPanels++;
						doneRecPanels = true;
				  	}
				  	AllData.peopleList[i].totalPanels = counterPanels;					  	
			  	}
		  	}
	  	}		  			  	
  	}  
  	var doneRecLots = false;  	
  	$scope.recountLots = function(){
	  	if(AllData.lotsList && doneRecLots == false){
		  	var minDate = 2016;
		  	for(var i in AllData.lotsList){
		  		var conv =  convertIOSTypeDateToUnix(AllData.lotsList[i].reiRequestedAt)/(365 * 24 * 3600 * 1000) + 1970;								
				if(!minDate){
					if(AllData.lotsList[i].reiRequestedAt>17){
						minDate = conv;
					}
				}
				if(conv < minDate)minDate = conv;
				console.log(conv);
				AllData.lotsList[i].requested_at = conv;
				if(!conv){
					AllData.lotsList[i].requested_at = minDate;
				}
				doneRecLots = true;
		  	}
	  	}		  			  	
  	}  	
  	
})

