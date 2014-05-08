root = this;


root.controllers.controller('documentCtrl', ['$scope', '$routeParams', '$http', ($scope, $routeParams, $http) ->
    $scope.idx = $routeParams.idx
    $scope.doc = {}
    $scope.idx = Number($routeParams.idx)
    $scope.meta = {}
    $http.get("/api/#{ $routeParams.server }/#{ $routeParams.database }/#{ $routeParams.collection }/idx/#{$routeParams.idx - 1}").then((res) ->
         $scope.doc = res.data.document
         $scope.meta = res.data.meta
    )
    
    $scope.previousDocumentUrl = () ->
        "#/#{ $routeParams.server }/#{ $routeParams.database }/#{ $routeParams.collection }/idx/#{$scope.idx - 1}"

    $scope.nextDocumentUrl = () ->
        "#/#{ $routeParams.server }/#{ $routeParams.database }/#{ $routeParams.collection }/idx/#{$scope.idx + 1}"

    $scope.hasPreviousDocument = () ->
        $scope.idx > 1

    
])