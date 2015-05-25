root = this;


root.controllers.controller('documentCtrl', ['$scope', '$routeParams', '$location', 'util', 'documentCtrlUtil', ($scope, $routeParams, $location, util, documentCtrlUtil) ->

    $scope.initScopeVariables = ->
        $scope.idx = $routeParams.idx
        $scope.doc = {}
        $scope.idx = Number($routeParams.idx) or 1
        $scope.meta = {}
        $scope.query = $routeParams.query or $routeParams.pipeline or ""
        $scope.notfound = false
        $scope.error = ""
        $scope.codeMirrorOptions =
            lineWrapping : true
            lineNumbers: true
            mode: 'text/javascript'

    $scope.init = ->
        $scope.initScopeVariables()
        url  = documentCtrlUtil.getUrl($routeParams)
        $scope.raw_url = url

        if $scope.isDocumentFromPipeline()
            promise = documentCtrlUtil.getPipeline(url, $scope.idx - 1)
        else
            promise = util.get(url)

        promise.then((res) ->
             $scope.doc = res.data.document
             $scope.meta = res.data.meta
             $scope.total = res.data.meta.count + $scope.idx - 1
             $scope.enlapsed_time = res.data.enlapsed_time
        ).catch((res) ->
            $scope.error = res.data.error
        )

    $scope.isDocumentFromPipeline = ->
        return $routeParams.pipeline

    $scope.search = (query) ->
        if query == ""
            return ""
        $location.path "/#{ $routeParams.server }/#{ $routeParams.database }/#{ $routeParams.collection }/idx/1/query/#{query}"

    $scope.executePipeline = (pipeline) ->
        if pipeline == ""
            return
        $location.path "/#{ $routeParams.server }/#{ $routeParams.database }/#{ $routeParams.collection }/idx/1/pipeline/#{pipeline}"

    $scope.previousDocumentUrl = () ->
        return '#' + $location.path().replace(/\/idx\/\d+/, "/idx/#{$scope.idx - 1}")

    $scope.nextDocumentUrl = () ->
        return '#' + $location.path().replace(/\/idx\/\d+/, "/idx/#{$scope.idx + 1}")

    $scope.hasPreviousDocument = () ->
        $scope.idx > 1

    $scope.hasNextDocument = ->
        $scope.total > 0 and $scope.idx < $scope.total

    $scope.init()
])


root = this

root.services.factory('documentCtrlUtil', ['util', (util)->
    service =
        _cache: {}

        getUrl: ($routeParams) ->
            url  = "/api/#{ $routeParams.server }/#{ $routeParams.database }/#{ $routeParams.collection }"
            if $routeParams.query
                url = "#{url}/query/#{$routeParams.query}"
            else if $routeParams.pipeline
                return "#{url}/pipeline/#{$routeParams.pipeline}"

            if $routeParams.idx
                url = "#{ url }/idx/#{$routeParams.idx - 1}"
            else if $routeParams.id
                url = "#{ url }/_id/#{$routeParams.id}"
            return url

        wrapPipelinePromise: (promise, idx) ->
            return promise.then (res) ->
                ret =
                    data:
                        document: res.data.document[idx]
                        meta:
                            count: res.data.document.length - idx
                        enlapsed_time: res.data.enlapsed_time

            return promise

        getPipeline: (url, idx) ->
            if url in _.keys(service._cache)
                return service.wrapPipelinePromise(service._cache[url], idx)
            service._cache[url] = util.get(url)
            return service.getPipeline(url, idx)

    return service

]);
