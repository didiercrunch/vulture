root = this;
mapCenter =
    lat: 46.1227
    lng: -72.6169
    zoom: 7

getSingleDataUrl = (routeParams) ->
    url = "/api/#{ routeParams.server }/#{ routeParams.database }/#{ routeParams.collection }"
    if routeParams.query
        url = "#{url}/query/#{ routeParams.query }" 
    return "#{ url }/idx/#{ Number(routeParams.idx) - 1 }"

getAllDataUrl = (routeParams) ->
    url = "/api/#{ routeParams.server }/#{ routeParams.database }/#{ routeParams.collection }"
    if routeParams.query
        url = "#{url}/query/#{ routeParams.query }" 
    return "#{ url }/all"

getDocumentUrl = (routeParams, id) ->
    return "/#{ routeParams.server }/#{ routeParams.database }/#{ routeParams.collection }/_id/#{ id }"

transformListOfGeoJsonToGeometryCollection = (resData, routeParams) ->
    ret =
        type: "GeometryCollection"
        geometries: []
    for doc in resData.document
        geojson = doc[routeParams.key]
        if not geojson.properties
            geojson.properties = {}
        geojson.properties["_vulture_url_link"] = getDocumentUrl(routeParams, doc._id)
        ret.geometries.push(geojson)
    return ret
    

root.controllers.controller('geojsonmapCtrl', ['$scope', '$routeParams', '$location', '$http', ($scope, $routeParams, $location, $http) ->
    $scope.geojson = {}
    $scope.geojsonData = {}
    $scope.idx = Number($routeParams.idx)
    $scope.center = mapCenter
    
    $scope.getAggredatedUrl = () ->
        url = "#/#{ $routeParams.server }/#{ $routeParams.database }/#{ $routeParams.collection }/idx/all"
        if $routeParams.query
            url = "#{url}/query/#{$routeParams.query}"
        "#{url}/geojson/#{$routeParams.key}"
        

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
        $location.url(featureSelected.properties._vulture_url_link);
    
    $scope.initSingleDocument = ()->
        url = getSingleDataUrl($routeParams)
        $http.get(url).then (res) ->
            geojson = res.data.document[$routeParams.key]
            if not geojson.properties
                geojson.properties = {}
            geojson.properties["_vulture_url_link"] = getDocumentUrl($routeParams, res.data.document._id)
            $scope.meta = res.data.meta
            $scope.geojsonData =
                data: geojson
                style: undefined
                resetStyleOnMouseout: true

    $scope.initAllDocuments = () ->
        url = getAllDataUrl($routeParams)
        $http.get(url).then (res) ->
            $scope.meta = res.data.meta
            $scope.geojsonData =
                data: transformListOfGeoJsonToGeometryCollection(res.data, $routeParams)
                style: undefined
                resetStyleOnMouseout: true
    
    if $routeParams.idx
        $scope.mode = 'single_document'
        $scope.initSingleDocument()
    else
        $scope.mode = 'all'
        $scope.initAllDocuments()
])

