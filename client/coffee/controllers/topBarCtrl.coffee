root = this;

root.controllers.controller('topBarCtrl', ['$scope', '$location', ($scope, $location) ->
    $scope.$on('$routeChangeSuccess', (next, current) ->
        $scope.path = _.filter($location.path().split("/"), (s) -> s)
        $scope.getHistoryUrl = (idx) ->
            ret = "#/" + ($scope.path[i] for i in [0...idx]).join("/")
            if $scope.path[idx] == "idx"
                return ""
            if idx == 0
                ret += "servers"
            else if idx == 1
                ret += "/databases"
            else if idx == 2
                ret += "/collections"
            return ret
    )
 ])