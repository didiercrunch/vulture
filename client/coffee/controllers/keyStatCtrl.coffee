root = this;

humanValueOfStatisticalAbreviation =
    mean: "mean"
    std: "standard deviation"
    var: "variance"


root.controllers.controller('keyStatCtrl', ['$scope', '$routeParams', 'util', ($scope, $routeParams, util) ->
    $scope.name = "didier!"
    $scope.stats = []
    
    url  = "/api/#{ $routeParams.server }/#{ $routeParams.database }/#{ $routeParams.collection }"
    url = "#{ url }/stats/#{$routeParams.key}"

    util.get(url).then((res) ->
        for key, val of res.data
            $scope.stats.push({name: humanValueOfStatisticalAbreviation[key], value: val })
    )
    
])

