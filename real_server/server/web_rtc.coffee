""" 
  WebRTC handler for clientServer. 

  (TODO at some point refactor)
"""

class window.WebRTC
  # Become a clientServer and set up events.
  constructor: ->
    @browserConnections = {}
    @dataChannels = {}
     
    @connection = io.connect("http://localhost:8890") # TODO fix hard coded connection url
    
    @connection.emit("joinAsClientServer") # Start becoming a clientServer
    
    # Add a clientBrowser who has joined
    @connection.on("joined", @addBrowserConnection)

    @connection.on("receiveOffer", @receiveOffer)
    @connection.on("receiveICECandidate", @receiveICECandidate)


  # Set up events for new data channel
  addDataChannel: (socketID, channel) ->
    console.log("adding data channel")
    
    channel.onopen = ->
      console.log "data stream open " + socketID
      channel.send(JSON.stringify({ "eventName": "initialLoad", "data": "<h2>Welcome page</h2><p>Good job.</p>" }))
  
    channel.onclose = (event) =>
      delete @dataChannels[socketID]
      console.log "data stream close " + socketID
  
    # Incoming message from the channel (ie, from one of the clientBrowsers)
    channel.onmessage = (message) ->
      console.log "data stream message " + socketID
      console.log message
  
    channel.onerror = (err) ->
      console.log "data stream error " + socketID + ": " + err
  
    @dataChannels[socketID] = channel
    
  sendEvent: (eventName, data) =>
    for socketID, dataChannel of @dataChannels
      console.log("send event " + eventName);
      dataChannel.send(JSON.stringify({ "eventName": eventName, "data": data }))

  # Make a peer connection with a data channel to the clientBrowser with the socketID
  addBrowserConnection: (socketID) =>
    # Make a peer connection for a data channel (first arg is null ice server)
    peerConnection = new RTCPeerConnection(null, { "optional": [{ "RtpDataChannels": true }] })
    @browserConnections[socketID] = peerConnection
    
    peerConnection.onicecandidate = (event) =>
      console.log("onicecandidate")
      @connection.emit("sendICECandidate", socketID, event.candidate)

    peerConnection.ondatachannel = (evt) =>
      console.log("data channel connecting " + socketID);
      @addDataChannel(socketID, evt.channel);
      
    console.log("client joined", socketID)

  # Part of connection handshake
  receiveOffer: (socketID, sdp) =>
    console.log("offer received from " + socketID);
    pc = @browserConnections[socketID]
    pc.setRemoteDescription(new RTCSessionDescription(sdp))
    @sendAnswer(socketID)
    
  # Part of connection handshake
  sendAnswer: (socketID) ->
    console.log("sendAnswer")
    pc = @browserConnections[socketID]
    pc.createAnswer (session_description) =>
      pc.setLocalDescription(session_description)
      console.log("sendAnswer emit")
      @connection.emit("sendAnswer", socketID, session_description)

  # Part of connection handshake
  receiveICECandidate: (socketID, candidate) =>
      console.log "receive_ice_candidate", candidate
      if candidate
        candidate = new RTCIceCandidate(candidate)
        console.log candidate
        @browserConnections[socketID].addIceCandidate(candidate)