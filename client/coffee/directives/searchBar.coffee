
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

directive = () ->
    directive = 
        templateUrl: "/partials/directives/searchBar.html"
        replace: true,
        transclude: false,
        restrict: 'E',
        scope:
            query: "@"
            callback: "="
        controller:["$scope", "$routeParams", ($scope, $routeParams) ->
                $scope.bigInput = false
                $scope.newQuery = $scope.query or ""
                $scope.codeMirrorOptions =
                    lineWrapping : true
                    lineNumbers: true
                    mode: 'text/typescript'
                
                $scope.parseQueryToJSON = (query) ->
                    try
                        query = mongoJsToMongoJSON(query)
                        ret = JSON.stringify(query)
                        $scope.error = ""
                        return ret
                    catch error
                        $scope.error
                        return ""
                
                $scope.isValidEntry = ()->
                    query = $scope.parseQueryToJSON($scope.newQuery)
                    return query != ""
                
                $scope.callCallback = () ->
                    query = $scope.parseQueryToJSON($scope.newQuery)
                    if query != ""
                        f = () ->
                            $scope.callback(query)
                        $scope.$eval(f)
            ]
    return directive
                        
directives.directive( "vulSearchBar", [directive])