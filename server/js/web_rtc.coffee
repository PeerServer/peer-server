"""
  WebRTC handler for clientServer.

  Dispatches (sends and receives) WebRTC data. Should be kept 
  as minimal as possible, dispatching to other modules.
"""

class window.WebRTC
  # Become a clientServer and set up events.
  constructor: (@serverFileCollection, @setClientBrowserLink) ->
    @browserConnections = {}
    @dataChannels = {}

    # Event Transmission
    @eventTransmitter = new window.EventTransmitter()
    @setUpReceiveEventCallbacks()

    @connection = io.connect(document.location.origin)

    @connection.emit("joinAsClientServer") # Start becoming a clientServer

    # Add a clientBrowser who has joined
    @connection.on("joined", @addBrowserConnection)

    @connection.on("receiveOffer", @receiveOffer)
    @connection.on("receiveICECandidate", @receiveICECandidate)
    # Store own socket id
    @connection.on "setSocketId", (socketId) =>
      console.log "SERVER SOCKET ID: " + socketId
      @socketId = socketId
      @setClientBrowserLink(window.location.origin + "/connect/" + socketId + "/")

  # Returns the client-server's own socket id.
  getSocketId: =>
    return @socketId

  # Set up events for new data channel
  addDataChannel: (socketID, channel) ->
    console.log("adding data channel")

    channel.onopen = =>
      console.log "data stream open " + socketID
      landingPage = @serverFileCollection.getLandingPage()
      channel.send(JSON.stringify({ "eventName": "initialLoad", "data": landingPage }))

    channel.onclose = (event) =>
      delete @dataChannels[socketID]
      console.log "data stream close " + socketID

    # Incoming message from the channel (ie, from one of the clientBrowsers)
    channel.onmessage = (message) =>
      console.log "data stream message " + socketID
      console.log message
      @eventTransmitter.receiveEvent(message.data)

    channel.onerror = (err) =>
      console.log "data stream error " + socketID + ": " + err

    @dataChannels[socketID] = channel

  # Make a peer connection with a data channel to the clientBrowser with the socketID
  #  socketID: the socket ID of the client browser (not ourself)
  addBrowserConnection: (socketID) =>
    # Make a peer connection for a data channel (first arg is null ice server)
    peerConnection = new mozRTCPeerConnection(null, { "optional": [{ "RtpDataChannels": true }] })
    @browserConnections[socketID] = peerConnection

    peerConnection.onicecandidate = (event) =>
      @connection.emit("sendICECandidate", socketID, event.candidate)

    peerConnection.ondatachannel = (evt) =>
      console.log("data channel connecting " + socketID)
      @addDataChannel(socketID, evt.channel)

    console.log("client joined", socketID)

  # Part of connection handshake
  receiveOffer: (socketID, sdp) =>
    console.log("offer received from " + socketID)
    pc = @browserConnections[socketID]
    pc.setRemoteDescription(new mozRTCSessionDescription(sdp))
    @sendAnswer(socketID)

  # Part of connection handshake
  sendAnswer: (socketID) ->
    pc = @browserConnections[socketID]
    pc.createAnswer (session_description) =>
      pc.setLocalDescription(session_description)
      @connection.emit("sendAnswer", socketID, session_description)

  # Part of connection handshake
  receiveICECandidate: (socketID, candidate) =>
      if candidate
        candidate = new mozRTCIceCandidate(candidate)
        console.log candidate
        @browserConnections[socketID].addIceCandidate(candidate)

  sendEvent: (eventName, data) =>
    for socketID, dataChannel of @dataChannels
      @eventTransmitter.sendEvent(dataChannel, eventName, data)

  sendEventTo: (socketId, eventName, data) =>
    @eventTransmitter.sendEvent(@dataChannels[socketId], eventName, data)
    console.log "sending event"
    console.log data

  setUpReceiveEventCallbacks: =>
    @eventTransmitter.addEventCallback("requestFile", @serveFile)
    @eventTransmitter.addEventCallback("requestAjax", @serveAjax)

  serveAjax: (data) =>
    console.log "Got an ajax request"
    console.log data

    if 'path' not of data
      console.log "Received bad ajax request: no path requested"
      return

    path = data['path']
    paramData = data.options.data
    if typeof(paramData) is "string"
      paramData = URI.parseQuery(paramData)  # TODO test

    console.log paramData

    # Check for 404s
    if not @serverFileCollection.hasFile(path)
      # TODO: not just do nothing here
      console.log "Path not found"
      return

    # Assemble a response
    response = {}
    if 'requestId' of data
      response['requestId'] = data['requestId']

    response['path'] = path
    response['contents'] = @getContentsForPath(path)
    
    console.log "Transmitting ajax response"
    console.log response
    @sendEventTo(data.socketId, "receiveAjax", response)

  serveFile: (data) =>
    console.log "FILENAME: " + data.filename
    rawPath = data.filename
    [path, params] = @parsePath(rawPath)
    console.log "Parsed path: " + path
    console.log "PARAMS: "
    console.log params

    if not @serverFileCollection.hasFile(path)
      page404 = @serverFileCollection.get404Page()
      console.error "Error: Client requested " + rawPath + " which does not exist on server."
      @sendEventTo(data.socketId, "receiveFile", {
        filename: page404.filename,
        fileContents: page404.fileContents,
        fileType: page404.type,
        type: data.type
      })
      return

    @sendEventTo(data.socketId, "receiveFile", {
      filename: rawPath,
      fileContents: @getContentsForPath(path),
      type: data.type,
      fileType: @serverFileCollection.getFileType(path)
    })

  parsePath: (fullPath) =>
    pathDetails = URI.parse(fullPath)
    params = URI.parseQuery(pathDetails.query)
    console.log params
    return [pathDetails.path, params]

  # TODO handle leading slash and  handle "./file" -- currently breaks
  getContentsForPath: (path) =>
    if @serverFileCollection.isDynamic(path)
      return @evalDynamic(@serverFileCollection.getContents(path))
    return @serverFileCollection.getContents(path)

  # This method allows us to present an API to dynamic code before evaluating it
  # Currently, there is only 1 part of the API: the page's serverFileCollection
  # is made available through a variable of that name.
  evalDynamic: (js) =>
    console.log "evalDynamic"
    exe = =>
      serverFileCollection = @serverFileCollection
      eval(js)

    return exe()
