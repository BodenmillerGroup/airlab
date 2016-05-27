angular.module('Plans', ['ngRoute', 'Getters'])
 
.config(function($routeProvider) {
  $routeProvider
    .when('/plans', {
      controller:'PlansCtrl',
      templateUrl:'web/plans.html'
    })
    .when('/shared', {
      controller:'PlansSharedCtrl',
      templateUrl:'web/plans_shared.html'
    })
    .when('/experiment', {
      controller:'ExperimentCtrl',
      templateUrl:'web/experiment.html'
    })
    .otherwise({
      redirectTo:'/'
    });
})

.factory('SelectedExperiment', function() {
  return {"selectedExperiment" : "-1"};
})

.controller('PlansSharedCtrl', function($scope, $http, $window, SelectedExperiment, AllGetters, AllData) {

    $scope.baseData = AllData;
    $scope.allGetters = AllGetters;
    AllData.getAllPlansSharedForPersonGroup(false);    
    AllData.getAllEnsayosSharedForPersonGroup(false);
	
	$scope.clicked = function(experiment){
		SelectedExperiment.selectedExperiment = experiment;
	  	$window.location.href = '#experiment';
	};
})
 
.controller('PlansCtrl', function($scope, $http, $window, SelectedExperiment, AllGetters, AllData) {

    $scope.baseData = AllData;
    $scope.allGetters = AllGetters;
    AllData.getAllPlansForPersonGroup(false);
    AllData.getAllEnsayosForPersonGroup(false);
	
	$scope.clicked = function(experiment){
		SelectedExperiment.selectedExperiment = experiment;
	  	$window.location.href = '#experiment';
	};
	
	$scope.addEnsayo = function(plan){
		var retVal = prompt("Enter the new experiment's name : ", "Experiment name here");
		var ensayo = {};
		ensayo.enyPlanId = plan.plnPlanId;
		ensayo.enyTitle = retVal;
		if(retVal) createApi('ensayo', ensayo, $http, AllData.ensayosList, 'enyEnsayoId');
	}
	$scope.addProject = function(){
		//alert($scope.plansList);return;
		var retVal = prompt("Enter the new project's name : ", "Project name here");
		var plan = {};
		plan.plnTitle = retVal;
		if(retVal) createApi('plan', plan, $http, AllData.plansList, 'plnPlanId');
	}
	$scope.settingsProject = function(project){
		if(!project)$scope.dataModal = {};
	    if(project)$scope.dataModal = angular.copy(project);
	    if(project.plnShare){
			var dict = JSON.parse(project.plnShare);
			var arr = [];
			for(var i in dict){
				var miniDict = {};
				miniDict['key'] = i.replace(/-/g, '');
				miniDict['value'] = dict[i];
				console.log(i.replace(/-/g, ''));
				arr.push(miniDict);
			}
			$scope.dataModal.pairs = arr; 
		}else{
			$scope.dataModal.pairs = [];	
		}
		openModal('settingsProject');
	}
	$scope.addPair = function(){
		if(!$scope.dataModal.pairs){
			$scope.dataModal.pairs = [];
		}
		$scope.dataModal.pairs.push({'key':'','value': ''});
	}
	$scope.removePair =  function(ind){
		$scope.dataModal.pairs.splice(ind, 1);
	}
	$scope.changeDictValue = function(dict, avalue){	
		dict.value = avalue;
	}
	$scope.changeDictKey = function(dict, key){
		dict.key = key;
	}
	
	$scope.nextSettingsProjectModal = function(){
		var c = confirm('Are you sure?');
		if(c == true){
			if($scope.dataModal.pairs.length > 0){
				var redoneDict = {};
				for(var i in $scope.dataModal.pairs){
					console.log(i);
					redoneDict['-'+$scope.dataModal.pairs[i].key+'-'] = $scope.dataModal.pairs[i].value;
				}
				console.log(redoneDict);
				$scope.dataModal.plnShare = createJSONFromDictionary(redoneDict);
			}else{
				$scope.dataModal.plnShare = null;
			}
			createApi('plan', $scope.dataModal, $http, AllData.plansList, 'plnPlanId');
			closeModal('settingsProject');			
		}		
	}
})

