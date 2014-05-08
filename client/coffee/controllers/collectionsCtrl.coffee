root = this;


root.controllers.controller('collectionsCtrl', ['$scope', '$routeParams', '$http', ($scope, $routeParams, $http) ->
   $scope.server = $routeParams.server
   $scope.database = $routeParams.database
   $scope.collections = []
   $http.get("/api/#{ $routeParams.server }/#{ $routeParams.database }/collections").then((res) ->
        $scope.collections = res.data
    )
    
])