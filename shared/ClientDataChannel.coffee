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
    # TODO remove: hack until PeerJS / Chrome works again with huge JSON objects.
    # In the meantime, this seems to work with the connection sending a stringified data object.
    try
      data = JSON.parse(data)
    catch e
      data = data
    @onDataCallback(data)

  onError: (error) =>
    if error.type is "unavailable-id"
      @onUnavailableID() if @onUnavailableID
    else if error.type is "invalid-id"
      @onInvalidID() if @onInvalidID
