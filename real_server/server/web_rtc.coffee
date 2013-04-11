class window.WebRTC
  constructor: ->
    @peerConnections = {}
    @connection = io.connect("http://localhost:8890")
    
    @connection.emit('joinAsServer')
    @connection.on 'joined', (clientID) =>
      @addPeerConnection(clientID)
      console.log('client joined', clientID)

    @connection.on "receiveOffer", @receiveOffer
      
    @dataChannels = {}
    @dataChannelConfig = { "optional": [{ "RtpDataChannels": true }] }

  addPeerConnection: (clientID) ->
    pc = new RTCPeerConnection(null, @dataChannelConfig)
    @peerConnections[clientID] = pc
    pc.ondatachannel = (evt) =>
      console.log('data channel connecting ' + clientID);
      @addDataChannel(clientID, evt.channel);
      return
    return

  receiveOffer: (clientID, sdp) =>
    pc = @peerConnections[clientID]
    pc.setRemoteDescription(new RTCSessionDescription(sdp))
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
    for dataChannel in @dataChannels
      dataChannel.send(JSON.stringify({ "eventName": eventName, "data": data }))
    

