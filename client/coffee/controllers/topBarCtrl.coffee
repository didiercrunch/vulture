root = this;

joinArray = (a, b)->
    a.push.apply(a, b)
    return a

root.controllers.controller('topBarCtrl', ['$scope', '$location', ($scope, $location) ->
    
    $scope.loading = false
    
    $scope.$on('$routeChangeSuccess', (next, current) ->
        $scope.path = _.filter($location.path().split("/"), (s) -> s)
        if $scope.path[5] == "query"
            $scope.path = joinArray($scope.path[0...6], $scope.path[7...-1])
        $scope.getHistoryUrl = (idx) ->
            ret = "#/" + ($scope.path[i] for i in [0...idx]).join("/")
            if _.indexOf(["idx", "geojson", "query", "_id", "field", "all"], $scope.path[idx]) != -1
                return ""
            if idx == 0
                ret += "servers"
            else if idx == 1
                ret += "/databases"
            else if idx == 2
                ret += "/collections"
            else if idx == 4
                ret += "/#{ $scope.path[4] }"
            return ret
    )
    $scope.$on "loading", ()->
        $scope.loading = true
    
    $scope.$on "loadingFinished", ()->
        $scope.loading = false
 ])