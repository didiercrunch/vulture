root = this;


humanValueOfStatisticalAbreviation =
    mean: "mean"
    std: "standard deviation"
    var: "variance"
    min: "minimum"
    max: "maximum"
    n: "number of documents"

findHistogramMin = (stats) ->
    return Math.max(stats.min, stats.mean - 3 * stats.std)

findHistogramMax = (stats) ->
    return Math.min(stats.max, stats.mean + 3 * stats.std)


getAxisLabel = (min, stepSize, numberOfBins) ->
    return (min + 0.5 * stepSize + i * stepSize for i in [0... numberOfBins])

root.controllers.controller('keyStatCtrl', ['$scope', '$routeParams', '$location', 'util', ($scope, $routeParams, $location, util) ->
    $scope.name = $routeParams.key
    $scope.stats = []
    $scope.queryObject = $routeParams.query or $routeParams.pipeline or '{}'

    base_url  = "/api/#{ $routeParams.server }/#{ $routeParams.database }/#{ $routeParams.collection }"
    if $routeParams.pipeline
        base_url = "#{base_url}/pipeline/#{$routeParams.pipeline}"
    else
        base_url = "#{base_url}/query/#{$scope.queryObject}"
    stat_url = "#{ base_url }/stats/#{$routeParams.key}"


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
            categories: []
        title:
            text: 'Distribution'
        loading: false
        series: [{
            data: [],
            name: $routeParams.key
            color: '#008CBA'
        }]

    $scope.changeQuery = (query) ->
        if query == ""
            return ""
        r = $routeParams
        $location.path "/#{ r.server }/#{ r.database }/#{ r.collection }/stats/#{ r.key }/query/#{query}"


    util.get(stat_url).then((res) ->
        for key, val of res.data
            $scope.stats.push({name: humanValueOfStatisticalAbreviation[key], value: val })
        numberOfBins = 50
        min = findHistogramMin(res.data)
        max = findHistogramMax(res.data)
        histogram_url = "#{ base_url }/histogram/#{$routeParams.key}/#{min}/#{max}/#{numberOfBins}"
        return util.get(histogram_url)
    ).then((res) ->
        $scope.chartConfig.series[0].data = res.data.values
        $scope.chartConfig.xAxis.categories = getAxisLabel(res.data.min, res.data.step_size, res.data.values.length)
    )

])
