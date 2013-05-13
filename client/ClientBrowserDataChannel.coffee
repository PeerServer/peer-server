class window.ClientBrowserDataChannel extends ClientDataChannel

  constructor: ->
    super()

    # Looks at the URL, which must be of the form [host]/connect/[serverSocketId]/[optionalStartPage]
    # desired server is used both as a socket id for joining up via webRTC, as well as in the url path
    [@desiredServer, startPage] = @parseUrl(window.location.pathname)

  dataChannelReady: =>
    @dataChannel.connect(@desiredServer)

  onMessage: (data) =>
    console.log data

  onOpen: =>
    console.log("onopen")
    @dataChannel.send("CLIENT: " + @id)

  onFileProgress: =>
    # TODO

  onFileSent: =>
    # TODO

  onFileReceived: =>
    # TODO

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
  

