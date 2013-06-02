class window.ClientServerDataChannel extends ClientDataChannel

  constructor: (options) ->
    @onConnectionCallback = options.onConnectionCallback
    @onDataCallback = options.onDataCallback
    @onReady = options.onReady
    @onConnectionCloseCallback = options.onConnectionCloseCallback
    @id = options.desiredServerID
    @onUnavailableID = options.onUnavailableIDCallback
    @onInvalidID = options.onInvalidIDCallback

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