.controller('ExperimentCtrl', function($scope, $http, $window, SelectedExperiment, $sce, AllGetters, AllData) {
    
    $scope.selectedExperiment = SelectedExperiment.selectedExperiment;
    $scope.baseData = AllData;
    $scope.allGetters = AllGetters;
    $scope.baseData.partsList = [];//To clear before.
    AllData.getAllPartsForExperiment($scope.selectedExperiment.enyEnsayoId, true);
    AllData.getAllPanelsForGroup(false);
    AllData.getAllProteinsForGroup(false);    
	AllData.getAllClonesForGroup(false);
	AllData.getAllLotsForGroup(false);
	AllData.getAllLabeledAntibodiesForGroup(false);
	AllData.getAllTags(false);
	AllData.getAllRecipesForGroup(false);	
    AllData.getAllFilesForPersonGroup(false);
	AllData.getAllFilePartsForGroup(false);
	
	$scope.totalVolumePanel = 100;  


    $scope.filesPartLinkersList = [];
    $scope.writable = null;
    
    $scope.back = function(){
		$window.location.href = '#/plans';
	}
    if(!$scope.selectedExperiment.enyEnsayoId)$scope.back();
    
    $scope.selectedExperiment.nameeditable = false;
		
	$scope.utfToHtml_ = function(str){
		return $sce.trustAsHtml(utfToHtml(str));
	}
		
	$scope.file = function(fileId){//Old files
		var array = findObjectsInArrayWithIdInField(AllData.filesList, fileId, 'filFileId');
	    return array[0];
	};
	$scope.filePartForPart = function(part){
		var array = findObjectsInArrayWithIdInField(AllData.filesPartLinkersList, part.prtPartId, 'fptPartId');
	    return array[0];
	};
	$scope.filePartForFile= function(file){
		var array = findObjectsInArrayWithIdInField(AllData.filesPartLinkersList, file.filFileId, 'fptFileId');
	    return array[0];
	};
	
	$scope.getSteps = function(part){
		if(!part.steps){
			var allSteps = JSON.parse(part.prtText);
			if(!allSteps)allSteps = [];
			part.steps = allSteps;	
		}
		
		return part.steps;
	}	
	
	$scope.operateOnSelected = function(){
		// Alerts the currently selected contents
		alert(tinyMCE.activeEditor.selection.getContent());
	}
	
	//http://ajaxorg.github.io/ace-builds/kitchen-sink.html
	$scope.languages = ["abap","abc","actionscript","ada","apache_conf","asciidoc", "assembly_x86","autohotkey","batchfile","c_cpp","c9search","cirru","clojure","cobol", "coffee","coldfusion","csharp","css","curly","d","dart","diff","dockerfile","dot","dummy", "dummysyntax","eiffel","ejs","elixir","elm","erlang","forth","fortran","ftl","gcode","gherkin", "gitignore","glsl","gobstones","golang","groovy","haml","handlebars","haskell","haxe","html", "html_elixir","html_ruby","ini","io","jack","jade","java","javascript","json","jsoniq","jsp","jsx","julia","latex","lean","less","liquid","lisp","livescript","logiql","lsl","lua","luapage","lucene","makefile","markdown","mask","matlab","maze","mel","mushcode","mysql","nix","nsis","objectivec","ocaml","pascal","perl","pgsql","php","powershell","praat","prolog","properties","protobuf","python","r","razor","rdoc","rhtml","rst","ruby","rust","sass","scad","scala","scheme","scss","sh","sjs","smarty","snippets","soy_template","space","sql","sqlserver","stylus","svg","swift","tcl","tex","text","textile","toml","twig","typescript","vala","vbscript","velocity","verilog","vhdl","wollok","xml","xquery","yaml","django"];
	
	$scope.changedLang = function(part){
		var editor = ace.edit("code_editor_"+part.prtPartId);
		editor.session.setMode("ace/mode/"+part.prtLanguage);
	}
	
	$scope.themes = {"ace/theme/chrome":"Chrome",
		"ace/theme/clouds":"Clouds",
		"ace/theme/crimson_editor":"Crimson Editor",
		"ace/theme/dawn":"Dawn",
		"ace/theme/dreamweaver":"Dreamweaver",
		"ace/theme/eclipse":"Eclipse",
		"ace/theme/github":"GitHub",
		"ace/theme/iplastic":"IPlastic",
		"ace/theme/solarized_light":"Solarized Light",
		"ace/theme/textmate":"TextMate",
		"ace/theme/tomorrow":"Tomorrow",
		"ace/theme/xcode":"XCode",
		"ace/theme/kuroir":"Kuroir",
		"ace/theme/katzenmilch":"KatzenMilch",
		"ace/theme/sqlserver":"SQL Server",
		"ace/theme/ambiance":"Ambiance",
		"ace/theme/chaos":"Chaos",
		"ace/theme/clouds_midnight":"Clouds Midnight",
		"ace/theme/cobalt":"Cobalt",
		"ace/theme/idle_fingers":"idle Fingers",
		"ace/theme/kr_theme":"krTheme",
		"ace/theme/merbivore":"Merbivore",
		"ace/theme/merbivore_soft":"Merbivore Soft",
		"ace/theme/mono_industrial":"Mono Industrial",
		"ace/theme/monokai":"Monokai",
		"ace/theme/pastel_on_dark":"Pastel on dark",
		"ace/theme/solarized_dark":"Solarized Dark",
		"ace/theme/terminal":"Terminal",
		"ace/theme/tomorrow_night":"Tomorrow Night",
		"ace/theme/tomorrow_night_blue":"Tomorrow Night Blue",
		"ace/theme/tomorrow_night_bright":"Tomorrow Night Bright",
		"ace/theme/tomorrow_night_eighties":"Tomorrow Night 80s",
		"ace/theme/twilight":"Twilight",
		"ace/theme/vibrant_ink":"Vibrant Ink"};
	
	$scope.changedTheme = function(part){
		var editor = ace.edit("code_editor_"+part.prtPartId);
		editor.setTheme(part.prtTheme);
	}
	
	$scope.newTextPart = function(){
		var part = {};
		part.createdBy = AllData.selfLinker();
		part.prtEnsayoId = $scope.selectedExperiment.enyEnsayoId;
		part.prtType = 'text';
		$scope.writable = part;
		part.prtPosition = countArray(AllData.partsList).toString();
		if(!AllData.partsList)AllData.partsList = [];
		createApi('part', part, $http, AllData.partsList, 'prtPartId');
	}
	
	$scope.startEditors = function(){
		//tinymce.init({ selector:'textarea' });
		tinymce.init({
		  selector: 'textarea#texter',
		  height: 500,
		  plugins: [
		    'advlist autolink lists link image charmap print preview anchor',
		    'searchreplace visualblocks code fullscreen',
		    'insertdatetime media table contextmenu paste code'
		  ],
		  toolbar: 'insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image',
		  statusbar:false,
		  content_style: 'p {font-size: 30px}',
/*
		  content_css: [
		    '//fast.fonts.net/cssapi/e6dc9b99-64fe-4292-ad98-6974f93cd2a2.css',
		    '//www.tinymce.com/css/codepen.min.css'
		  ]
*/
		});
	}
		
	$scope.newCodePart = function(){
		var part = {};
		part.createdBy = AllData.selfLinker();		
		part.prtEnsayoId = $scope.selectedExperiment.enyEnsayoId;
		part.prtType = 'cod';
		part.prtLanguage = 'python';
		part.prtTheme = 'ace/theme/twilight';		
		$scope.writable = part;
		part.prtPosition = countArray(AllData.partsList).toString();
		createApi('part', part, $http, AllData.partsList, 'prtPartId');
	};
	$scope.addTextToCodeEditor = function(part){
		if($scope.writable == part)return;//To avoid reseting text when has done change of theme or language while editing part
		var editor = ace.edit("code_editor_"+part.prtPartId);
		editor.setValue(part.prtText);
		if(!part.prtLanguage)part.prtLanguage = 'javascript';
		editor.session.setMode("ace/mode/"+part.prtLanguage);
		if(!part.prtTheme)part.prtTheme = 'ace/theme/twilight';
		editor.setTheme(part.prtTheme);
		editor.gotoLine(editor.session.getLength()-1);
		//return min(max(editor.session.getLength() * 16, 100), 400);
	};
	$scope.disableCode = function(part, disable){
		var editor = ace.edit("code_editor_"+part.prtPartId);
		if(editor)editor.setReadOnly(disable);
	}
	
	$scope.edit = function(part){
		
		if($scope.writable == part){
			if(part.prtType == 'text'){
				//console.log(tinyMCE.activeEditor.getContent());
				//console.log(tinyMCE.activeEditor.getContent({format : 'raw'}));
				var text = tinyMCE.activeEditor.getContent({format : 'raw'});
				part.prtText = text;
				createApi('part', angular.copy(part), $http, null, 'prtPartId');
				$scope.cancelEdit();
			}
			if(part.prtType == 'cod'){
				var editor = ace.edit("code_editor_"+part.prtPartId);
				part.prtText = editor.getValue();
				createApi('part', angular.copy(part), $http, null, 'prtPartId');
				$scope.writable = null;
			}			
		}
		else
		{
			$scope.cancelEdit();			
			if(part.prtType == 'text'){
				$scope.writable = part;
				$("#part"+part.prtPartId).show();
				startEditors();	
			}		
			$scope.writable = part;
		}
	};	
	$scope.cancelEdit = function(){
		if($scope.writable){
			if($scope.writable.prtType == 'cod'){
				var editor = ace.edit("code_editor_"+$scope.writable.prtPartId);
				editor.setValue($scope.writable.prtText);
				editor.setReadOnly(true);
			}	
		}
		
		$scope.writable = null;
	};
	$scope.close = function(part){
		var retVal = confirm("Are you sure?\nThis action can not be undone");
	    if( retVal == true ){
	      $scope.writable = null;
		  part.prtClosedAt = iOSLikeDate();
		  createApi('part', angular.copy(part), $http, null, 'prtPartId');
		  return true;
	    }else{
		  return false;
	    }
	}
	$scope.panelChosen = function(panel){
		var part = {};
		part.createdBy = AllData.selfLinker();		
		part.prtType = 'pan';
		part.prtText = panel.panDetails;
		part.prtEnsayoId = $scope.selectedExperiment.enyEnsayoId;
		createApi('part', part, $http, AllData.partsList, 'prtPartId');
	}
	
	$scope.protocolChosen = function(protocol){
		var part = {};
		part.createdBy = AllData.selfLinker();		
		part.prtType = 'pro';
		part.catchedInfo = protocol.rcpTitle;
		part.prtText = protocol.catchedInfo;
		part.prtEnsayoId = $scope.selectedExperiment.enyEnsayoId;
		createApi('part', part, $http, AllData.partsList, 'prtPartId');
	}
	
	$scope.savePan = function(part){
		part.prtText = createJSONFromArrayOfDictionaries(part.linkers);
		createApi('part', part, $http, AllData.partsList, 'prtPartId');		
	}
	
	$scope.panelLinkers = function(part){
		if(part.prtText){
			if(part.linkers)return part.linkers;
			part.linkers = JSON.parse(jsonEscape(part.prtText));
			return part.linkers;
		}
		return [];
	}
	
	$scope.amountAntibody = function (finalConc, initialConc, totalVolume){
	    return parseFloat(totalVolume)*(parseFloat(finalConc)/parseFloat(initialConc));
    }
    
    $scope.diluentVolume = function(part){
    	var cum = 0.0;
    	for(var index in part.linkers){
    		var linker = part.linkers[index];
			var add = $scope.amountAntibody(linker.plaActualConc, AllGetters.conjugate(linker.plaLabeledAntibodyId, linker).labConcentration, part.catchedInfo);
			
    		if(!isNaN(add)){
	    		cum = cum + add;
    		}
       	}
	    return parseFloat(part.catchedInfo) - cum;
    }
    	
	
	$scope.deletePart = function(part){
		var r = confirm("Are you sure?");
		if (r == true) {
			deleteApi('part', angular.copy(part), $http, $scope.baseData.partsList, 'prtPartId');
		} else {
		
		}
	}
	
	$scope.resave = function(){
	    $scope.selectedExperiment.nameeditable = false;
		createApi('ensayo', angular.copy($scope.selectedExperiment), $http, $scope.baseData.ensayosList, 'enyEnsayoId');
    }
    
    $scope.nameEdit = function(){
	    $scope.selectedExperiment.nameeditable = !$scope.selectedExperiment.nameeditable;   
    }
	
	
	$scope.styleForPart = function(part){
		if(part.prtType == 'text' && $scope.writable == part){
			return {"padding":"0px"}
		}
		if(part.prtType == 'cod'){
			return {"padding":"0px"}
		}
		return {};
	}
	
	
	//This is for files
	$scope.addFile = function () {

	}
	
	$scope.files = [];//These are the files selected
	$scope.uploadComplete = false;
	$scope.file = null;
		
	
	$scope.cancelFile = function(element) {
		element.files = null;
	}

    $scope.uploadFile = function() {
        
    	var aFile = {};
    	aFile.filExtension = getExtensionFromFilename($scope.files[0].name);
		aFile.filHash = makeHash(2)+'_'+makeHash(20);
		aFile.filSize = $scope.files[0].size;
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
		//client.setRequestHeader("Content-Type", "multipart/form-data");//This gives troble in the PHP server
		client.send(fd);  /* Send to server */ 
     
	   client.onreadystatechange = function() 
	   {
	      if (client.readyState == 4 && client.status == 200) 
	      {
	         //alert(client.statusText + '__returned '+client.responseText);
	         var idRet = createApi('file', aFile, $http, AllData.filesList, 'filFileId');
	         $scope.newData.file = idRet;
	      }else if(client.status != 200){
		      genericError();
	      }
	   }
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
    //Refactor
    $scope.getFileUrl = function(fileId){
	    return fileURL(fileId, $http, $sce, AllData.filesList);
	}
		//This is for files
	$scope.tempFileURL = function(fileId){
		if(fileId)
	    return fileURL(fileId, $http, $sce, AllData.filesList);
	}

	$scope.downloadFileData = function(id, $http){
		if(id)
		getFileForCanvas(id, $http);
	}	
	
	$scope.nextAddFileModal =  function (){
		if($scope.file){
			
	    	var floatingPart = {};
			floatingPart.prtEnsayoId = $scope.selectedExperiment.enyEnsayoId;
			floatingPart.prtType = 'fil';
			floatingPart.prtPosition = countArray(AllData.partsList).toString();
			floatingPart.createdAt = getCurrentDateJS();
			
			//Move this below and do properly
			createApi('part', floatingPart, $http, AllData.partsList, 'prtPartId', linkerPart);
			
			function linkerPart(){
				console.log(floatingPart);
				var zfilepart = {};
				zfilepart.fptPartId = floatingPart.prtPartId;
				zfilepart.fptFileId = $scope.file.filFileId;
				
				floatingPart.prtEnsayoId = $scope.selectedExperiment.enyEnsayoId;
				AllData.partsList.push($scope.floatingPart);
				
				createApi('zfilepart', zfilepart, $http, AllData.filesPartLinkersList, 'fptFilePartId');
			}
			
		}
    };	
	
})
