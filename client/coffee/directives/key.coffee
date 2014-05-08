
directive = () ->
    directive = 
        templateUrl: "/partials/directives/key.html"
        replace: true,
        transclude: false,
        restrict: 'E',
        scope:
            value: "="
        controller:["$scope", ($scope) ->
                $scope.hasIndexDown = false
                $scope.hasIndexUp = false
                $scope.hasIndex = false
                $scope.has2DIndexUp = false
            ]
    return directive
                        
directives.directive( "vulKey", [directive])
