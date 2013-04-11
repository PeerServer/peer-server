class window.WebRTC
  constructor: ->
    @connection = io.connect("http://localhost:8890")
    @connection.emit('joinAsClient')
    
    @peerConnection = new RTCPeerConnection(null, { "optional": [{ "RtpDataChannels": true }] })
    @peerConnection.onicecandidate = (event) =>
      if event.candidate
        @connection.emit("sendICECandidate", event.candidate)
    
    @connection.on "receiveICECandidate", (candidate) =>
      console.log("receive ICE")
      @peerConnection.addIceCandidate(new RTCIceCandidate(candidate))

    @connection.on "setClientID", (clientID) =>
      @clientID = clientID
      @createDataChannel()
      @sendOffer()
      
  sendOffer: ->
    @peerConnection.createOffer (sessionDescription) =>
      @peerConnection.setLocalDescription(sessionDescription)
      @connection.emit("sendOffer", @clientID, sessionDescription)
#      console.log(sessionDescription.sdp)

  createDataChannel: ->
    try
      console.log "createDataChannel " + @clientID 
      @dataChannel = @peerConnection.createDataChannel(@clientID, { reliable: false })

      @dataChannel.onopen = =>
        console.log "data stream open " + @clientID

      @dataChannel.onclose = (event) =>
        delete @dataChannels[clientID]
        console.log "data stream close " + @clientID

      @dataChannel.onmessage = (message) =>
        console.log "data stream message " + @clientID
        console.log message

      @dataChannel.onerror = (err) =>
        console.log "data stream error " + @clientID + ": " + err
        
    catch error
      console.log "seems that DataChannel is NOT actually supported!"
      throw error
