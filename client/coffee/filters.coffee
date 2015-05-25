root = this;

root.filters.filter 'escape', () ->
  return window.encodeURIComponent;


root.filters.filter 'replaceAllCommasBySpaces', () ->
  return (text) ->
      if _.isString(text)
          return text.replace(new RegExp(",","g"), " ")
      return text

root.filters.filter 'niceJSON', () ->
  return (obj) ->
      return JSON.stringify(obj, null, 4);

root.filters.filter 'replaceReturnByBreak', () ->
    return (text) ->
        return text.replace(new RegExp("\n","g"), "<br>")

root.filters.filter 'onlyNthLines', () ->
    return (text, n) ->
        if not _.isString(text)
            return ""
        s = text.split("\n")
        return s[0...n].join("\n")
