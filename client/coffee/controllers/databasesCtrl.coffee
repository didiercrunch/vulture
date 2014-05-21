root = this;


root.controllers.controller('databasesCtrl', ['$scope', '$routeParams', 'util', ($scope, $routeParams, util) ->
    $scope.server = $routeParams.server
    $scope.databases = []
    util.get("/api/#{ $routeParams.server }/databases").then((res) ->
        $scope.databases = res.data
    )
    
])