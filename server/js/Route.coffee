'''
  Defines the Route model for handing dynamic paths and 
  defined path parameters.

  TODO: there should be verification on the UI-end that only valid Routes are initialized.
  Specifically: 
    - name should be a valid Javascript function name (nonempty, no invalid characters, no spaces, etc)
    - routePath should be a valid path (tokens separated by / without invalid characters in the tokens.
        some of the tokens can be of the form <token> but there shouldn't be any other angle-brackets 
        except at the start and end.)
    - reserved words: database, static_file, params  (inspect getExecutableFunction for most up-to-date)
'''

class window.Route extends Backbone.Model
  defaults:
    name: ""
    routePath: ""
    routeCode: ""  # The function body to execute for this route
    paramNames: []  # This should NOT be set on initialization -- is derived from routePath
    options: {}
    isProductionVersion: false
    hasBeenEdited: false

  initialize: ->
    @setParsedPath()
    console.log "Parsed route: " + @get("routePath") + " " + @pathRegex + " " + @paramNames
    @on("change:routePath", @setParsedPath)

  # Creates the text of a function that can be eval'd to obtain a renderable result. 
  # Passes in the param names in order, and a final parameter called "params" containing
  #  the url-parameters (ie, get parameters foo and bar for "page?foo=f&bar=b")
  getExecutableFunction: (urlParams, dynamicParams, staticFileFcn, userDatabase) =>
    text = "(function ("
    paramNames = @get("paramNames")
    if paramNames and paramNames.length > 0
      text += paramNames.join(", ") + ", "
    text += "params" + ") {"
    text += @get("routeCode") + "})"
    # Now invoke the function with the appropriate parameters
    text += "("
    if dynamicParams and dynamicParams.length > 0
      dynamicParams = _.map dynamicParams, (param) ->
        return '"' + param + '"'  # Place all the parameter names in quotes, as they are strings.
      console.log "dynamic params: " + dynamicParams
      text += dynamicParams.join(",") + ", "  # Pass in the dynamic url-path parameters
    text += JSON.stringify(urlParams) + ")"  # Pass in the get-url parameters
    console.log "Function: " + text
    fcn = =>
      database = userDatabase
      static_file = staticFileFcn
      render_template = (filename, context) =>
        return window.UserTemplateRenderer.renderTemplate(static_file(filename, context), context)
      try
        return eval(text)
      catch error
        console.log "Eval error: " + error
        return null
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
    @pathRegex = "^/?" + regexParts.join("/") + "/?$" # Indifferent to starting or trailing slash
    @set("paramNames", paramNames)

  # Remove hash or param list from final path part if needed
  # foo?query=hi&another=hello#somehash is converted to foo
  sanitizePathPart: (part) =>
    part = part.split("#")[0]
    part = part.split("&")[0]
    return part

  validate: (attrs) =>
    invalid = {}

    if _.has(attrs, "name") and
    not /^[$A-Z_][0-9A-Z_$]*$/i.test(attrs.name)
      invalid.name = true

    # Route path matches multiple groups of
    # "letters,digits,_,-" or "<letters,digits,_,->"
    # that begin with a "/"
    if _.has(attrs, "routePath") and
    not /^(\/([A-Z\d_-]+|<[A-Z\d_-]+>))+$/i.test(attrs.routePath)
      invalid.routePath = true

    if not _.isEmpty(invalid)
      return invalid


