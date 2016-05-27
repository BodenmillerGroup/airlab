angular.module('searchFilters', [])

.filter('proteinFilter', function() {
  return function (items, search, proteins) {
    	alert(search);
  };
});