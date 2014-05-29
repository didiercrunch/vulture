root = this;


root.controllers.controller('documentCtrl', ['$scope', '$routeParams', '$location', 'util', ($scope, $routeParams, $location, util) ->
    $scope.idx = $routeParams.idx
    $scope.doc = {}
    $scope.idx = Number($routeParams.idx) or 1
    $scope.meta = {}
    $scope.query = $routeParams.query or ""
    $scope.notfound = false
    $scope.error = ""
    $scope.codeMirrorOptions =
        lineWrapping : true
        lineNumbers: true
        mode: 'text/typescript'
    
    url  = "/api/#{ $routeParams.server }/#{ $routeParams.database }/#{ $routeParams.collection }"
    if $routeParams.query
        url = "#{url}/query/#{$routeParams.query}"
    if $routeParams.idx
        url = "#{ url }/idx/#{$routeParams.idx - 1}"
    else if $routeParams.id
        url = "#{ url }/_id/#{$routeParams.id}"
    $scope.raw_url = url
    util.get(url).then((res) ->
         $scope.doc = res.data.document
         $scope.meta = res.data.meta
         $scope.enlapsed_time = res.data.enlapsed_time
    ).catch( (res) ->
        if res.data.error == "not found"
            $scope.notfound = true
        else
            $scope.error = res.data.error
    )
    
    $scope.search = (query) ->
        if query == ""
            return ""
        $location.path "/#{ $routeParams.server }/#{ $routeParams.database }/#{ $routeParams.collection }/idx/1/query/#{query}"
    
    $scope.previousDocumentUrl = () ->
        url = "#/#{ $routeParams.server }/#{ $routeParams.database }/#{ $routeParams.collection }/idx/#{$scope.idx - 1}"
        if $routeParams.query
            url = "#{url}/query/#{$routeParams.query}"
        return url

    $scope.nextDocumentUrl = () ->
        url = "#/#{ $routeParams.server }/#{ $routeParams.database }/#{ $routeParams.collection }/idx/#{$scope.idx + 1}"
        if $routeParams.query
            url = "#{url}/query/#{$routeParams.query}"
        return url

    $scope.hasPreviousDocument = () ->
        $scope.idx > 1
])

