
hasIndex = (keyName, indexes) ->
    for index in indexes
        if _.indexOf(index.keys, keyName) != -1
            return true
    return false

hasUniqueIndex = (keyName, indexes) ->
    for index in indexes
        if _.indexOf(index.keys, keyName) != -1
            return index.unique
    return false

hasIndexAsc = (keyName, indexes) ->
    hasIndex(keyName, indexes)

hasIndexDesc = (keyName, indexes) ->
    hasIndex("-#{keyName}", indexes)


has2dIndex = (keyName, indexes) ->
    hasIndex("$2dsphere:#{keyName}", indexes)

getStatsUrl = (keyName, routeParams)->
    r = routeParams
    ret = "#/#{r.server}/#{r.database}/#{r.collection}/stats/#{ keyName }"
    if r.query
        ret = "#{ ret }/query/#{ r.query }"
    else if r.pipeline
        ret = "#{ret}/pipeline/#{r.pipeline}"
    return ret

directive = () ->
    directive =
        templateUrl: "/partials/directives/key.html"
        replace: true,
        transclude: false,
        restrict: 'E',
        scope:
            keyName: "="
            value: "="
            indexes: "="
        controller:["$scope", "$routeParams", ($scope, $routeParams) ->
                $scope.indexes = $scope.indexes or []
                $scope.canMakeHistogram = _.isNumber($scope.value)
                $scope.statsUrl = getStatsUrl($scope.keyName, $routeParams)
                $scope.hasIndexDesc = hasIndexDesc($scope.keyName, $scope.indexes)
                $scope.hasIndexAsc = hasIndexAsc($scope.keyName, $scope.indexes)
                $scope.isIndexUnique = hasUniqueIndex($scope.keyName, $scope.indexes)
                $scope.has2DIndex = has2dIndex($scope.keyName, $scope.indexes)
                $scope.showTools = false
                $scope.hasIndex = $scope.hasIndexDown or $scope.hasIndexUp or $scope.has2DIndex
                $scope.getGeoJsonUrl = () ->
                    r = $routeParams
                    e = window.encodeURIComponent
                    url = "#/#{r.server}/#{r.database}/#{r.collection}/idx/#{r.idx}"
                    if r.query
                        url = "#{url}/query/#{e(r.query)}"
                    return "#{url}/geojson/#{$scope.keyName}"
            ]
    return directive

directives.directive( "vulKey", [directive])
