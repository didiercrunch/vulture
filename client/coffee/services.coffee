root = this

root.services.factory('util', ['$http', '$rootScope', ($http, $rootScope)->
    service =
        get: (params...) ->
            $rootScope.$broadcast("loading")
            return $http.get(params...).
            finally( () ->
                $rootScope.$broadcast("loadingFinished")
            )
        parseObjectId: (objectIdAsString) ->
            if objectIdAsString.length != 24
                throw new Error("object id string must be of length 24")
            ret =
                date: new Date(parseInt(objectIdAsString.substr(0, 8), 16) * 1000)
                machine: parseInt(objectIdAsString.substr(8, 14), 16)
                process: parseInt(objectIdAsString.substr(14, 18), 16)
                counter: parseInt(objectIdAsString.substr(18, 24), 16)

    return service

]);
