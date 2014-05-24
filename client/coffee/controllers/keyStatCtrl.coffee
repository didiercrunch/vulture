root = this;

humanValueOfStatisticalAbreviation =
    mean: "mean"
    std: "standard deviation"
    var: "variance"
    min: "minimum"
    max: "maximum"
    n: "number of documents"



getAxisLabel = (min, stepSize, numberOfBins) ->
    return (min + 0.5 * stepSize + i * stepSize for i in [0... numberOfBins])

root.controllers.controller('keyStatCtrl', ['$scope', '$routeParams', 'util', ($scope, $routeParams, util) ->
    $scope.name = $routeParams.key
    $scope.stats = []
    
    url  = "/api/#{ $routeParams.server }/#{ $routeParams.database }/#{ $routeParams.collection }"
    url = "#{ url }/stats/#{$routeParams.key}"

    util.get(url).then((res) ->
        for key, val of res.data
            $scope.stats.push({name: humanValueOfStatisticalAbreviation[key], value: val })
    )
    
    $scope.chartConfig =
        options:
            chart:
                type: 'column'
            plotOptions:
                column:
                    groupPadding: 0
                    pointPadding: 0
                    borderWidth: 0
         xAxis:
            categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
        title:
            text: 'Distribution'
        loading: false
        series: [{
            data: [10, 15, 12, 8, 7, 4, 12, 12, 9, 11],
            name: $routeParams.key
            color: '#008CBA'
        }]
    
])

