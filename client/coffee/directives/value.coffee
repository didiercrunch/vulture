
directive = () ->
    directive =
        templateUrl: "/partials/directives/value.html"
        replace: true,
        transclude: false,
        restrict: 'E',
        scope:
            value: "="
            docId: "="
            key: "="
            expended: "="
        controller:["$scope", "$routeParams", "util", ($scope, $routeParams, util) ->
                $scope.isSmallString = (str)->
                    if not _.isString(str)
                        return false
                    rgx = str.match(/\n/g) or []
                    return str.length < 1000 and rgx.length < 20

                $scope.isSmallObject = (obj) ->
                    return $scope.isSmallString(JSON.stringify(obj, null, 4))

                $scope.getSmallPrefix = (str) ->
                    if _.isString(str)
                        return str.substr(0, 500) + "..."
                    return ""
                $scope.url = ()->
                    rp = $routeParams
                    s = $scope
                    return "#/#{rp.server}/#{rp.database}/#{rp.collection}/_id/#{s.docId}/field/#{s.key}"
                $scope.isObjectId = (val) ->
                    objectIdRegexp =  /^[01234567890abcdef]{24}$/
                    _.isString(val) and objectIdRegexp.test(val)

                $scope.getDateFromObjectId = (objectId) ->
                    util.parseObjectId(objectId).date.toISOString()

                $scope.valueLength = if _.isObject($scope.value) then _.keys($scope.value).length else $scope.value.length

                $scope.isObjectId = $scope.isObjectId($scope.value)
                $scope.isString = not $scope.isObjectId and _.isString($scope.value)
                $scope.isNumber = _.isNumber($scope.value)
                $scope.isObject = _.isObject($scope.value)
                $scope.isArray = _.isArray($scope.value)
                $scope.isBoolean = _.isBoolean($scope.value)
            ]
    return directive

directives.directive( "vulValue", [directive])
