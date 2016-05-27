function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i=0; i<ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1);
        if (c.indexOf(name) == 0) return c.substring(name.length,c.length);
    }
    return "";
}

function dataCrud(){

	var userId =getCookie('USER_ID');
	var linker =getCookie('USER_USER_GROUP_ID');
	var group =getCookie('USER_GROUP_ID');
	var token =getCookie('TOKEN_PUBLIC_KEY');
	
	return 'dataCrud={"groupId":"'+group+'","perPersonId":"'+userId+'","linkerFlag":"'+linker+'","token":"'+token+'"}';
}

function postCall($http, postData, apiExtension, $scope, receiver, callBack, window){
	
	$http({method: 'POST', 
	    	data: postData, 
	    	headers: {'Content-Type': 'application/x-www-form-urlencoded'},
	    	url: '/apiLabPad/api/'+apiExtension}).success(function(data, status, headers, config) {
	    		if(data == 0){
		    		if(!$scope[receiver])$scope[receiver] = [];
	    		}else{
		    		//TODO push here instead of substitute
		    		$scope[receiver] = data;
	    		}
	    		if(callBack)callBack();
      			
		    }).error(function(data, status, headers, config) {
					//TODO notify the progress bar and the user and prompt for reload
			});
}

function getCall($http, apiExtension, $scope, receiver, callBack){
	
	$http({method: 'GET',
		url: '/apiLabPad/api/'+apiExtension}).success(function(data, status, headers, config) {
      		if(data == 0){
		    	if(!$scope[receiver])$scope[receiver] = [];
	    	}else{
		    	//TODO push here instead of substitute
		    	$scope[receiver] = data;
	    	}
      		if(callBack)callBack();
        }).error(function(data, status, headers, config) {
          //TODO notify the progress bar and the user and prompt for reload
		});
}

function isObject(val) {
    if (val === null) { return false;}
    return ( (typeof val === 'function') || (typeof val === 'object') );
}

function createJSONFromDictionary(dictionary){
	var jsonString = '{';
	for(var index in dictionary) {
		var field =  dictionary[index];
		if(isObject(field)){
			console.log(field);
			continue;
		}

			//jsonString += '\\\"'+index+'\\\":\\\"'+field+'\\\",';
			jsonString += '"'+index+'":"'+field+'",';
			//if(jsonString.indexOf('\n') > -1 || jsonString.indexOf('\r') > -1){
			//jsonString = jsonString.replace(/(\n|\r)/g, ' ');
			//jsonString = jsonString.replace(/(\n|\r)/g, '<br>');
			//}	
		
  	}
  	if(jsonString.length == 1)return '{}';
  	jsonString = jsonString.substring(0, jsonString.length - 1);
  	jsonString += '}';
	return jsonString;
}

function createJSONFromDictionaryOfDictionaries(dictionary){
	var jsonString = '{';
	for(var index in dictionary) {
		
		var inDict = dictionary[index];
		
		jsonString += '"'+index+'":'+createJSONFromDictionary(inDict)+',';
  	}
  	if(jsonString.length == 1)return '{}';
  	jsonString = jsonString.substring(0, jsonString.length - 1);
  	jsonString += '}';
	return jsonString;
}

function createJSONFromArrayOfDictionaries(arrayOfDictionaries){
	
	var jsonString = '[';
	for(var index in arrayOfDictionaries) {
		var dictionary =  arrayOfDictionaries[index];
		jsonString = jsonString + createJSONFromDictionary(dictionary) +',';
  	}
  	if(jsonString.length == 1)return '[]';
  	jsonString = jsonString.substring(0, jsonString.length - 1);
  	jsonString += ']';
  	
	return jsonString;
}

function isUndefined(value) {
    return typeof value === 'undefined';
}

function isValidJSON(aJsonString){
	try{
		JSON.parse(field);
	}catch(e){
		//alert(e);
		return false;
	}
	return true;
}

function jsonEscape(str){
    //return str.replace(/\n/g, "\\\\n").replace(/\r/g, "\\\\r").replace(/\t/g, "\\\\t");
    if(!str)return '[]';
    //return str.replace(/\n/g, '\\n').replace(/\r/g, '\\r').replace(/\t/g, '\\t');//.replace(/\\/g, '<br>');//This works with all but dictionaries for reagents
    return str.replace(/\n/g, '\\n').replace(/\r/g, '\\r').replace(/\t/g, '\\t');//.replace(/\\/g, '<br>');
}

