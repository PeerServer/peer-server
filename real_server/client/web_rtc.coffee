""" 
  WebRTC handler for clientBrowser. 

  (TODO at some point refactor)
"""

class window.WebRTC

  # Become a clientBrowser and set up events.
  constructor: ->
    @connection = io.connect("http://localhost:8890") # TODO fix hard coded connection url
    @connection.emit("joinAsClientBrowser") # Start becoming a clientServer

    # Handshake
    @createServerConnection()
    @createDataChannel()
    @sendOffer()
    @connection.on("receiveAnswer", @receiveAnswer)
    @connection.on("receiveICECandidate", @receiveICECandidate)

  # Set up events for new data channel
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

  receiveEvent: (messageEventData) =>
    messageEventData = JSON.parse(messageEventData)
    eventName = messageEventData.eventName
    messageData = messageEventData.data

    if @onMessageCallback
      @onMessageCallback(messageData)
    return


  # Part of connection handshake
  createServerConnection: =>
    @serverRTCPC = new RTCPeerConnection(null, { "optional": [{ "RtpDataChannels": true }] })

    @serverRTCPC.onicecandidate = (event) =>
      @connection.emit("sendICECandidate", "server", event.candidate)

  # Part of connection handshake
  sendOffer: =>
    @serverRTCPC.createOffer (sessionDescription) =>
      @serverRTCPC.setLocalDescription(sessionDescription)
      @connection.emit("sendOffer", sessionDescription)

  # Part of connection handshake
  receiveAnswer: (sessionDescription) =>
    console.log("receive answer", sessionDescription);
    @serverRTCPC.setRemoteDescription(new RTCSessionDescription(sessionDescription))

  # Part of connection handshake
  receiveICECandidate: (candidate) =>
      console.log "receive_ice_candidate", candidate
      if candidate
        candidate = new RTCIceCandidate(candidate)
        console.log candidate
        @serverRTCPC.addIceCandidate(candidate)
