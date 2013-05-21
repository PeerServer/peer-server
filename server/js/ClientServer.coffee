class window.ClientServer
  
  constructor: (@serverFileCollection, @routeCollection, @appView) ->
    @eventTransmitter = new EventTransmitter()
    @dataChannel = new ClientServerDataChannel(
      @channelOnOpen, @channelOnMessage, @channelOnReady)

    @setUpReceiveEventCallbacks()

  channelOnReady: =>
    @appView.trigger("setServerID", @dataChannel.id)

  channelOnOpen: =>
    console.log "channelOnOpen"
    landingPage = @serverFileCollection.getLandingPage()
    @eventTransmitter.sendEvent(@dataChannel, "initialLoad", landingPage)

  channelOnMessage: (message) =>
    console.log "channelOnMessage", message
    @eventTransmitter.receiveEvent(message)

  setUpReceiveEventCallbacks: =>
    @eventTransmitter.addEventCallback("requestFile", @serveFile)
    @eventTransmitter.addEventCallback("requestAjax", @serveAjax)

  sendEventTo: (userID, eventName, data) =>
    @eventTransmitter.sendEvent(@dataChannel.getChannelByUserID(userID),
      eventName, data)

  serveFile: (data) =>
    console.log "FILENAME: " + data.filename
    rawPath = data.filename || ""
    [path, paramData] = @parsePath(rawPath)
    console.log "Parsed path: " + path
    console.log "PARAMS: "
    console.log paramData
    route = "/" + path
    if not @serverFileCollection.hasFile(path) and
    not @routeCollection.hasRoute(route)
      page404 = @serverFileCollection.get404Page()
      console.error "Error: Client requested " + rawPath +
        " which does not exist on server."
      @sendEventTo(data.socketId, "receiveFile", {
        filename: page404.filename,
        fileContents: page404.fileContents,
        fileType: page404.type,
        type: data.type
      })
      return

    @sendEventTo(data.socketId, "receiveFile", {
      filename: rawPath,
      fileContents: @getContentsForPath(path, paramData),
      type: data.type,
      fileType: @serverFileCollection.getFileType(path)
    })

  serveAjax: (data) =>
    console.log "Got an ajax request"
    console.log data

    if 'path' not of data
      console.log "Received bad ajax request: no path requested"
      return

    path = data['path'] || ""
    paramData = data.options.data
    if typeof(paramData) is "string"
      paramData = URI.parseQuery(paramData) # TODO test

    console.log paramData
    route = "/" + path

    # Check for 404s
    if not @serverFileCollection.hasFile(path) and
    not @routeCollection.hasRoute(route)
      # TODO: not just do nothing here
      console.log "Path not found"
      return

    # Assemble a response
    response = {}
    if 'requestId' of data
      response['requestId'] = data['requestId']

    response['path'] = path
    response['contents'] = @getContentsForPath(path, paramData)
    
    console.log "Transmitting ajax response"
    console.log response
    @sendEventTo(data.socketId, "receiveAjax", response)

  parsePath: (fullPath) =>
    if not fullPath or fullPath == ""
      return ["", {}]
    pathDetails = URI.parse(fullPath)
    params = URI.parseQuery(pathDetails.query)
    console.log params
    return [pathDetails.path, params]

  # TODO handle leading slash and handle "./file" -- currently breaks
  getContentsForPath: (path, paramData) =>
    route = "/" + path
    if @routeCollection.hasRoute(route)
      # TODO flesh out with params, etc.
      results =
      runRoute = =>
        serverFileCollection = @serverFileCollection
        params = paramData
        eval(@routeCollection.getRouteCode(route))
      return runRoute()
    if @serverFileCollection.isDynamic(path) # TODO replace with routecollection
      return @evalDynamic(@serverFileCollection.getContents(path))
    return @serverFileCollection.getContents(path)

  # This method allows us to present an API to dynamic code before evaluating it
  # Currently, there is only 1 part of the API: the page's serverFileCollection
  # is made available through a variable of that name.
  evalDynamic: (js) =>
    console.log "evalDynamic"
    exe = =>
      eval(js)

    return exe()
