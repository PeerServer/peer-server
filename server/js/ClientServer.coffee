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
    @eventTransmitter.addEventCallback("requestAjax", @serveAjax)

  sendEventTo: (socketId, eventName, data) =>
    connection = @clientBrowserConnections[socketId]
    @eventTransmitter.sendEvent(connection, eventName, data)

  send404: (data) =>
    page404 = @serverFileCollection.get404Page()
    @sendEventTo(data.socketId, "receiveFile", {
      filename: page404.filename,
      fileContents: page404.fileContents,
      fileType: page404.type,
      type: data.type
    })

  serveFile: (data) =>
    console.log "FILENAME: " + data.filename
    rawPath = data.filename || ""
    [path, paramData] = @parsePath(rawPath)
    console.log "Parsed path: " + path
    console.log "PARAMS: "
    console.log paramData
    slashedPath = "/" + path
    foundRoute = @routeCollection.findRouteForPath(slashedPath)  # Check if path mapping
    if (foundRoute is null or foundRoute is undefined) and not @serverFileCollection.hasProductionFile(path)
      console.error "Error: Client requested " + rawPath + " which does not exist on server."
      @send404(data, rawPath)
      return
    # TODO check if DYNAMIC is the right enum with serverfilecollection, which is being edited by brie now :)
    fileType = if foundRoute is null then @serverFileCollection.getFileType(path) else "DYNAMIC"
    contents = @getContentsForPath(path, paramData, foundRoute)
    if not contents or contents.length is 0
      console.error "Error: Function evaluation for  " + rawPath + " generated an error, returning 404."
      @send404(data, rawPath)
      return
    @sendEventTo(data.socketId, "receiveFile", {
      filename: rawPath,
      fileContents: contents,
      type: data.type,
      fileType: fileType
    })

  # TODO handle all this code duplication. Especially since it is buggy from the AJAX.
  # Make it basically identical to serve file / integrate the request id into serve file.
  # serveAjax: (data) =>
  #   console.log "Got an ajax request"
  #   console.log data

  #   if 'path' not of data
  #     console.log "Received bad ajax request: no path requested"
  #     return

  #   path = data['path'] || ""
  #   paramData = data.options.data
  #   if typeof(paramData) is "string"
  #     paramData = URI.parseQuery(paramData) # TODO test

  #   console.log paramData
  #   slashedPath = "/" + path
  #   foundRoute = @routeCollection.findRouteForPath(slashedPath)

  #   # Check for 404s
  #   if not @serverFileCollection.hasProductionFile(path) and not foundRoute
  #     # TODO: not just do nothing here
  #     console.log "Path not found"
  #     return

  #   # Assemble a response
  #   response = {}
  #   if 'requestId' of data
  #     response['requestId'] = data['requestId']

  #   response['path'] = path
  #   response['contents'] = @getContentsForPath(path, paramData, foundRoute)
    
  #   console.log "Transmitting ajax response"
  #   console.log response
  #   @sendEventTo(data.socketId, "receiveAjax", response)

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

    # TODO replace this functionality (the code eval on ajax)
    # if @serverFileCollection.isDynamic(path) # TODO replace with routecollection
      # return @evalDynamic(@serverFileCollection.getContents(path))

  # This method allows us to present an API to dynamic code before evaluating it
  # Currently, there is only 1 part of the API: the page's serverFileCollection
  # is made available through a variable of that name.
  evalDynamic: (js) =>
    console.log "evalDynamic"
    exe = =>
      eval(js)

    return exe()
