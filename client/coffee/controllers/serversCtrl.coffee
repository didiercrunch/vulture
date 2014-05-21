root = this;


root.controllers.controller('serversCtrl', ['$scope', 'util', ($scope, util) ->
    $scope.servers = []
    util.get("/api/servers").then((res) ->
        $scope.servers = res.data
    )
    
])