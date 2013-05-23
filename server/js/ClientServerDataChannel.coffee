class window.ClientServerDataChannel

  constructor: (@onConnectionCallback, @onMessageCallback, @onReady) ->
    if isDevelopmentServer()
      @peer = new Peer(
        host: location.hostname,
        port: 9000,
        config: { 'iceServers': [] })
    else
      @peer = new Peer(key: "rrvwvw4tuyxpqfr", config: { "iceServers": [] })

    @peer.on("open", @onOpen)
    @peer.on("connection", @onConnection)

  onOpen: (id) =>
    @id = id
    @onReady()

  onConnection: (connection) =>
    connection.on "open", () =>
      @onConnectionCallback(connection)
    connection.on "data", (data) =>
      @onData(connection, data)

  onData: (connection, data) =>
    @onMessageCallback(connection, data)

