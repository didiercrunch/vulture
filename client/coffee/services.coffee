root = this

root.services.factory('util', ['$http', '$rootScope', ($http, $rootScope)->
    service = 
        get: (params...) ->
            $rootScope.$broadcast("loading")
            return $http.get(params...).
            finally( () ->
                $rootScope.$broadcast("loadingFinished")
            )
        
    return service

]);