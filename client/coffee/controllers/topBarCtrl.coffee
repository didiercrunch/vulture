root = this;

root.controllers.controller('topBarCtrl', ['$scope', '$location', ($scope, $location) ->
    $scope.$on('$routeChangeSuccess', (next, current) ->
        $scope.path = _.filter($location.path().split("/"), (s) -> s)
        if $scope.path[5] == "query"
            $scope.path = $scope.path[0...-1]
        $scope.getHistoryUrl = (idx) ->
            ret = "#/" + ($scope.path[i] for i in [0...idx]).join("/")
            if _.indexOf(["idx", "geojson"], $scope.path[idx]) != -1
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
 ])