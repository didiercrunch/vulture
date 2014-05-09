root = this;


root.controllers.controller('geojsonmapCtrl', ['$scope', '$routeParams', '$http', ($scope, $routeParams, $http) ->
    $scope.geojson = {}
    $scope.geojsonData = {}
    $scope.idx = Number($routeParams.idx)
    $scope.center =  # experimental point around Québec
        lat: 46.1227
        lng: -72.6169
        zoom: 7
        
    url  = "/api/#{ $routeParams.server }/#{ $routeParams.database }/#{ $routeParams.collection }"
    if $routeParams.query
        url = "#{url}/query/#{$routeParams.query}"
    url = "#{ url }/idx/#{$routeParams.idx - 1}"
    $http.get(url).then((res) ->
        $scope.geojson = res.data.document[$routeParams.key]
        if not $scope.geojson.properties
            $scope.geojson.properties = {}
        $scope.geojson.properties["_vulture_url_link"] = ""
        $scope.meta = res.data.meta
        $scope.geojsonData =
            data: $scope.geojson 
            style: undefined
            resetStyleOnMouseout: true
    )
    
    $scope.previousDocumentUrl = () ->
        url = "#/#{ $routeParams.server }/#{ $routeParams.database }/#{ $routeParams.collection }/idx/#{$scope.idx - 1}"
        if $routeParams.query
            url = "#{url}/query/#{$routeParams.query}"
        "#{url}/geojson/#{$routeParams.key}"

    $scope.nextDocumentUrl = () ->
        url = "#/#{ $routeParams.server }/#{ $routeParams.database }/#{ $routeParams.collection }/idx/#{$scope.idx + 1}"
        if $routeParams.query
            url = "#{url}/query/#{$routeParams.query}"
        "#{url}/geojson/#{$routeParams.key}"

    $scope.hasPreviousDocument = () ->
        $scope.idx > 1
    
    $scope.$on "leafletDirectiveMap.geojsonClick", (ev, featureSelected, leafletEvent) ->
        a = 90
        b = 89
            
])

