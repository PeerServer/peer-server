""" 
  WebRTC handler for clientServer. 

  (TODO at some point refactor)
"""

class window.WebRTC
  # Become a clientServer and set up events.
  constructor: ->
    @browserConnections = {}
    @dataChannels = {}
    
    # Event Transmission
    @eventTransmitter = new window.EventTransmitter()
    @setUpReceiveEventCallbacks()
     
    @connection = io.connect("http://localhost:8890") # TODO fix hard coded connection url
    
    @connection.emit("joinAsClientServer") # Start becoming a clientServer
    
    # Add a clientBrowser who has joined
    @connection.on("joined", @addBrowserConnection)

    @connection.on("receiveOffer", @receiveOffer)
    @connection.on("receiveICECandidate", @receiveICECandidate)


  # Set up events for new data channel
  addDataChannel: (socketID, channel) ->
    console.log("adding data channel")
    
    channel.onopen = =>
      console.log "data stream open " + socketID
      channel.send(JSON.stringify({ "eventName": "initialLoad", "data": "<h2>Welcome page</h2><p>Good job.</p>" }))
  
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
  addBrowserConnection: (socketID) =>
    # Make a peer connection for a data channel (first arg is null ice server)
    peerConnection = new mozRTCPeerConnection(null, { "optional": [{ "RtpDataChannels": true }] })
    @browserConnections[socketID] = peerConnection
    
    peerConnection.onicecandidate = (event) =>
      @connection.emit("sendICECandidate", socketID, event.candidate)

    peerConnection.ondatachannel = (evt) =>
      console.log("data channel connecting " + socketID);
      @addDataChannel(socketID, evt.channel);
      
    console.log("client joined", socketID)

  # Part of connection handshake
  receiveOffer: (socketID, sdp) =>
    console.log("offer received from " + socketID);
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
        
  setUpReceiveEventCallbacks: =>
    @eventTransmitter.addEventCallback("requestFile", @serveFile)
      
  serveFile: (filename)=>
    fileReader = new FileReader()
    
    fileReader.onloadend = (event) =>
      console.log(event.target.result)
      # TODO only send to the interested client-browser
      @sendEvent("receiveFile", {
        filename: filename,
        fileContents: event.target.result
      })
    
    if @isCSSFile(filename)
      blob = new Blob(["body { color: red; }"], { "type" : "text\/css" })
      fileReader.readAsText(blob)
    else if @isJSFile(filename)
      blob = new Blob(["console.log(\"hello\");"], { "type" : "text\/javascript" })
      fileReader.readAsText(blob)
    else if @isImageFile(filename)
      blob = new Blob(["data:image/png;base64,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"], { "type" : "image\/png" })
      fileReader.readAsDataURL(blob)
      
    
  isCSSFile: (filename) =>
    return filename.match(/\.css/) isnt null
    
  isJSFile: (filename) =>
    return filename.match(/\.js/) isnt null

  isImageFile: (filename) =>
    return filename.match(/\.(?:png)|(?:jpg)|(?:jpeg)/) isnt null