function comillasEscape(str){
	return str.replace(/\"/g, '\\"');
}

function utfToHtml(str){
    //return str.replace(/\n/g, "\\\\n").replace(/\r/g, "\\\\r").replace(/\t/g, "\\\\t");
    if(!str)return '';
    return str.replace(/\n/g, '<br>').replace(/\r/g, '<br>');
}

function dataPayload(dictionary){
	var userId =getCookie('USER_ID');
	var linker =getCookie('USER_USER_GROUP_ID');
	var group =getCookie('USER_GROUP_ID');
	var payload = 'data={"groupId":"'+group+'","perPersonId":"'+userId+'","createdBy":"'+linker+'",';
	for(var index in dictionary) {
		var field =  dictionary[index];
		if(field == false){
				//if(field.indexOf('')>-1)
				field = "0";	
			}
		if(field == true){
				field = "1";	
		}
		
		if(field != null && typeof field !== 'undefined'){
			field = field.toString();
			//alert(index + ' ' + field);
			if(field.indexOf('\n') > -1 || field.indexOf('\r') > -1){
				field = field.replace(/(\n|\r)/g, '\\n');
			}
			if(field.indexOf('\"') > -1){
				field = field.replace(/"/g, '\\\"');
			}
			if(field.indexOf("\'") > -1){
				field = field.replace(/"/g, "\\\'");
			}
			if(isValidJSON(field)){
				//alert(field);
			}
		}
		if(field){
			field = encodeURIComponent(field);///
			payload += '\"'+index+'\":\"'+field+'\",';
		}
  	}
  	payload = payload.substring(0, payload.length - 1);
  	payload += '}';
//   	console.log(payload);
	return payload;
}

function checkRequired(dictionary, requiredArray){
	for(var index in requiredArray) {
		var field = requiredArray[index];
		if(dictionary[field] == null){
			//alert(index+ ' '+field+' '+dictionary[field]+' false');
			alert('Check missing fields');
			return false;
		}
  	}
  	return true;
}

function checkRequiredNoAlert(dictionary, requiredArray){
	for(var index in requiredArray) {
		var field = requiredArray[index];
		if(dictionary[field] == null){
			return false;
		}
  	}
  	return true;
}



function addWarningOfType(type, message){
	var node = document.getElementById('messages');
	var warning = document.createElement("div");
	
	var text = document.createTextNode(message);
	warning.appendChild(text);
	
	var button = document.createElement('button');
	button.setAttribute('type', 'button');
	button.setAttribute('class', 'close');
	button.setAttribute('data-dismiss', 'alert');
	button.setAttribute('aria-label', 'Close');
	
	var span = document.createElement('span');
	span.setAttribute('aria-hidden', 'true');
	var x = document.createTextNode('\u00D7');
	span.appendChild(x);
	button.appendChild(span);
	
	warning.appendChild(button);
	warning.setAttribute('class', 'alert alert-'+type+' alert-dismissible fade in');
	warning.setAttribute('role', 'alert');
	var num = Math.round(Math.random()*100) + 1;
	warning.setAttribute('id', 'war'+num);	
	
	setTimeout(function(){
		$("#war"+num).fadeOut("slow");
		//warning.parentNode.removeChild(warning);
	},2000);
	
	node.appendChild(warning);
	
/*
	$(".alert-dismissable").fadeTo(2000, 500).slideUp(500, function(){
    	$(".alert-dismissable").alert('close');
	});
*/
}

function createApi(apiSuffix, payload, $http, addToarray, pk, callback){
	var message = 'You successfully ';
	if(payload[pk] != null){
		apiSuffix = apiSuffix.concat('Update');
		message= message + 'updated this object';
	}else{
		message= message + ' entered a new registry';
		payload.createdAt = iOSLikeDate();
	}
	//console.log(dataPayload(payload)+'&'+dataCrud());
	$http({method: 'POST',
    	data: dataPayload(payload)+'&'+dataCrud(),
    	headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    	//headers: {'Content-Type': 'application/json'},
		url: '/apiLabPad/api/'+apiSuffix}).success(function(data, status, headers, config) {  
			if(data == 0 || data.indexOf('0')==0){
				addWarningOfType('danger', 'There was an error processing your request.');
				return;
			}    		
      		if(payload[pk] == null){
	      		payload[pk] = data;//This line new
	      		if(addToarray)addToarray.push(payload);
      		}else{
	      		for(i in addToarray){
		      		if(addToarray[i][pk] == payload[pk]){
			      		addToarray[i] = payload;
		      		}
	      		}
      		}
      		if(callback)callback();
      		addWarningOfType('success', message);	      		      		
          }).error(function(data, status, headers, config) {
			addWarningOfType('danger', 'There was an error processing your request.');	
    });
}

function deleteApi(apiPrefix, payload, $http, removeFromArray, pk, callback){
	var message = 'You successfully deleted this object';
	console.log(dataPayload(payload)+'&'+dataCrud());
	$http({method: 'POST',
    	data: dataPayload(payload)+'&'+dataCrud(),
    	headers: {'Content-Type': 'application/x-www-form-urlencoded'},
		url: '/apiLabPad/api/'+apiPrefix+'Delete'}).success(function(data, status, headers, config) {
      		
      		if(removeFromArray){
	      		for(var i in removeFromArray){
		      		var objectToAnalyze = removeFromArray[i];
		      		if(parseInt(objectToAnalyze[pk]) == parseInt(payload[pk])){
			      		removeFromArray.splice(i, 1);
			      		break;
		      		}
	      		}
      		}
      		if(callback)callback();
      		addWarningOfType('info', message);	
      		      		
          }).error(function(data, status, headers, config) {

			addWarningOfType('danger', 'There was an error processing your request.');	
    });
}


function findByAttributeValue(xmlDoc, tag, attribute, value)
{
  var returnable = [];
   
  var allElements = xmlDoc.getElementsByTagName(tag);
  for (var i = 0; i < allElements.length; i++)
   {
    if (allElements[i].getAttribute(attribute) == value)
    {
    returnable.push(allElements[i]);
      
    }
  }
  return returnable;
}

function getCurrentDateJS(){
	var a = new Date();
	return a.toString("yyyy-MM-dd HH:mm:ss");
}

function getDateIOSFormat(date){
	var dateNew = date.toString("yyyy-MM-dd HH:mm:ss");
	return dateNew+' 0000';
}

function iOSLikeDate(){
	var theDate = new Date();
	var isoS = theDate.toISOString();
	var inter = isoS.replace('T', ' ');
	var finalStr = inter.substr(0, 19);
	return finalStr+' 0000';
}

function getDateFromIOSFormat(date){
	return date.substring(0, 18)
}

function findObjectsInArrayWithIdInField(array, id, field){
	var found = [];
	for(var i in array){
		if(parseInt(array[i][field]) == parseInt(id)){
			found.push(array[i]);
		}
	}

	return found;
}

function findObjectsInArrayWithValueInField(array, value, field){
	
	var found = [];
	for(var i in array){
		if(array[i][field]== value){
			found.push(array[i]);
		}
	}
	return found;
}

function findFirstObjectInArrayWithValueInField(array, value, field){
	
	for(var i in array){
		if(array[i][field]== value){
			return array[i];
		}
	}
	return null;
}

function fileURL(fileId, $http, $sce, listFiles){
	var array = findObjectsInArrayWithIdInField(listFiles, fileId, 'filFileId');
    if(array.length > 0){
	    var file = array[0];
	    
	    if(file.fileURL){
			return $sce.trustAsResourceUrl(file.fileURL);	
		}else{
			if(!file.fileFetch){
				getFileData(file, $http);
				file['fileFetch'] = 'true';	
			}
			//return 'https://airlabfiles.storage.googleapis.com/temp/'+file.filHash.replace('_', '/')+'.'+file.filExtension;
			return '';//'pictures/loader.gif';
		}
	}
	return false;
}

function getFileData(file, $http){
	//If using temp file system. Will create file in temp that is public and get the url to the file
	$http({method: 'POST',
    	data: dataCrud(),
    	headers: {'Content-Type': 'application/x-www-form-urlencoded'},
		url: '/apiLabPad/api/serveFileURL/'+file.filFileId}).success(function(data, status, headers, config) {
      		file['fileURL'] = data;
      		file['fileFetch'] = null;
      		console.log('downloaded data: '+data);
          }).error(function(data, status, headers, config) {
          	console.log('failed getting file data');
    });	
}

function getFileServingURL(file){
	//GAE will serve the file. In a different URL actually, but gets redirected in server
	var userId =getCookie('USER_ID');
	var linker =getCookie('USER_USER_GROUP_ID');
	var group =getCookie('USER_GROUP_ID');
	var token =getCookie('TOKEN_PUBLIC_KEY');
	var url = '/apiLabPad/api/serveFileGet/'+linker+'-'+userId+'-'+group+'-'+token+'-400x400-'+file.filHash+'.'+file.filExtension;//Important to keep this in check
    return url;	
}

function base64encode(binary) {
    return btoa(unescape(encodeURIComponent(binary)));
}

function getFileForCanvas(file, $http){

	function loadCanvas(theBinary) {
		var base64encoded = 'data:image/png;base64,'+base64encode(theBinary);		
		
        var canvas = document.getElementById('canvas'+file);
	    if(canvas){        
        var context = canvas.getContext('2d');
		 	var imageObj = new Image();
		 	imageObj.onload = function() {
		 		alert('hola');
		 		context.drawImage(this, 0, 0);
        	};   
	    }
        imageObj.src = base64encoded;
      }

					
      var request = new XMLHttpRequest();
      request.open('POST', '/apiLabPad/api/serveFile/'+file, true);
      request.onreadystatechange = function() {
        // Makes sure the document is ready to parse.
        if(request.readyState == 4) {
          // Makes sure it's found the file.
          if(request.status == 200) {
			  loadCanvas(request.responseText);
          }
        }
      };
      request.send(dataCrud());    
}

function makeHash(lengthHash){
    var text = "";
    var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    for( var i=0; i < lengthHash; i++ )
        text += possible.charAt(Math.floor(Math.random() * possible.length));

    return text;
}

function countArray(array){
	var count = 0;
	for(var index in array){
		count++;
	}
	return count;
}

function getExtensionFromFilename(filename){
	var a = filename.split(".");
	if( a.length === 1 || ( a[0] === "" && a.length === 2 ) ) {
    	return "";
	}
	return a.pop();
}


function genericError(){
	
	alert('There was an error');
}

function redoArrayToCommaString(array){
	var str = '';
    for(var i in array){
	    str = str + array[i] + ',';
    }
    if(str.length > 1)str = str.substring(0, str.length-1);
    return str;
}

function reorderAnInstanceFromAReagent(instance, $http, AllData){
	var retVal = prompt("Enter the purpose for this reagent's re-order request : ");
		if(retVal){
			var newReagent = angular.copy(instance);
			newReagent.reiReagentInstanceId = null;
			newReagent.reiStatus = 'requested';
			newReagent.reiPurpose = retVal;
			newReagent.tubFinishedBy = '0';
			newReagent.tubIsLow = '0';
			newReagent.tubPlaceId = '0';
			newReagent.lotNumber = 'Pending';
			newReagent.reiRequestedBy = getCookie('USER_USER_GROUP_ID');
			newReagent.reiRequestedAt = iOSLikeDate();
			newReagent.reiApprovedBy = null;
			newReagent.reiApprovedAt = null;
			newReagent.reiOrderedBy = null;
			newReagent.reiOrderedAt = null;
			newReagent.reiReceivedBy = null;
			newReagent.reiReceivedAt = null;
			newReagent.tubPlaceId = null;
			newReagent.tubFinishedBy = null;
			newReagent.tubIsLow = null;
			createApi('lot', newReagent, $http, AllData.reagentInstancesList, 'reiReagentInstanceId');
		}
}

function loadModalIntoDivWithIdAndTemplateInModalsFolder(idDiv, template){
		var request = new XMLHttpRequest();
    request.open("GET", "web/modals/"+template, false);
    request.send(null);
    var returnValue = request.responseText;
	$("#"+idDiv).html(returnValue);
}

function openModal(idModal){

	$('#'+idModal).on('shown.bs.modal', function () {
	    
	});
	
	$('#'+idModal).modal({
	        show: true
	});
}

function closeModal(idModal){
	$('#'+idModal).modal('hide');
}

function sleep(milliseconds) {
  var start = new Date().getTime();
  for (var i = 0; i < 1e7; i++) {
    if ((new Date().getTime() - start) > milliseconds){
      break;
    }
  }
}

function convertIOSTypeDateToUnix(iOSTypeDat){
	if(iOSTypeDat == null)return;
	if(iOSTypeDat.length < 19)return;
	return moment(iOSTypeDat.substr(0, 19)).valueOf();
}
