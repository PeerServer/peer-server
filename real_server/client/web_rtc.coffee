class window.WebRTC
  constructor: ->
    @connection = io.connect("http://localhost:8890")
    @connection.emit('joinAsClient')

    @createServerConnection()
    @createDataChannel()
    @sendOffer()

    @connection.on("receiveAnswer", @receiveAnswer)

    @connection.on "receiveICECandidate", (candidate) =>
      console.log "receive_ice_candidate", candidate
      if candidate
        candidate = new RTCIceCandidate(candidate)
        console.log candidate
        @serverRTCPC.addIceCandidate(candidate)
    
  sendOffer: ->
    @serverRTCPC.createOffer (sessionDescription) =>
      @serverRTCPC.setLocalDescription(sessionDescription)
      @connection.emit("sendOffer", sessionDescription)

  receiveAnswer: (sessionDescription) =>
    console.log("receive answer", sessionDescription);
    @serverRTCPC.setRemoteDescription(new RTCSessionDescription(sessionDescription))

  createServerConnection: =>
    @serverRTCPC = new RTCPeerConnection(null, { "optional": [{ "RtpDataChannels": true }] })

    @serverRTCPC.onicecandidate = (event) =>
      @connection.emit("sendICECandidate", "server", event.candidate)

  createDataChannel: =>
    try
      console.log "createDataChannel to server"
      @dataChannel = @serverRTCPC.createDataChannel("RTCDataChannel", { reliable: false })

      @dataChannel.onopen = =>
        console.log "data stream open"

      @dataChannel.onclose = (event) =>
        console.log "data stream close"

      @dataChannel.onmessage = (message) =>
        console.log "data stream message"
        console.log message
        @receiveEvent(message.data)
        

      @dataChannel.onerror = (err) =>
        console.log "data stream error: " + err

    catch error
      console.log "seems that DataChannel is NOT actually supported!"
      throw error

  receiveEvent: (messageEventData) ->
    messageEventData = JSON.parse(messageEventData)
    eventName = messageEventData.eventName
    messageData = messageEventData.data

    if @onMessageCallback
      @onMessageCallback(messageData)
    
    return
