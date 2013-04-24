""" 
  WebRTC handler for clientBrowser. 

  (TODO at some point refactor)
"""

class window.WebRTC

  # Become a clientBrowser and set up events.
  constructor: (documentElement)->
    @documentElement = documentElement
    
    @connection = io.connect(document.location.origin)
    @connection.emit("joinAsClientBrowser") # Start becoming a clientServer

    # Handshake
    @serverRTCPC = null
    @createServerConnection()
    @createDataChannel()
    @sendOffer()
    @connection.on("receiveAnswer", @receiveAnswer)
    @connection.on("receiveICECandidate", @receiveICECandidate)
    # Store own socket id
    @connection.on "setSocketId", (socketId) =>
      @socketId = socketId

    @htmlProcessor = new HTMLProcessor(@sendEvent, @setDocumentElementInnerHTML, @getSocketId)
    
    # Event Transmission
    @eventTransmitter = new window.EventTransmitter()
    @setUpReceiveEventCallbacks()

  # Returns the client-server's own socket id. 
  getSocketId: =>
    return @socketId

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
    @serverRTCPC = new mozRTCPeerConnection(null, { "optional": [{ "RtpDataChannels": true }] })

    @serverRTCPC.onicecandidate = (event) =>
      @connection.emit("sendICECandidate", "server", event.candidate)

  # Part of connection handshake
  sendOffer: =>
    @serverRTCPC.createOffer (sessionDescription) =>
      @serverRTCPC.setLocalDescription(sessionDescription)
      @connection.emit("sendOffer", sessionDescription)

  # Part of connection handshake
  receiveAnswer: (sessionDescription) =>
    @serverRTCPC.setRemoteDescription(new mozRTCSessionDescription(sessionDescription))

  # Part of connection handshake
  receiveICECandidate: (candidate) =>
      if candidate
        candidate = new mozRTCIceCandidate(candidate)
        console.log candidate
        @serverRTCPC.addIceCandidate(candidate)

  sendEvent: (eventName, data) =>
    @eventTransmitter.sendEvent(@dataChannel, eventName, data)
        
  setUpReceiveEventCallbacks: =>
    @eventTransmitter.addEventCallback("initialLoad", @setDocumentElementInnerHTML)
    @eventTransmitter.addEventCallback("textAreaValueChanged", @setDocumentElementInnerHTML)
    @eventTransmitter.addEventCallback("receiveFile", @htmlProcessor.receiveFile)
    
  setDocumentElementInnerHTML: (html)=>
    @documentElement.innerHTML = "<img src='/client/loading.gif' />"
    @htmlProcessor.processHTML html, (processedHTML) =>
      @documentElement.innerHTML = processedHTML
      @executeScripts()

  # Needed since innerHTML does not run scripts.
  # Inspired by:
  #   http://stackoverflow.com/questions/2592092/executing-script-elements-inserted-with-innerhtml
  executeScripts: =>
    scriptElements = @documentElement.getElementsByTagName("script")
    for oldScriptEl in scriptElements
      newScriptEl = document.createElement("script")
      newScriptEl.type = "text/javascript"
      newScriptEl.text = oldScriptEl.text || oldScriptEl.textContent || oldScriptEl.innerHTML || ""

      oldScriptEl.parentNode.insertBefore(newScriptEl, oldScriptEl)
      oldScriptEl.parentNode.removeChild(oldScriptEl)
      
