root = this;


root.controllers.controller('collectionsCtrl', ['$scope', '$routeParams', '$rootScope', 'util', ($scope, $routeParams, $rootScope, util) ->
   $scope.server = $routeParams.server
   $scope.database = $routeParams.database
   $scope.collections = []
   $rootScope.$broadcast("loading")
   util.get("/api/#{ $routeParams.server }/#{ $routeParams.database }/collections").then((res) ->
        $scope.collections = res.data
    )
    
])