class window.ClientBrowserDataChannel extends ClientDataChannel

  constructor: (@onDataCallback, @desiredServer) ->
    super(@onDataCallback)

  onOpen: (id) =>
    super(id)
    # TODO put back JSON serialization when PeerJS/Chrome works again with big JSON objects.
    # @connection = @peer.connect(@desiredServer, { reliable: true, serialization: "json" })
    @connection = @peer.connect(@desiredServer, { reliable: true })
    @connection.on("data", @onData)

  send: (data) =>
    # TODO remove the stringify when PeerJS/Chrome works again with big JSON objects.
    @connection.send(JSON.stringify(data))

