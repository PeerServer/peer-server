class window.ClientBrowser

  constructor: (@documentElement) ->
    # Looks at the URL, which must be of the form
    # [host]/connect/[serverSocketId]/[optionalStartPage]
    # desired server is used both as a socket id for joining up via webRTC,
    # as well as in the url path
    [@desiredServer, startPage] = @parseUrl(window.location)
    @pathRoot = "/connect/" + @desiredServer + "/"

    @eventTransmitter = new EventTransmitter()
    @dataChannel = new ClientBrowserDataChannel(
      @channelOnOpen, @channelOnMessage, @desiredServer)

    @htmlProcessor = new HTMLProcessor(
      @sendEvent, @setDocumentElementInnerHTML, @getID)
    @ajaxClient = new AJAXClient(@sendEvent, @getSocketId)

    @setUpReceiveEventCallbacks(startPage)

    window.onpopstate = (evt) =>
      filename = evt.state.path
      @htmlProcessor.requestFile(filename, "backbutton")

  # Returns the client-server's own data channel id.
  getID: =>
    return @dataChannel.id

  # Finds the socket ID of the desired server through the url.
  parseUrl: (locationObj) =>
    pathname = locationObj.pathname
    queryStr = locationObj.search
    if (pathname.indexOf("connect") == -1)
      console.error "Error: pathname does not contain 'connect'"
    # Get everything after "connect/"
    suffix = pathname.substr("/connect/".length)
    slashIndex = suffix.indexOf("/")
    startPage = null # Default start page, none specified
    if slashIndex != -1 # Strip out everything after the id if needed
      serverId = suffix.substr(0, slashIndex)
      # i.e., if there are characters following the slash
      if slashIndex != (suffix.length - 1)
        startPage = suffix.substr(suffix.indexOf("/") + 1)
    else
      serverId = suffix
    result = startPage
    if queryStr
      result += queryStr
    result = startPage + queryStr
    if not result or result == "null"
      result = ""
    console.log "result: " + result
    return [serverId, result]

  sendEvent: (eventName, data) =>
    @eventTransmitter.sendEvent(@dataChannel, eventName, data)

  channelOnOpen: =>
    console.log "channelOnOpen"

  channelOnMessage: (message) =>
    console.log "channelOnMessage", message
    @eventTransmitter.receiveEvent(message)

  setUpReceiveEventCallbacks: (startPage) =>
    @eventTransmitter.addEventCallback "initialLoad", (data) =>
      if startPage # Ignore the initial file and request the start page
        startPage = @htmlProcessor.removeTrailingSlash(startPage)
        # Same behavior as if user just clicked on the link
        @htmlProcessor.requestFile(startPage, "initialLoad")
      else # Load in the default start page.
        @setDocumentElementInnerHTML(data, "initialLoadDefault")

    @eventTransmitter.addEventCallback("receiveFile",
      @htmlProcessor.receiveFile)
    @eventTransmitter.addEventCallback("receiveAjax", @ajaxClient.receiveAjax)
    
  setDocumentElementInnerHTML: (data, optionalInfo)=>
    html = data.fileContents
    path = @htmlProcessor.removeTrailingSlash(data.filename)
    console.log path
    if optionalInfo isnt "backbutton" and optionalInfo isnt "initialLoad" # still do it for initialLoadDefault
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
  # http://stackoverflow.com/questions/2592092/executing-script-elements-inserted-with-innerhtml
  executeScriptsCallback: (scriptMapping) =>
    scriptElements = @documentElement.getElementsByTagName("script")
    for oldScriptEl in scriptElements
      newScriptEl = document.createElement("script")
      newScriptEl.type = "text/javascript"
      # This is where the text we read out of oldScriptEl may have weird encodings (ie, &amp for &, etc)
      # The weird encodings will break things (ie, if we tried to just put the script contents in directly)
      # So we're going through the middle step of putting in the filename as an identifier instead.
      # If the filename has weird encodings, though, all hell breaks loose since scriptMapping breaks.
      filename = oldScriptEl.text || oldScriptEl.textContent || oldScriptEl.innerHTML || ""
      if not scriptMapping[filename]
        console.error("BAD: " + filename + "was not found in the script mapping. Script will not exist. This is because the script name got encoding-bork.")
      newScriptEl.text = scriptMapping[filename]
      # console.log "EXECUTE SCRIPTS index of &amp"
      # console.log newScriptEl.text.indexOf("&amp")
      oldScriptEl.parentNode.insertBefore(newScriptEl, oldScriptEl)
      oldScriptEl.parentNode.removeChild(oldScriptEl)
