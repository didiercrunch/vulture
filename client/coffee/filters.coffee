root = this;

root.filters.filter 'escape', () ->
  return window.escape;


root.filters.filter 'replaceAllCommasBySpaces', () ->
  return (text) ->
    return text.replace(new RegExp(",","g"), " ")

root.filters.filter 'niceJSON', () ->
  return (obj) ->
    return JSON.stringify(obj, null, 4);
