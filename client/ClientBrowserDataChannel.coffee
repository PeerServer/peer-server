class window.ClientBrowserDataChannel extends ClientDataChannel

  constructor: (@onOpenCallback, @onMessageCallback, @desiredServer) ->
    super(@onOpenCallback, @onMessageCallback)

  dataChannelReady: =>
    @dataChannel.connect(@desiredServer)

