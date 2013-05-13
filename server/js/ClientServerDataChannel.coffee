class window.ClientServerDataChannel extends ClientDataChannel

  constructor: (@onOpenCallback, @onMessageCallback, @onReady) ->
    super(@onOpenCallback, @onMessageCallback)
    @dataChannel.direction = "one-to-many"

  dataChannelReady: =>
    @dataChannel.open(@id)
    @onReady()

