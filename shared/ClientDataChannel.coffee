class window.ClientDataChannel

  constructor: ->
    @dataChannel = new DataChannel()

    # Get an ID from the server
    @socket = io.connect(document.location.origin)
    @socket.on("setID", @handleSetID)

  handleSetID: (id) =>
    @id = id
    console.log(id)
    @initDataChannelCallbacks()
    @dataChannelReady()

  initDataChannelCallbacks: =>
    @dataChannel.openSignalingChannel = @openSignalingChannel
    @dataChannel.onmessage = @onMessage
    @dataChannel.onopen = @onOpen
    @dataChannel.onFileProgress = @onFileProgress
    @dataChannel.onFileSent = @onFileSent
    @dataChannel.onFileReceived = @onFileReceived

  openSignalingChannel: (config) =>
    channel = config.channel or @dataChannel.channel
    sender = @id

    io.connect(document.location.origin).emit("newDataChannel", {
      channel: channel, sender: sender })

    channelSocket = io.connect(document.location.origin + "/" + channel)
    channelSocket.channel = channel
    channelSocket.on "connect", ->
      config.callback(channelSocket) if config.callback

    channelSocket.send = (message) ->
      console.log "send", { sender: sender, data: message }
      channelSocket.emit("message", { sender: sender, data: message })

    channelSocket.on("message", config.onmessage)

  onMessage: (data) =>
    # abstract method

  onOpen: =>
    # abstract method

  onFileProgress: =>
    # abstract method

  onFileSent: =>
    # abstract method

  onFileReceived: =>
    # abstract method

  dataChannelReady: =>
    # abstract method


