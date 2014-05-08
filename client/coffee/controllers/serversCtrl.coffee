root = this;


root.controllers.controller('serversCtrl', ['$scope', '$http', ($scope, $http) ->
    $scope.servers = []
    $http.get("/api/servers").then((res) ->
        $scope.servers = res.data
    )
    
])