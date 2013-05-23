class window.ClientBrowserDataChannel

  constructor: (@onMessageCallback, @desiredServer) ->
    @peer = new Peer(key: "rrvwvw4tuyxpqfr", config: { "iceServers": [] })
    @peer.on("open", @onOpen)

  onOpen: (id) =>
    @id = id
    @connection = @peer.connect(@desiredServer, { reliable: true })
    @connection.on("data", @onData)

  onData: (data) =>
    @onMessageCallback(data)

  send: (data) =>
    @connection.send(data)

