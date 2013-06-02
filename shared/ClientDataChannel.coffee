class window.ClientDataChannel

  constructor: (@onDataCallback) ->
    if isDevelopmentServer()
      options =
        host: location.hostname,
        port: 9000,
        config: { 'iceServers': [] }
    else
      options =
        key: "rrvwvw4tuyxpqfr",
        config: { "iceServers": [] }

    # Use the predefined peer id, if there is one
    if @id
      @peer = new Peer(@id, options)
    else
      @peer = new Peer(options)

    @peer.on("open", @onOpen)
    @peer.on("error", @onError)

  onOpen: (id) =>
    @id = id

  onData: (data) =>
    @onDataCallback(data)

  onError: (error) =>
    if error.type is "unavailable-id"
      @onUnavailableID() if @onUnavailableID
    else if error.type is "invalid-id"
      @onInvalidID() if @onInvalidID
