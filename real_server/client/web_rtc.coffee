""" 
  WebRTC handler for clientBrowser. 

  (TODO at some point refactor)
"""

class window.WebRTC

  # Become a clientBrowser and set up events.
  constructor: (documentElement)->
    @documentElement = documentElement
    
    @connection = io.connect("http://localhost:8890") # TODO fix hard coded connection url
    @connection.emit("joinAsClientBrowser") # Start becoming a clientServer

    # Handshake
    @serverRTCPC = null
    @createServerConnection()
    @createDataChannel()
    @sendOffer()
    @connection.on("receiveAnswer", @receiveAnswer)
    @connection.on("receiveICECandidate", @receiveICECandidate)

    @htmlProcessor = new HTMLProcessor(@sendEvent)
    
    # Event Transmission
    @eventTransmitter = new window.EventTransmitter()
    @setUpReceiveEventCallbacks()

  # Set up events for new data channel
  createDataChannel: =>
    try
      console.log "createDataChannel to server"
      @dataChannel = @serverRTCPC.createDataChannel("RTCDataChannel", { reliable: false })

      @dataChannel.onopen = =>
        console.log "data stream open"
        @sendEvent("testEvent", {}) #TODO remove

      @dataChannel.onclose = (event) =>
        console.log "data stream close"

      @dataChannel.onmessage = (message) =>
        console.log "data stream message"
        console.log message
        @eventTransmitter.receiveEvent(message.data)

      @dataChannel.onerror = (err) =>
        console.log "data stream error: " + err

    catch error
      console.error "seems that DataChannel is NOT actually supported!"

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
    @serverRTCPC.setRemoteDescription(new RTCSessionDescription(sessionDescription))

  # Part of connection handshake
  receiveICECandidate: (candidate) =>
      if candidate
        candidate = new RTCIceCandidate(candidate)
        console.log candidate
        @serverRTCPC.addIceCandidate(candidate)

  sendEvent: (eventName, data) =>
    @eventTransmitter.sendEvent(@dataChannel, eventName, data)
        
  setUpReceiveEventCallbacks: =>
    @eventTransmitter.addEventCallback("initialLoad", @setDocumentElementInnerHTML)
    @eventTransmitter.addEventCallback("textAreaValueChanged", @setDocumentElementInnerHTML)
    @eventTransmitter.addEventCallback("receiveFile", @htmlProcessor.receiveFile)
    
  setDocumentElementInnerHTML: (html)=>
    @htmlProcessor.processHTML html, (processedHTML) =>
      @documentElement.innerHTML = processedHTML
