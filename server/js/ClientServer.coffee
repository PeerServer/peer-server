class window.ClientServer
  
  constructor: (@serverFileCollection, @appView) ->
    @eventTransmitter = new EventTransmitter()
    @dataChannel = new ClientServerDataChannel(@channelOnOpen, @channelOnMessage, @channelOnReady)

    @setUpReceiveEventCallbacks()

  channelOnReady: =>
    @appView.trigger("setServerID", @dataChannel.id)

  channelOnOpen: =>
    console.log "channelOnOpen"
    landingPage = @serverFileCollection.getLandingPage()
    @eventTransmitter.sendEvent(@dataChannel, "initialLoad", landingPage)

  channelOnMessage: (message) =>
    console.log "channelOnMessage", message
    @eventTransmitter.receiveEvent(message)

  setUpReceiveEventCallbacks: =>
    @eventTransmitter.addEventCallback("requestFile", @serveFile)

  sendEventTo: (userID, eventName, data) =>
    console.log @dataChannel.getChannelByUserID(userID)
    channel = @dataChannel.getChannelByUserID(userID)
    @eventTransmitter.sendEvent(channel, eventName, data)

  serveFile: (data) =>
    # TODO handle leading slash and handle "./file" -- currently breaks
    filename = data.filename

    console.log "FILENAME: " + filename

    if not @serverFileCollection.hasFile(filename)
      console.error "Error: Client requested " + filename + " which does not exist on server."
      @sendEventTo(data.socketId, "receiveFile", {
        filename: filename,
        fileContents: "",
        type: ""
      })
      return

    @sendEventTo(data.socketId, "receiveFile", {
      filename: filename,
      fileContents: @serverFileCollection.getContents(filename),
      type: data.type
    })
