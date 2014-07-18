root = this;



defaultMapCenter =
    lat: 46.1227
    lng: -72.6169
    zoom: 7

getLocalStorageMapCenter = () ->
    JSON.parse(localStorage.getItem("mapCenter")) or defaultMapCenter

getInitialCenter = (loc) ->
    if loc
        loc = (Number(x) for x in loc.split(","))
        if loc.length != 3
            return getLocalStorageMapCenter()
        ret =
            lat: loc[0]
            lng: loc[1]
            zoom: loc[2]
        return ret
    return getLocalStorageMapCenter()
        
    



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
        type: "FeatureCollection"
        features: []
    for doc in resData.document
        geojson = doc[routeParams.key]
        if not geojson.properties
            geojson.properties = {}
        geojson.properties["_vulture_url_link"] = getDocumentUrl(routeParams, doc._id)
        feature =
            type: "Feature"
            geometry: geojson,
            properties: geojson.properties
        ret.features.push(feature)
    return ret
    

root.controllers.controller('geojsonmapCtrl', ['$scope', '$routeParams', '$location', 'util', ($scope, $routeParams, $location, util) ->
    $scope.geojson = {}
    $scope.geojsonData = {}
    $scope.idx = Number($routeParams.idx)
    $scope.center = getInitialCenter($routeParams.loc)
    $scope.queryObject = $routeParams.query or "{}"
    
    $scope.$watch 'center', () ->
        localStorage.setItem("mapCenter", JSON.stringify($scope.center))
    
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
        
    $scope.setStyleOnFeature = (feature, element) ->
        if feature.properties and feature.properties.style
            element.setStyle(feature.properties.style)
    
    $scope.initSingleDocument = ()->
        url = getSingleDataUrl($routeParams)
        util.get(url).then (res) ->
            geojson = res.data.document[$routeParams.key]
            if not geojson.properties
                geojson.properties = {}
            geojson.properties["_vulture_url_link"] = getDocumentUrl($routeParams, res.data.document._id)
            $scope.meta = res.data.meta
            $scope.geojsonData =
                data: geojson
                style: geojson.properties.style or undefined
                resetStyleOnMouseout: true

    $scope.getGoogleMapLink = () ->
        c = $scope.center
        return "https://www.google.ca/maps/@#{c.lat},#{c.lng},#{c.zoom}z"

    $scope.initAllDocuments = () ->
        url = getAllDataUrl($routeParams)
        util.get(url).then (res) ->
            $scope.meta = res.data.meta
            geojson = transformListOfGeoJsonToGeometryCollection(res.data, $routeParams)
            $scope.geojsonData =
                data: geojson
                onEachFeature: $scope.setStyleOnFeature
                resetStyleOnMouseout: true
    
    if $routeParams.idx
        $scope.mode = 'single_document'
        $scope.initSingleDocument()
    else
        $scope.mode = 'all'
        $scope.initAllDocuments()

    $scope.changeQuery = (query) ->
        if query == ""
            return ""
        r = $routeParams
        $location.path "/#{ r.server }/#{ r.database }/#{ r.collection }/idx/1/query/#{query}/geojson/#{r.key}"
    
    $scope.getUrlWithLocation = () ->
        c = $scope.center
        if $routeParams.loc
            l = $location.absUrl()
            rgx = /\/location\/-?\d{0,3}\.?\d*,-?\d{0,3}\.?\d*,\d+/
            return l.replace(rgx, "/location/#{c.lat},#{c.lng},#{c.zoom}")
        else
            return "#{$location.absUrl()}/location/#{c.lat},#{c.lng},#{c.zoom}"
])

