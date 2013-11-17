class window.ClientServer

  constructor: (options) ->
    @serverFileCollection = options.serverFileCollection
    @routeCollection = options.routeCollection
    @appView = options.appView
    @userDatabase = options.userDatabase

    @desiredServerID = @readDesiredServerIDFromURL()

    @eventTransmitter = new EventTransmitter()
    @userSessions = new UserSessions()
    @dataChannel = new ClientServerDataChannel(
      onConnectionCallback: @channelOnConnection,
      onDataCallback: @channelConnectionOnData,
      onReady: @channelOnReady,
      onConnectionCloseCallback: @channelOnConnectionClose,
      desiredServerID: @desiredServerID,
      onUnavailableIDCallback: @channelOnUnavailableID,
      onInvalidIDCallback: @channelOnInvalidID)

    @setUpReceiveEventCallbacks()

    @clientBrowserConnections = {}

    # TODO ensure that this is false
    @isPushChangesEnabled = false
    if @isPushChangesEnabled
      @clientBrowserResourceRequests = {}
      @serverFileCollection.on("change", @onResourceChange)
      @routeCollection.on("change", @onResourceChange)
      @userDatabase.on("onDBChange", @onDBChange)

  channelOnReady: =>
    serverID = @dataChannel.id
    @appView.trigger("setServerID", serverID)
    @serverFileCollection.initLocalStorage(serverID)
    @routeCollection.initLocalStorage(serverID)
    @userDatabase.initLocalStorage(serverID)

  channelOnUnavailableID: =>
    @appView.trigger("onUnavailableID", @desiredServerID)

  channelOnInvalidID: =>
    @appView.trigger("onInvalidID", @desiredServerID)

  readDesiredServerIDFromURL: =>
    if /\/server\//.test(location.pathname)
      return location.pathname.replace(/\/server\//, "")
    return null

  channelOnConnection: (connection) =>
    landingPage = @serverFileCollection.getLandingPage()

    # connection.peer is the socket id of the remote peer this connection
    # is connected to
    @clientBrowserConnections[connection.peer] = connection
    @userSessions.addSession(connection.peer)
    @appView.updateConnectionCount(_.size(@clientBrowserConnections))

    foundRoute = @routeCollection.findRouteForPath("/index")
    # Check if path mapping or a static file for /index exists -- otherwise send index.html
    if foundRoute isnt null and foundRoute isnt undefined
      contents = @getContentsForPath("/index", {}, foundRoute, connection.peer)
      if contents and not contents.error
        landingPage =
          fileContents: contents.result,
          filename: "index",
          type: "text/html"
    @eventTransmitter.sendEvent(connection, "initialLoad", landingPage)


  channelOnConnectionClose: (connection) =>
    @userSessions.removeSession(connection.peer) if connection and connection.peer
    delete @clientBrowserConnections[connection.peer] if connection and connection.peer and _.has(@clientBrowserConnections, connection.peer)
    @appView.updateConnectionCount(_.size(@clientBrowserConnections))
    @removePeerFromClientBrowserResourceRequests(connection.peer)

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
    rawPath = data.filename || ""
    if _.isObject(rawPath)  # In case the user passed an object with a url field instead.
      rawPath = rawPath.url
    [path, paramData] = @parsePath(rawPath)
    if data.options and data.options.data  # Happens for ajax and form submits
      # Merge in any extra parameters passed with the ajax request.
      if typeof(data.options.data) is "string"
        extraParams = URI.parseQuery(paramData) # Return object mapping of get params in data.options.data
      else
        extraParams = data.options.data
      for name, val of extraParams
        paramData[name] = val
    slashedPath = "/" + path

    foundRoute = @routeCollection.findRouteForPath(slashedPath)
    foundServerFile = @serverFileCollection.findWhere(name: path, isProductionVersion: true)

    # Check if path mapping or a static file for this path exists -- otherwise send failure
    if (foundRoute is null or foundRoute is undefined) and not @serverFileCollection.hasProductionFile(path)
      console.error "Error: Client requested " + rawPath + " which does not exist on server."
      @sendFailure(data, "Not found")
      return

    if foundRoute is null or foundRoute is undefined
      fileType = @serverFileCollection.getFileType(path)
    else
      fileType = "UNKNOWN"

    contents = @getContentsForPath(path, paramData, foundRoute, data.socketId)

    # Check if following the path results in valid contents -- otherwise send failure
    if not contents or contents.error
      console.error "Error: Function evaluation for  " + rawPath + " generated an error, returning 404: " + contents.error
      @sendFailure(data, "Internal server error")
      return

    # if contents.result and contents.result.extra is "redirect"  # Option to also return a function to be executed
    #   contents.result.fcn()
    # Construct the response to send with the contents
    response = {
      filename: rawPath,
      fileContents: contents.result,
      type: data.type,
      fileType: fileType
    }

    if data.type is "ajax"
      response.requestId = data.requestId
    else
      @recordResourceRequest(data.socketId, data, foundServerFile, foundRoute)

    @sendEventTo(data.socketId, "receiveFile", response)

  parsePath: (fullPath) =>
    if not fullPath or fullPath == ""
      return ["", {}]
    pathDetails = URI.parse(fullPath)
    params = URI.parseQuery(pathDetails.query)
    return [pathDetails.path, params]

  # Returns the contents for the given path with the params.
  # foundRoute is an optional parameter that must be the corresponding dynamic path
  #   if the path is a dynamic path (ie, if the path is in the routecollection), or null
  #   if the path is a static file.
  # Returns either the html string, or null if none can be found.
  #
  # TODO (?) handle leading slash and handle "./file"
  getContentsForPath: (path, paramData, foundRoute, socketId) =>
    if foundRoute is null or foundRoute is undefined
      return {"result": @serverFileCollection.getContents(path)}
    # Otherwise, handle a dynamic path
    slashedPath = "/" + path
    # TODO (?) flesh out with params, etc.
    match = slashedPath.match(foundRoute.pathRegex)
    runRoute = foundRoute.getExecutableFunction(paramData, match.slice(1),
      @serverFileCollection.getContents, @userDatabase.database, @userSessions.getSession(socketId))
    return runRoute()


  recordResourceRequest: (peerID, data, foundServerFile, foundRoute) =>
    return if not @isPushChangesEnabled

    return if not ((foundServerFile and foundServerFile.get("fileType") is ServerFile.fileTypeEnum.HTML) or
                    foundRoute)

    resource = null
    if foundServerFile
      resource = foundServerFile
    else if foundRoute
      resource = foundRoute
    return if not resource

    resourceName = resource.get("name")
    @removePeerFromClientBrowserResourceRequests(peerID)
    if not @clientBrowserResourceRequests[resourceName]
      @clientBrowserResourceRequests[resourceName] = []
    @clientBrowserResourceRequests[resourceName].push(peerID: peerID, data: data)


  onResourceChange: (resource) =>
    return if not @isPushChangesEnabled
    return if not resource.get("isProductionVersion")
    interestedPeers = @clientBrowserResourceRequests[resource.get("name")]
    _.each interestedPeers, (interestedPeer) =>
      @serveFile(interestedPeer.data)


  removePeerFromClientBrowserResourceRequests: (peerID) =>
    return if not @isPushChangesEnabled

    resourceNames = _.keys(@clientBrowserResourceRequests)

    _.each resourceNames, (resourceName) =>
      @clientBrowserResourceRequests[resourceName] =
        _.filter @clientBrowserResourceRequests[resourceName], (interestedPeer) =>
          return interestedPeer.peerID isnt peerID


  onDBChange: =>
    return if not @isPushChangesEnabled

    resourceNames = _.keys(@clientBrowserResourceRequests)
    _.each resourceNames, (resourceName) =>
      # This is a bit of a hack -- not currently used experiment for push-on-DB-change functionality.
      route = @routeCollection.findWhere(name: resourceName, isProductionVersion: true)
      return if route and /database\.insert\(|database\(.*?\)\.remove\(|database\(.*?\)\.update\(/.test(route.get("routeCode"))

      interestedPeers = @clientBrowserResourceRequests[resourceName]
      _.each interestedPeers, (interestedPeer) =>
        @serveFile(interestedPeer.data)

