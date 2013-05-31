class window.ClientServer
  
  constructor: (@serverFileCollection, @routeCollection, @appView, @userDatabase) ->
    @eventTransmitter = new EventTransmitter()
    @dataChannel = new ClientServerDataChannel(
      @channelOnConnection, @channelConnectionOnData, @channelOnReady)
    @setUpReceiveEventCallbacks()

    @clientBrowserConnections = {}

  channelOnReady: =>
    @appView.trigger("setServerID", @dataChannel.id)

  channelOnConnection: (connection) =>
    landingPage = @serverFileCollection.getLandingPage()

    # connection.peer is the id of the remote peer this connection
    # is connected to
    @clientBrowserConnections[connection.peer] = connection
    
    @eventTransmitter.sendEvent(connection, "initialLoad", landingPage)

  channelConnectionOnData: (data) =>
    @eventTransmitter.receiveEvent(data)

  setUpReceiveEventCallbacks: =>
    @eventTransmitter.addEventCallback("requestFile", @serveFile)

  sendEventTo: (socketId, eventName, data) =>
    connection = @clientBrowserConnections[socketId]
    @eventTransmitter.sendEvent(connection, eventName, data)

  # The client-browser requested a file or path that resulted in an error. 
  # The file might not exist, or evaluating the path may result in an error
  #  due to the user writing broken server code for the path.
  sendFailure: (data, errorMessage) =>
    if data.type is "ajax"
      response = {
        fileContents: "",
        type: data.type, 
        textStatus: "error"
        errorThrown: errorMessage
        requestId: data.requestId
      }
    else
      page404 = @serverFileCollection.get404Page()
      response =  {
        filename: page404.filename,
        fileContents: page404.fileContents,
        fileType: page404.type,
        type: data.type
        errorMessage: errorMessage
      }
    @sendEventTo(data.socketId, "receiveFile", response)

  serveFile: (data) =>
    console.log "FILENAME: " + data.filename
    rawPath = data.filename || ""
    [path, paramData] = @parsePath(rawPath)
    if data.type is "ajax" and data.options.data
      # Merge in any extra parameters passed with the ajax request. 
      if typeof(data.options.data) is "string"
        extraParams = URI.parseQuery(paramData) # TODO test, should return object mapping of get params in data.options.data
      else 
        extraParams = data.options.data
      for name, val of extraParams
        paramData[name] = val
    console.log "Parsed path: " + path
    console.log "PARAMS: "
    console.log paramData
    slashedPath = "/" + path
    foundRoute = @routeCollection.findRouteForPath(slashedPath)  
    # Check if path mapping or a static file for this path exists -- otherwise send failure
    if (foundRoute is null or foundRoute is undefined) and not @serverFileCollection.hasProductionFile(path)
      console.error "Error: Client requested " + rawPath + " which does not exist on server."
      @sendFailure(data, "Not found")
      return
    # TODO check if DYNAMIC is the right enum with serverfilecollection, which is being edited by brie now :)
    fileType = if foundRoute is null then @serverFileCollection.getFileType(path) else "DYNAMIC"
    contents = @getContentsForPath(path, paramData, foundRoute)
    # Check if following the path results in valid contents -- otherwise send failure
    if not contents or contents.length is 0
      console.error "Error: Function evaluation for  " + rawPath + " generated an error, returning 404."
      @sendFailure(data, "Internal server error")
      return
    # Construct the response to send with the contents
    response = {
      filename: rawPath,
      fileContents: contents,
      type: data.type,
      fileType: fileType
    }
    if data.type is "ajax"
      response.requestId = data.requestId
    @sendEventTo(data.socketId, "receiveFile", response)

  parsePath: (fullPath) =>
    if not fullPath or fullPath == ""
      return ["", {}]
    pathDetails = URI.parse(fullPath)
    params = URI.parseQuery(pathDetails.query)
    console.log params
    return [pathDetails.path, params]

  # Returns the contents for the given path with the params. 
  # foundRoute is an optional parameter that must be the corresponding dynamic path 
  #   if the path is a dynamic path (ie, if the path is in the routecollection), or null 
  #   if the path is a static file. 
  # Returns either the html string, or null if none can be found.
  #
  # TODO handle leading slash and handle "./file" -- currently breaks
  getContentsForPath: (path, paramData, foundRoute) =>
    if foundRoute is null or foundRoute is undefined
      return @serverFileCollection.getContents(path)
    # Otherwise, handle a dynamic path
    slashedPath = "/" + path
    # TODO flesh out with params, etc.
    console.log "getting contents for path! "
    console.log foundRoute.paramNames
    match = slashedPath.match(foundRoute.pathRegex)
    console.log "Matching given path " + slashedPath
    console.log "with found path " + foundRoute.get("routePath")
    console.log "and results are: " + match
    runRoute = foundRoute.getExecutableFunction(paramData, match.slice(1), 
      @serverFileCollection.getContents, @userDatabase.database)
    return runRoute()