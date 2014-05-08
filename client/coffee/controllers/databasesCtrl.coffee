root = this;


root.controllers.controller('databasesCtrl', ['$scope', '$routeParams', '$http', ($scope, $routeParams, $http) ->
    $scope.server = $routeParams.server
    $scope.databases = []
    $http.get("/api/#{ $routeParams.server }/databases").then((res) ->
        $scope.databases = res.data
    )
    
])