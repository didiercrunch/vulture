root = this;


root.controllers.controller('fieldCtrl', ['$scope', '$routeParams', 'util', ($scope, $routeParams, util) ->
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

    util.get(url).then((res) ->
         $scope.doc = res.data.document
         $scope.value = $scope.doc[$scope.field]
         $scope.fields = _.keys($scope.doc)
         $scope.meta = res.data.meta
    )
    
])

