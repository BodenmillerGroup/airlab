angular.module('Papers', ['ngRoute', 'Getters'])
 
.config(function($routeProvider) {
  $routeProvider
    .when('/my_papers', {
      controller:'PapersCtrl',
      templateUrl:'web/papers.html'
    })
    .when('/papers_lab', {
      controller:'LabPapersCtrl',
      templateUrl:'web/papers_lab.html'
    })
    .when('/pubmed_search', {
      controller:'PubmedCtrl',
      templateUrl:'web/pubmed_search.html'
    })
    .otherwise({
      redirectTo:'/'
    });
})
 
.controller('PapersCtrl', function($scope, $http, $window, AllData, AllGetters) {
   
    $scope.sort = null;
    $scope.baseData = AllData;
    AllData.getAllScientificArticlesForPerson(true);
    $scope.showAbstract = function(paper){
	    paper.showAbstract = true;
    }
    $scope.hideAbstract = function(paper){
	    paper.showAbstract = null;
    }  
    $scope.erasePaper = function(paper){
	    var r = confirm("Are you sure?");
		if (r == true) {
			deleteApi('scientificarticle', angular.copy(paper), $http, $scope.baseData.papersList, 'sciScientificArticleId');
		}
    }  
})

.controller('LabPapersCtrl', function($scope, $http, $window, AllData, AllGetters) {
   
    $scope.sort = null;
    $scope.baseData = AllData;
    AllData.getAllScientificArticlesForGroup(true);
    $scope.showAbstract = function(paper){
	    paper.showAbstract = true;
    } 
    $scope.hideAbstract = function(paper){
	    paper.showAbstract = null;
    }
    $scope.erasePaper = function(paper){
	    var r = confirm("Are you sure?");
		if (r == true) {
			deleteApi('scientificarticle', angular.copy(paper), $http, $scope.baseData.papersLabList, 'sciScientificArticleId');
		}
    }          
})

.controller('PubmedCtrl', function($scope, $http, $window) {
   
    $scope.search_box = '';
    $scope.dataObtained = '';
    $scope.papersList = [];
    $scope.queryKey = '';
    $scope.webEnv = '';
    
    $scope.getAbstract = function(aPaper){
	    //Now get abstract
			var url = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id='+aPaper.sciPubmedID+'&WebEnv='+$scope.webEnv+'&query_key='+$scope.queryKey+'&retmode=xml';
			$http({method: 'GET', 
								url: url}).success(function(data, status, headers, config) {
								//alert(dataB);
							if(data == 0){
								$scope.errorMessage();
							}else{
								$scope.dataObtained = data;
								parser=new DOMParser();
								xmlDoc=parser.parseFromString(data,"text/xml");
								var abstract = xmlDoc.getElementsByTagName('AbstractText');
								aPaper.sciAbstract = abstract[0].childNodes[0].nodeValue;
						
							}
      			
						}).error(function(data, status, headers, config) {
							$scope.errorMessage();  
			  
						});
    }
    
    $scope.showAbstract = function(paper){
	    paper.showAbstract = true;
    }
    $scope.hideAbstract = function(paper){
	    paper.showAbstract = null;
    }    
       
    $scope.getSummaries = function(data){
   	  $scope.dataObtained = data;
	  if (window.DOMParser)
	  	{
		  	parser=new DOMParser();
		  	xmlDoc=parser.parseFromString(data,"text/xml");
		  	var array = xmlDoc.getElementsByTagName('Id');
		  	$scope.webEnv = xmlDoc.getElementsByTagName('WebEnv')[0].childNodes[0].nodeValue;
		  	$scope.queryKey = xmlDoc.getElementsByTagName('QueryKey')[0].childNodes[0].nodeValue;
		  	for(var i = 0; i<array.length; i++){
		  		var url = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&term=&id='+array[i].childNodes[0].nodeValue;
				$http({method: 'GET', 
					url: url}).success(function(dataB, statusB, headersB, configB) {
					//alert(dataB);
					if(dataB == 0){
		    			$scope.errorMessage();
					}else{
						parserB=new DOMParser();
						xmlDocB=parserB.parseFromString(dataB,"text/xml");
						
						var aPaper = {};
						var title = findByAttributeValue(xmlDocB, "Item", "Name", "Title");
						var pubDate = findByAttributeValue(xmlDocB, "Item", "Name", "PubDate");
						var source = findByAttributeValue(xmlDocB, "Item", "Name", "FullJournalName");
						var authors = findByAttributeValue(xmlDocB, "Item", "Name", "Author");
						var title = findByAttributeValue(xmlDocB, "Item", "Name", "Title");
						var pubmedID = findByAttributeValue(xmlDocB, "Item", "Name", "pubmed");
						
						aPaper.sciTitle = title[0].childNodes[0].nodeValue;
						aPaper.sciPubDate = pubDate[0].childNodes[0].nodeValue;
						aPaper.sciSource = source[0].childNodes[0].nodeValue;
						var merged = '';
						for(var node in authors){
							merged = merged + authors[node].childNodes[0].nodeValue + ', ';
						}
						aPaper.sciAuthors = merged;
						aPaper.sciPubmedID = pubmedID[0].childNodes[0].nodeValue;
						
						$scope.papersList.push(aPaper);
						
						$scope.getAbstract(aPaper);
					}
      			
				}).error(function(data, status, headers, config) {
					$scope.errorMessage();  
			  
				}); 	
		  	}
		  	//alert(array[0].childNodes[0].nodeValue);
		}
	 else // Internet Explorer
	 {
		 	xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
		 	xmlDoc.async=false;
		 	xmlDoc.loadXML(txt); 
	  }
    };
       
    $scope.clicked = function (searchTerm) {
    	if(typeof searchTerm === 'undefined')return;
    	$http({method: 'GET', 
    		url: 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term='+searchTerm+'&retmax=1000&usehistory=y'}).success(function(data, status, headers, config) {
      		$scope.dataObtained = data;
      		$scope.getSummaries(data);
      		
          }).error(function(data, status, headers, config) {
			  $scope.dataObtained = 'Error';
			  $window.location.href = '#';
		});
	};
	
	$scope.cleanCache = function(){
		$scope.papersList = [];
	}
	
	$scope.add_personal = function(paper){
		createApi('scientificarticle', angular.copy(paper), $http, $scope.papersList, 'sciScientificArticleId');
	}
	$scope.add_lab = function(paper){
		paper.sciLabShared = '1';
		createApi('scientificarticle', angular.copy(paper), $http, $scope.papersList, 'sciScientificArticleId');
	}
	
	$scope.showRefine = function(){
		return $scope.papersList.length>0?1:0;
	}
})