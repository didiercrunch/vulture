
root = this;

angular.module('vulture', [
  'ngRoute'
  'leaflet-directive'
  'vulture.filters'
  'vulture.services'
  'vulture.directives'
  'vulture.controllers'
]).
config(['$routeProvider', ($routeProvider) ->
  $routeProvider.when('/servers', {templateUrl: 'partials/servers.html', controller: 'serversCtrl'})
  $routeProvider.when('/about', {templateUrl: 'partials/about.html', controller: 'aboutCtrl'})
  $routeProvider.when('/:server/databases', {templateUrl: 'partials/databases.html', controller: 'databasesCtrl'})
  $routeProvider.when('/:server/:database/collections', {templateUrl: 'partials/collections.html', controller: 'collectionsCtrl'})
  $routeProvider.when('/:server/:database/:collection/idx/:idx', {templateUrl: 'partials/document.html', controller: 'documentCtrl'})
  $routeProvider.when('/:server/:database/:collection/idx/:idx/query/:query', {templateUrl: 'partials/document.html', controller: 'documentCtrl'})
  $routeProvider.when('/:server/:database/:collection/idx/:idx/geojson/:key', {templateUrl: 'partials/geojsonmap.html', controller: 'geojsonmapCtrl'})
  $routeProvider.when('/:server/:database/:collection/idx/:idx/query/:query/geojson/:key', {templateUrl: 'partials/geojsonmap.html', controller: 'geojsonmapCtrl'})
  
  $routeProvider.otherwise({redirectTo: '/servers'})
])

root.filters = angular.module('vulture.filters', [])
root.services = angular.module('vulture.services', [])
root.directives = angular.module('vulture.directives', [])
root.controllers = angular.module('vulture.controllers', [])

