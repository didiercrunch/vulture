root = this;


root.controllers.controller('fieldCtrl', ['$scope', '$routeParams', '$http', ($scope, $routeParams, $http) ->
    $scope.idx = $routeParams.idx
    $scope.field = $routeParams.field
    $scope.fields = []
    $scope._ = _
    $scope.value = ""
    $scope.doc = {}
    $scope.meta = {}
    
    $scope.fieldUrl = (fieldName) ->
        rt = $routeParams
        return "#/#{ rt.server }/#{ rt.database }/#{ rt.collection }/_id/#{rt.id}/field/#{fieldName}"
        
    url  = "/api/#{ $routeParams.server }/#{ $routeParams.database }/#{ $routeParams.collection }"
    url = "#{ url }/_id/#{$routeParams.id}"

    $http.get(url).then((res) ->
         $scope.doc = res.data.document
         $scope.value = $scope.doc[$scope.field]
         $scope.fields = _.keys($scope.doc)
         $scope.meta = res.data.meta
    )
    
])

