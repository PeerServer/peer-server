class window.ClientServerDataChannel extends ClientDataChannel

  constructor: ->
    super()
    @dataChannel.direction = "one-to-many"

  dataChannelReady: =>
    @dataChannel.open(@id)

  onMessage: (data) =>
    console.log data

  onOpen: =>
    @dataChannel.send("SERVER: " + @id)
    console.log("onopen")

  onFileProgress: =>
    # TODO

  onFileSent: =>
    # TODO

  onFileReceived: =>
    # TODO

