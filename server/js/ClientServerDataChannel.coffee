class window.ClientServerDataChannel extends ClientDataChannel

  constructor: (@onConnectionCallback, @onDataCallback, @onReady, @onConnectionCloseCallback) ->
    super(@onDataCallback)
    @peer.on("connection", @onConnection)

  onOpen: (id) =>
    super(id)
    @onReady()

  onConnection: (connection) =>
    connection.on "open", =>
      @onConnectionCallback(connection)
    connection.on("data", @onData)
    connection.on "close", =>
      @onConnectionCloseCallback(connection)
