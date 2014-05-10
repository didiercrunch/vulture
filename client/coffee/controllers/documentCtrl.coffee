root = this;

mongoJsToMongoJSON = (queryString) ->
    ObjectId = (id) ->
        return {"$oid": id}
    
    DBRef = (name, id) ->
        return {"$ref": name, "$id": id}
    
    Timestamp = (t, i) ->
        return {"t": t, "i": i}
    NumberLong = (number) ->
        return { "$numberLong": String(number)}
    MaxKey = { "$maxKey": 1 }
    MinKey = { "$minKey": 1 }
    
    query = ""
    eval("query = " + queryString)
    fixQuery = (query) ->
        if _.isArray(query)
            for v, i in query
                query[i] = fixQuery(v)
            return query
        if _.isRegExp(query)
            options = ""
            for k, option of {multiline: "m", global: "g", ignoreCase: "i"}
                if query[k]
                    options += option
            return { "$regex": query.source, "$options": options }
        if _.isDate(query)
            return { "$date": query.getTime()}
        if query == undefined
            return { "$undefined": true }
        if _.isObject(query)
            for k, v of query
                query[k] = fixQuery(v)
            return query
        return query
    
    return fixQuery(query)

testmongoJsToMongoJSON = () ->
    assertEqual = (a, b) ->
        if not _.isEqual(a, b)
            console.log("error! ", a, " != ", b)
    s = """{a: 89}"""
    assertEqual(mongoJsToMongoJSON(s), {a : 89})
    s = """{a: [1,3,{reg: /allo/gim}]}"""
    assertEqual(mongoJsToMongoJSON(s), {a: [1,3, {reg: { "$regex":"allo", "$options": "mgi" }}]})
    s = """{a: [
                1,
                3,
                {reg:
                    [/allo/gim,
                     new Date("2014-05-08T21:52:24.320Z")
                     ]
                }
                ]
            }"""
    assertEqual(mongoJsToMongoJSON(s), {a: [1,3, {reg: [{ "$regex":"allo", "$options": "mgi" }, {"$date": 1399585944320}]}]})
    

testmongoJsToMongoJSON()

root.controllers.controller('documentCtrl', ['$scope', '$routeParams', '$http', ($scope, $routeParams, $http) ->
    $scope.idx = $routeParams.idx
    $scope.doc = {}
    $scope.idx = Number($routeParams.idx) or 1
    $scope.meta = {}
    $scope.newQuery = $routeParams.query or ""
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

    $http.get(url).then((res) ->
         $scope.doc = res.data.document
         $scope.meta = res.data.meta
    ).catch( (res) ->
        if res.data.error == "not found"
            $scope.notfound = true
        else
            $scope.error = res.data.error
    )
    
    $scope.parseQueryToJSON = (query) ->
        try
            ret = JSON.stringify(mongoJsToMongoJSON(query))
            $scope.error = ""
            return ret
        catch error
            $scope.error
            return ""
    
    $scope.getQueryPath = ()->
        query = $scope.parseQueryToJSON($scope.newQuery)
        if query == ""
            return ""
        return "#/#{ $routeParams.server }/#{ $routeParams.database }/#{ $routeParams.collection }/idx/1/query/#{query}"
    
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

