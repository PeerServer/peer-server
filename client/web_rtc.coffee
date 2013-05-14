""" 
  WebRTC handler for clientBrowser. 

  (TODO at some point refactor)
"""

class window.WebRTC

  # Become a clientBrowser and set up events.
  constructor: (documentElement)->
    @documentElement = documentElement
    @connection = io.connect(window.location.origin)
    # Looks at the URL, which must be of the form [host]/connect/[serverSocketId]/[optionalStartPage]
    # desired server is used both as a socket id for joining up via webRTC, as well as in the url path
    [@desiredServer, startPage] = @parseUrl(window.location.pathname)
    @connection.emit("joinAsClientBrowser", {"desiredServer": @desiredServer}) # Start becoming a clientBrowser
    @pathRoot = "/connect/" + @desiredServer + "/"
    # Handshake
    @serverRTCPC = null
    @createServerConnection()
    @createDataChannel()
    @sendOffer(@desiredServer)
    @connection.on("receiveAnswer", @receiveAnswer)
    @connection.on("receiveICECandidate", @receiveICECandidate)
    # Store own socket id
    @connection.on "setSocketId", (socketId) =>
      @socketId = socketId
    
    @htmlProcessor = new HTMLProcessor(@sendEvent, @setDocumentElementInnerHTML, @getSocketId)
    
    # Event Transmission
    @eventTransmitter = new EventTransmitter()
    @setUpReceiveEventCallbacks(startPage)

    window.onpopstate = (evt) =>
      filename = evt.state.path
      @htmlProcessor.requestFile(filename, "backbutton")

  # Returns the client-server's own socket id. 
  getSocketId: =>
    return @socketId

  # Finds the socket ID of the desired server through the url.
  parseUrl: (pathname) =>
    if (pathname.indexOf("connect") == -1)
      console.error "Error: pathname does not contain 'connect'"
    suffix = pathname.substr("/connect/".length)  # Get everything after "connect/"
    slashIndex = suffix.indexOf("/")
    startPage = null  # Default start page, none specified
    if slashIndex != -1  # Strip out everything after the id if needed
      serverId = suffix.substr(0, slashIndex)
      if slashIndex != (suffix.length - 1)  # i.e., if there are characters following the slash
        startPage = suffix.substr(suffix.indexOf("/") + 1)
    else
      serverId = suffix
    return [serverId, startPage]

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
        #console.log message
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
  sendOffer: (desiredServer) =>
    @serverRTCPC.createOffer (sessionDescription) =>
      @serverRTCPC.setLocalDescription(sessionDescription)
      @connection.emit("sendOffer", sessionDescription, desiredServer)

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
        
  setUpReceiveEventCallbacks: (startPage) =>
    @eventTransmitter.addEventCallback "initialLoad", (data) =>
      if startPage  # Ignore the initial file and request the start page
        startPage = @htmlProcessor.removeTrailingSlash(startPage)
        @htmlProcessor.requestFile(startPage, "initialLoad")  # Same behavior as if user just clicked on the link
      else  # Load in the default start page.
        @setDocumentElementInnerHTML(data, "initialLoadDefault")
    @eventTransmitter.addEventCallback("textAreaValueChanged", @setDocumentElementInnerHTML)
    @eventTransmitter.addEventCallback("receiveFile", @htmlProcessor.receiveFile)
    
  setDocumentElementInnerHTML: (data, optionalInfo)=>
    html = data.fileContents
    path = @htmlProcessor.removeTrailingSlash(data.filename)
    console.log path
    if optionalInfo isnt "backbutton" and optionalInfo isnt "initialLoad"  # still do it for initialLoadDefault
      fullPath = @pathRoot + path
      window.history.pushState({"path": path}, fullPath, fullPath)
      console.log window.history.state
    @documentElement.innerHTML = ""
    if data.fileType is "IMG"
      # Serve up a single image
      @htmlProcessor.processImageAsHTML html, (processedHTML) =>
        @documentElement.innerHTML = processedHTML
    else 
      @htmlProcessor.processHTML html, (processedHTML, scriptMapping) =>
        @documentElement.innerHTML = processedHTML
        @executeScriptsCallback(scriptMapping)
      
  # Needed since innerHTML does not run scripts.
  # Inspired by:
  #   http://stackoverflow.com/questions/2592092/executing-script-elements-inserted-with-innerhtml
  executeScriptsCallback: (scriptMapping) =>
    scriptElements = @documentElement.getElementsByTagName("script")
    for oldScriptEl in scriptElements
      newScriptEl = document.createElement("script")
      newScriptEl.type = "text/javascript"
      # This is where the text we read out of oldScriptEl may have weird encodings (ie, &amp for &, etc)
      #  The weird encodings will break things (ie, if we tried to just put the script contents in directly)
      #  So we're going through the middle step of putting in the filename as an identifier instead. 
      #  If the filename has weird encodings, though, all hell breaks loose since scriptMapping breaks.
      filename = oldScriptEl.text || oldScriptEl.textContent || oldScriptEl.innerHTML || ""
      if not scriptMapping[filename]
        console.error("BAD: " + filename + "was not found in the script mapping. Script will not exist. This is because the script name got encoding-bork.")
      newScriptEl.text = scriptMapping[filename]
      # console.log "EXECUTE SCRIPTS index of &amp"
      # console.log newScriptEl.text.indexOf("&amp")
      oldScriptEl.parentNode.insertBefore(newScriptEl, oldScriptEl)
      oldScriptEl.parentNode.removeChild(oldScriptEl)
