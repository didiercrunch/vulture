directives.directive "selectOnClick", ->
    restrict: "A"
    link: (scope, element, attrs) ->
        element.on "click", ->
            @select()
            return
    
        return
