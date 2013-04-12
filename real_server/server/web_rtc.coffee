class window.WebRTC
  constructor: ->
    @peerConnections = {}
    @dataChannels = {}
    
    @connection = io.connect("http://localhost:8890")
    
    @connection.emit('joinAsServer')
    
    @connection.on 'joined', (clientID) =>
      @addPeerConnection(clientID)
      console.log('client joined', clientID)

    @connection.on("receiveOffer", @receiveOffer)

    @connection.on "receiveICECandidate", (clientID, candidate) =>
      console.log "receive_ice_candidate", candidate
      if candidate
        candidate = new RTCIceCandidate(candidate)
        console.log candidate
        @peerConnections[clientID].addIceCandidate(candidate)


  addPeerConnection: (clientID) =>
    pc = new RTCPeerConnection(null, { "optional": [{ "RtpDataChannels": true }] })
    @peerConnections[clientID] = pc
    
    pc.onicecandidate = (event) =>
      console.log("onicecandidate")
      @connection.emit("sendICECandidate", clientID, event.candidate)

    pc.ondatachannel = (evt) =>
      console.log('data channel connecting ' + clientID);
      @addDataChannel(clientID, evt.channel);
      return
      
    return

  receiveOffer: (clientID, sdp) =>
    console.log("offer received from " + clientID);
    pc = @peerConnections[clientID]
    pc.setRemoteDescription(new RTCSessionDescription(sdp))
    @sendAnswer(clientID)
    return

  sendAnswer: (clientID) ->
    console.log("sendAnswer")
    pc = @peerConnections[clientID]
    pc.createAnswer (session_description) =>
      pc.setLocalDescription(session_description)
      console.log("sendAnswer emit")
      @connection.emit("sendAnswer", clientID, session_description)
    return

  addDataChannel: (clientID, channel) ->
    console.log("adding data channel")
    
    channel.onopen = ->
      console.log "data stream open " + clientID
  
    channel.onclose = (event) =>
      delete @dataChannels[clientID]
      console.log "data stream close " + clientID
  
    channel.onmessage = (message) ->
      console.log "data stream message " + clientID
      console.log message
  
    channel.onerror = (err) ->
      console.log "data stream error " + clientID + ": " + err
  
    @dataChannels[clientID] = channel
    channel
    
  sendEvent: (eventName, data) =>
    for clientID, dataChannel of @dataChannels
      console.log("send event " + eventName);
      dataChannel.send(JSON.stringify({ "eventName": eventName, "data": data }))
      return

