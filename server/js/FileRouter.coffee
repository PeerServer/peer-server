'''
  Defines the Route model and RouteCollection for handing dynamic paths and 
  defined path parameters.

  TODO: there should be verification on the UI-end that only valid Routes are initialized.
  Specifically: 
    - name should be a valid Javascript function name (nonempty, no invalid characters, no spaces, etc)
    - routePath should be a valid path (tokens separated by / without invalid characters in the tokens.
        some of the tokens can be of the form <token> but there shouldn't be any other angle-brackets 
        except at the start and end.)
'''

class window.Route extends Backbone.Model
  defaults:
    name: ""
    routePath: ""
    routeCode: ""  # The function body to execute for this route
    paramNames: []  # This should NOT be set on initialization -- is derived from routePath
    options: {}
    isRequired: false
    isProductionVersion: false

  initialize: ->
    @setParsedPath()
    console.log "Parsed route: " + @get("routePath") + " " + @pathRegex + " " + @paramNames
    @on("change:routePath", @setParsedPath)


  # Creates the text of a function that can be eval'd to obtain a renderable result. 
  # Passes in the param names in order, and a final parameter called "params" containing
  #  the url-parameters (ie, get parameters foo and bar for "page?foo=f&bar=b")
  getExecutableFunction: (urlParams, dynamicParams, staticFiles) =>
    text = "(function " + @get("name") + "("
    paramNames = @get("paramNames")
    text += paramNames.join(", ") + ", params" + ") {"
    text += @get("routeCode") + "})"
    # Now invoke the function with the appropriate parameters
    dynamicParams = _.map dynamicParams, (param) ->
      return '"' + param + '"'  # Place all the parameter names in quotes, as they are strings.
    console.log "dynamic params: " + dynamicParams
    text += "(" + dynamicParams.join(",") + ", " + JSON.stringify(urlParams) + ")"  
    console.log "Function: " + text
    fcn = =>
      staticFiles = staticFiles  # TODO expose these static files a bit more nicely so it is read-only.
      # TODO expose database, templates when they exist.
      eval(text)
    return fcn

  # Parses the route path into a list of ordered parameters.
  # Example: "/<first>/foo/<second>/bar/<third>"  -> ["first", "second", "third"]
  setParsedPath: =>
    isParamPart = (part) =>
      return part.length > 2 and part.charAt(0) is "<" and part.charAt(part.length - 1) is ">"
    path = @get("routePath")
    pathParts = path.split("/")
    paramNames = []
    regexParts = []
    if pathParts.length == 0
      return paramNames
    pathParts[pathParts.length - 1] = @sanitizePathPart(_.last(pathParts))
    for part in pathParts
      # If part matches the form "<something>" then it is a parameter.
      if isParamPart(part)
        paramNames.push(part.slice(1, -1))  # Remove start and end brackets
        regexParts.push("([^/]+)")  # Add a matching regex for this parameter
      else 
        # TODO: Need to encode anything that is URL-safe but not regex-safe
        regexParts.push(part) # Add the part as a raw string to the regex
    @pathRegex = "^" + regexParts.join("/") + "/?$"  # Indifferent to trailing slash
    @set("paramNames", paramNames)

  # Remove hash or param list from final path part if needed
  # foo?query=hi&another=hello#somehash is converted to foo
  sanitizePathPart: (part) =>
    part = part.split("#")[0]
    part = part.split("&")[0]
    return part


class window.RouteCollection extends Backbone.Collection
  model: Route
  
  initialize: ->
    # TODO remove. just for testing.
    indexRoute = new Route(routePath: "/test/<name>/<x>/<y>", routeCode: "var result = parseInt(x)+parseInt(y); return '<h1>hello ' + name + '!</h1><p> x= ' + x + ' plus y = ' + y + ' is ' + result + '</p><h2>' + params.animal + '!!</h2>'", isRequired: true)
    @add(indexRoute)

  comparator: (route) =>
    return route.get("routePath")

  findRouteForPath: (routePath) => 
    console.log "route path: " + routePath
    matchedRoute = @find (route) =>
      return routePath.match(route.pathRegex) isnt null
    return matchedRoute