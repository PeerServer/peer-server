class window.ClientBrowserDataChannel extends ClientDataChannel

  constructor: (@onDataCallback, @desiredServer) ->
    super(@onDataCallback)

  onOpen: (id) =>
    super(id)
    @connection = @peer.connect(@desiredServer, { reliable: true })
    @connection.on("data", @onData)

  send: (data) =>
    @connection.send(data)

