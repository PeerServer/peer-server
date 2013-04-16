""" 
  WebRTC handler for clientServer. 

  (TODO at some point refactor)
"""

class window.WebRTC
  # Become a clientServer and set up events.
  constructor: (@fileStore) ->
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
      blob = new Blob(['alert("hi");'], { "type" : "text\/javascript" })
      fileReader.readAsText(blob)
    else if @isImageFile(filename)
      blob = new Blob(["data:image/png;base64,iVBORw0KGgoAAAANSUhE"], { "type" : "image\/png" })
      fileReader.readAsDataURL(blob)
      
    
  isCSSFile: (filename) =>
    return filename.match(/\.css/) isnt null
    
  isJSFile: (filename) =>
    return filename.match(/\.js/) isnt null

  isImageFile: (filename) =>
    return filename.match(/\.(?:png)|(?:jpg)|(?:jpeg)/) isnt null
