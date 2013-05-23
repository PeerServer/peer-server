class window.ClientBrowserDataChannel

  constructor: (@onMessageCallback, @desiredServer) ->
    if isDevelopmentServer()
      @peer = new Peer(
        host: location.hostname,
        port: 9000,
        config: { 'iceServers': [] })
    else
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

