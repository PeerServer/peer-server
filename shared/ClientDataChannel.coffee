class window.ClientDataChannel

  constructor: (@onOpenCallback, @onMessageCallback) ->
    @dataChannel = new DataChannel()

    # Get an ID from the server
    @socket = io.connect(document.location.origin)
    @socket.on("setID", @handleSetID)

  send: (message) =>
    @dataChannel.send(message)

  getChannelByUserID: (userID) =>
    return @dataChannel.channels[userID]

  handleSetID: (id) =>
    @id = id
    @dataChannel.userid = id
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
      channelSocket.emit("message", { sender: sender, data: message })

    channelSocket.on("message", config.onmessage)

  onOpen: =>
    @onOpenCallback()

  onMessage: (message) =>
    @onMessageCallback(message)

  onFileProgress: =>
    # abstract method

  onFileSent: =>
    # abstract method

  onFileReceived: =>
    # abstract method

  dataChannelReady: =>
    # abstract method


