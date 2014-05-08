
directive = () ->
    directive = 
        templateUrl: "/partials/directives/value.html"
        replace: true,
        transclude: false,
        restrict: 'E',
        scope:
            value: "="
        controller:["$scope", ($scope) ->
                $scope.isString = _.isString($scope.value)
                $scope.isNumber = _.isNumber($scope.value)
                $scope.isObject = _.isObject($scope.value)
                $scope.isArray = _.isArray($scope.value)
            ]
    return directive
                        
directives.directive( "vulValue", [directive])
