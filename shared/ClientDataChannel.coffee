class window.ClientDataChannel

  constructor: (@onDataCallback) ->
    if isDevelopmentServer()
      @peer = new Peer({
        host: location.hostname,
        port: 9000,
        config: { 'iceServers': [] }})
    else
      @peer = new Peer(key: "rrvwvw4tuyxpqfr", config: { "iceServers": [] })

    @peer.on("open", @onOpen)

  onOpen: (id) =>
    @id = id

  onData: (data) =>
    @onDataCallback(data)
